//
//  ServerBridge.h
//  InterfaceDemo
//
//  Created by LuisGin on 2018/6/28.
//  Copyright © 2018年 LuisGin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PrintServerProtocol <NSObject>

- (void)printHello;
- (void)world;

@end

@protocol LogServerProtocol <NSObject>

- (void)logHello;
- (void)logWorld;

@end

@interface ServerBridge : NSObject

+ (instancetype)shareInstance;

#pragma mark - printer
// 上层业务调用入口
@property (nonatomic, strong, readonly) id<PrintServerProtocol> printer;

// 底层SDK服务注入入口
- (void)setPrinterServer:(id<LogServerProtocol>)printer;

#pragma mark - loger
// 上层业务调用入口
@property (nonatomic, strong, readonly) id<LogServerProtocol> loger;

// 底层SDK服务注入入口
- (void)addLogerServer:(id<LogServerProtocol>)loger;

@end


