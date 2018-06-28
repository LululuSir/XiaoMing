//
//  PrintServer.h
//  InterfaceDemo
//
//  Created by LuisGin on 2018/6/28.
//  Copyright © 2018年 LuisGin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrintServer : NSObject

- (void)printHello;
- (void)printWorld;

- (void)innerPrintHello;
- (void)innerPrintWorld;

@end
