# 异步Block接口转为同步接口

## 1.异步Block接口
通常在遇到本地IO操作，网络请求等情况，我们习惯于使用Block作为回调，获取操作的结果，比如：

```
doSomething({
    // success
},{
    // failuer
})
```

但是当业务复杂，需要处理的异步任务比较多时，就会出现回调地狱的问题：

```
doSomething({
    doSomething({
        doSomething({
            doSomething({
                doSomething({
                    // =======================
                })
            })
        })
    })
})
```

基于这个问题，出现了一些解决方案，使用比较多的，就是Promise，将这种"粽子"调用改成"宽面"的调用：

```
doSomething()
.then({
    // =======================
})
.then({
    // =======================
})
.thern({
    // =======================
})
.thern({
    // =======================
})
.thern({
    // =======================
})
```

但是这种代码还是不够优雅，于是又有了async/await的方案：

```
await doSomething();
await doSomething();
await doSomething();
await doSomething();
await doSomething();
```

这个就是我们理想中的代码。

> PS:以上代码为伪码

## 2.iOS 将 block 转为同步
理想很丰满，现实很骨感。Objective-C 没有提供 async/await 方案。如果自己撸一套，由于没有编译器支持，自己添加语法糖的话，会把代码搞的更丑，因此我尝试直接将 Block 转为同步。

原理很简单，就是在 block 回调时，做一次线程同步：

改造前：

```
- (void)sendMessage:(NSString *)message callback:(MissionCallback)callback {
    float random = 1 + (arc4random()%100)/30.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(random * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *tag = [NSString stringWithFormat:@"%@ - random:%f", message, random];
        callback(tag);
    });
}
```

改造后

```
- (NSString *)sendMessageSemaphore:(NSString *)message {
    __block NSString *resultMessage;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self sendMessage:message callback:^(NSString * _Nonnull result) {
        resultMessage = result;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return resultMessage;
}
```
代码很简单，最终的效果也差强人意。实测修改后，该接口同时支持63方并发访问，再多就会卡死。

至于为什么是63这个数字，是因为gcd线程池最大线程数是64，当已经有64个线程并发时，再申请线程资源会被阻塞，直到有其他线程资源被释放。而本例中由于进行线程同步需要占用当前线程，因此当有64个任务并发时，就无法再创建callback的线程，导致所有任务卡死。

App进程的线程资源管理可以在 [xnu](https://github.com/apple/darwin-xnu) 上查到，后面有时间去翻一下，把这块的内容找出来。

## 3.Block 转同步的其他姿势
试验中，分别用信号量、条件锁、互斥锁、自旋锁写了demo，最终的实测效果和上面一样。性能上，dispatch_semaphore 和 pthread_mutex 性能比较好；OSSpinLock 不再安全已经废弃；NSCondition/NSConditionLock 更加灵活一些，Objective-C的接口对一些不熟悉c的程序员更友好。

以下是几种不同的方法的代码实现：

```
// Block
- (void)sendMessage:(NSString *)message callback:(MissionCallback)callback {
    float random = 1 + (arc4random()%100)/30.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(random * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *tag = [NSString stringWithFormat:@"%@ - random:%f", message, random];
        callback(tag);
    });
}

// 信号量
- (NSString *)sendMessageSemaphore:(NSString *)message {
    __block NSString *resultMessage;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self sendMessage:message callback:^(NSString * _Nonnull result) {
        resultMessage = result;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return resultMessage;
}

// 条件锁
- (NSString *)sendMessageCondition:(NSString *)message {
    __block NSString *resultMessage;
    NSCondition *condition = [[NSCondition alloc] init];
    [condition lock];
    [self sendMessage:message callback:^(NSString *result) {
        resultMessage = result;
        [condition signal];
    }];
    [condition wait];
    [condition unlock];
    return resultMessage;
}

- (NSString *)sendMessageConditionLock:(NSString *)message {
    __block NSString *resultMessage;
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:1];
    [self sendMessage:message callback:^(NSString *result) {
        resultMessage = result;
        [lock lock];
        [lock unlockWithCondition:0];
    }];
    [lock lockWhenCondition:0];
    [lock unlock];
    return resultMessage;
}

// 互斥锁
- (NSString *)sendMessageMutex:(NSString *)message {
    __block NSString *resultMessage;
    pthread_mutex_t pMutex = PTHREAD_MUTEX_INITIALIZER;
    __block pthread_cond_t pCond = PTHREAD_COND_INITIALIZER;
    
    pthread_mutex_lock(&pMutex);
    [self sendMessage:message callback:^(NSString *result) {
        resultMessage = result;
        pthread_cond_signal(&pCond);
    }];
    pthread_cond_wait(&pCond, &pMutex);
    pthread_mutex_destroy(&pMutex);
    return resultMessage;
}

// 自旋锁
- (NSString *)sendMessageSpin:(NSString *)message {
    __block NSString *resultMessage;
    __block OSSpinLock oslock = OS_SPINLOCK_INIT;
    
    OSSpinLockLock(&oslock);
    [self sendMessage:message callback:^(NSString *result) {
        resultMessage = result;
        OSSpinLockUnlock(&oslock);
    }];
    OSSpinLockLock(&oslock);
    return resultMessage;
}
```

## 4.一种解决超过64方并发卡死的方案
实际上虽然理论最高支持64个线程，但是线程资源占用太多，也是有影响的。一种可行的办法是创建一个转换同步任务的线程池，控制最大并发数，比如10。再用一个条件锁，当线程池中没有空闲线程资源时，不再执行block转同步的任务。


## 本文Demo代码
[代码](https://github.com/LululuSir/XiaoMing)

## 参考文章
[GCD最大线程数](https://stackoverflow.com/questions/7213845/number-of-threads-created-by-gcd)