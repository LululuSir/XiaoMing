//
//  ServerSetup.m
//  InterfaceDemo
//
//  Created by LuisGin on 2018/6/28.
//  Copyright © 2018年 LuisGin. All rights reserved.
//

#import "ServerSetup.h"
#import "PrintServer.h"
#import "LogServer.h"
#import "LogServerNew.h"
#import "ServerBridge.h"

@implementation ServerSetup

+ (void)load {
    setPrintServer([PrintServer new]);
    addLogServer([LogServer new]);
    addLogServer([LogServerNew new]);
}

@end
