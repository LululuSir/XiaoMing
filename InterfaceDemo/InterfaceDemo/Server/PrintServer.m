//
//  PrintServer.m
//  InterfaceDemo
//
//  Created by LuisGin on 2018/6/28.
//  Copyright © 2018年 LuisGin. All rights reserved.
//

#import "PrintServer.h"
#import "ServerBridge.h"

@interface PrintServer()<PrintServerProtocol>

@end

@implementation PrintServer

// transfer
- (void)world {
    printf("%s - %s\n",NSStringFromClass([self class]).UTF8String, NSStringFromSelector(_cmd).UTF8String);
    [self printWorld];
}

- (void)printHello {
    printf("%s - %s\n",NSStringFromClass([self class]).UTF8String, NSStringFromSelector(_cmd).UTF8String);
}
- (void)printWorld {
    printf("%s - %s\n",NSStringFromClass([self class]).UTF8String, NSStringFromSelector(_cmd).UTF8String);
}

- (void)innerPrintHello {
    printf("%s - %s\n",NSStringFromClass([self class]).UTF8String, NSStringFromSelector(_cmd).UTF8String);
}

- (void)innerPrintWorld {
    printf("%s - %s\n",NSStringFromClass([self class]).UTF8String, NSStringFromSelector(_cmd).UTF8String);
}

@end
