//
//  LogServer.h
//  InterfaceDemo
//
//  Created by LuisGin on 2018/6/28.
//  Copyright © 2018年 LuisGin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogServer : NSObject

- (void)logHello;
- (void)logWorld;

- (void)innerLogHello;
- (void)innerLogWorld;

@end
