//
//  Mission.h
//  UITest
//
//  Created by luqiang/00465337 on 2019/8/19.
//  Copyright © 2019年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^MissionCallback)(NSString *result);

@interface Mission : NSObject

- (void)sendMessage:(NSString *)message callback:(MissionCallback)callback;

- (NSString *)sendMessageSemaphore:(NSString *)message;
- (NSString *)sendMessageCondition:(NSString *)message;
- (NSString *)sendMessageConditionLock:(NSString *)message;
- (NSString *)sendMessageMutex:(NSString *)message;
- (NSString *)sendMessageSpin:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
