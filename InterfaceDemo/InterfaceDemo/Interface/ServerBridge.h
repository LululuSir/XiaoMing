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

@end

#define Printer printServer()
extern id printServer(void);
extern void setPrintServer(id printer);

#define Loger logServer()
extern id logServer(void);
extern void addLogServer(id loger);


