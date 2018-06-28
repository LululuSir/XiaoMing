//
//  LogServer.m
//  InterfaceDemo
//
//  Created by LuisGin on 2018/6/28.
//  Copyright © 2018年 LuisGin. All rights reserved.
//

#import "LogServer.h"
#import "ServerBridge.h"

@interface LogServer()<LogServerProtocol>
@end

@implementation LogServer

- (void)logHello {
    NSLog(@"%@ - %@\n",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}
- (void)logWorld {
    NSLog(@"%@ - %@\n",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)innerLogHello {
    NSLog(@"%@ - %@\n",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)innerLogWorld {
    NSLog(@"%@ - %@\n",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

@end
