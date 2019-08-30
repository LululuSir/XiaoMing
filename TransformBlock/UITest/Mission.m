//
//  Mission.m
//  UITest
//
//  Created by luqiang/00465337 on 2019/8/19.
//  Copyright © 2019年 frank. All rights reserved.
//

#import "Mission.h"
#include <pthread.h>
#import <libkern/OSAtomic.h>

@implementation Mission

- (void)sendMessage:(NSString *)message callback:(MissionCallback)callback {
    float random = 1 + (arc4random()%100)/30.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(random * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *tag = [NSString stringWithFormat:@"%@ - random:%f", message, random];
        callback(tag);
    });
}

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

@end
