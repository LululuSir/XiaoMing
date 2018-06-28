//
//  ServerBridge.m
//  InterfaceDemo
//
//  Created by LuisGin on 2018/6/28.
//  Copyright © 2018年 LuisGin. All rights reserved.
//

#import "ServerBridge.h"
#import "LogServerNew.h"
#import "LogServer.h"

@interface ServerBridge()
@property (nonatomic, strong) id<PrintServerProtocol> printer;
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

id printServer(void)
{
    return [ServerBridge shareInstance].printer;
}

void setPrintServer(id printer) {
    [ServerBridge shareInstance].printer = printer;
}

id logServer(void)
{
    return [ServerBridge shareInstance].loger;
}

void addLogServer(id loger)
{
    [[ServerBridge shareInstance] addLogerServer:loger];
}

