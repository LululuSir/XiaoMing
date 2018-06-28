# iOS面向接口编程(面向protocol编程)
## 前言
面向接口编程已经是老生常谈了，但是最近在做项目重构中发现，团队对面向接口编程的理解还停留在纸面，并没有进行实践。网上也没有简单易懂的解释iOS(objective-c)的面向接口编程的文章，特此整理以下。

## 什么是面向接口编程
本文不深入解释什么是面向接口编程，如有需要烦请自行百度&Google。摘抄一个[网上的解释](https://baike.baidu.com/item/%E9%9D%A2%E5%90%91%E6%8E%A5%E5%8F%A3%E7%BC%96%E7%A8%8B/6025286?fr=aladdin)：

```
	我们在一般实现一个系统的时候，通常是将定义与实现合为一体，不加分离的，
	我认为最为理想的系统设计规范应是所有的定义与实现分离，尽管这可能对系统中的某些情况有点麻烦。
```

## iOS实现面向接口编程
先说实现，后面再解释原理。我们将设计分为：底层实现、接口层、上层调用，三个部分。
### 1.接口层
接口层是上下层的粘合剂，实现上下层的分离。

- <b>接口层通过protocol声明底层需要实现的接口，同时也是上层可以调用的接口。</b>

```
@protocol PrintServerProtocol <NSObject>

- (void)printHello;
- (void)world;

@end
```

接口层通过单例持有底层服务

```
@interface ServerBridge()
@property (nonatomic, strong) id<PrintServerProtocol> printer;
+ (instancetype)shareInstance;
@end

@implementation ServerBridge
+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
@end
```

- <b>底层需要将自己的功能注入给接口层。</b>

```
extern void setPrintServer(id printer);

void setPrintServer(id printer) {
    [ServerBridge shareInstance].printer = printer;
}


```

- <b>上层通过指定的入口调用下层的接口</b>

```
#define Printer printServer()
extern id printServer(void);

id printServer(void)
{
    return [ServerBridge shareInstance].printer;
}

```

### 2.底层
<b>底层需要遵循接口层协议，并实现protocol的声明的方法</b>

```

@interface PrintServer()<PrintServerProtocol>

@end

@implementation PrintServer

- (void)printHello {
    printf("%s - %s\n",NSStringFromClass([self class]).UTF8String, NSStringFromSelector(_cmd).UTF8String);
}

- (void)world {
    printf("%s - %s\n",NSStringFromClass([self class]).UTF8String, NSStringFromSelector(_cmd).UTF8String);
}

@end
```

<b>底层的服务需要注入到接口层，可以是底层setup时注入，也可以是二方的其他合适的位置注入</b>

```
@implementation ServerSetup

+ (void)load {
    setPrintServer([PrintServer new]);
    addLogServer([LogServer new]);
    addLogServer([LogServerNew new]);
}

@end
```

### 3.上层使用
上层只依赖接口层，通过接口层调用底层方法

```
    [Printer printHello];
    [Printer world];
```

## 面向接口编程的扩展
我们可以将底层SDK看做是接口功能服务提供方，上层是接口功能服务的使用方。当前的实现，是服务提供方有1个，服务使用方没有限制，可以任意使用。是一个1对多的模型。在这个基础上，我们还可以扩展出多种形式的1对多的模型。

### 多个底层接口提供方，按需调用其中1个
第一次扩展，我们希望，能够有多个底层接口提供方，上层业务使用时，可以按需调动。这一模型，很容易就想到，在接口层添加一个可变数组，通过维护数组实现相应的功能。

- <b>接口层</b>

```

@interface ServerBridge()
@property (nonatomic, strong) NSMutableArray *logerServers;
@property (nonatomic, strong) id<LogServerProtocol> loger;

+ (instancetype)shareInstance;
- (void)addLogerServer:(id<LogServerProtocol>)player;

@end

@implementation ServerBridge

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark loger
- (NSMutableArray *)logerServers {
    if (!_logerServers) {
        _logerServers = [NSMutableArray array];
    }
    return _logerServers;
}

- (instancetype)loger {
    // 针对多个server，根据条件取得合适的server
    id targetClass;
    if (arc4random()%2 == 0) {
        targetClass = [LogServer class];
    } else {
        targetClass = [LogServerNew class];
    }
    
    for (id loger in self.logerServers) {
        if ([loger isKindOfClass:[targetClass class]]) {
            return loger;
        }
    }
    return nil;
}

- (void)addLogerServer:(id<LogServerProtocol>)player {
    @synchronized(self) {
        if ( [player conformsToProtocol:@protocol(LogServerProtocol)] ) {
            [self.logerServers addObject:player];
        }
    }
}

@end
```

即，我们通过维护一个内部可变数组的方式，用随机值模拟实际的条件(如根据网络状况选择服务：lowNetQuality时选serverA，highNetQuality时选serverB)。

需要注意的是，Foundation框架下的NSMutable不是线程安全的，即便property中声明了atomic。当然，上述demo代码也只对setter做了简单的线程保护，并不能完全保证线程安全。

- <b>底层</b>

底层实现同上，setup中也仅仅需要进行add操作

- <b>上层</b>

上层调用同上，可以通过block或其他形式，将选择server的条件暴露给上层。需要注意的是，这可能会以另一种形式将上下层再次耦合起来。

## 多个底层接口提供方，顺序调用全部
这个方案实现起来相对复杂。一种可行的思路是，在接口层进行消息转发，在转发接口时，从servers数组中依次取出server，并进行转发。

## iOS面向接口实现原理
首先解释一个误区，很多iOS开发工程师认为protocol就是传递方法调用的(委托&代理)，只有dataSource，delegate两种用法。这种理解很狭隘，会限制protocol使用的想象。

protocol只是声明了一组接口，遵从协议的一方需要对应实现，此外没有更多了。委托，代理，面向接口都是protocol的一种使用方式。

根据这种解释，面向接口编程就很好理解了。接口层声明了一组protocol，底层声明遵从协议，并实现相应方法。上层调用底层的实例/类，就可以直接调用对应的接口了。中间的接口层就是一层粘合剂，把下层的实例/类注入进来，上层拿注入好的实例/类调用对应方法即可。

delegate其实理解起来反倒更难一点。因为delegate的实现，和本文讲的接口分离，刚好是反着的。以我们通常使用的UITableViewDelegate为例：

<b>接口层</b>

```
@protocol UITableViewDelegate<NSObject, UIScrollViewDelegate>
// 接口方法······
@end
```

<b>底层</b>

```
// 服务注入
tableView.delegate = self;

// 接口实现
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// 具体实现
}

```

<b>上层调用</b>

```
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// ···
	if ( [self.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)] ) {
		[self.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
	}
	// ···
}
```

可以很明显的看到，我们平时代码里写的UITableViewDelegate的接口的实现，刚好对应面向接口编程中的底层服务。

## 本文Demo代码
[代码](https://github.com/LululuSir/XiaoMing)