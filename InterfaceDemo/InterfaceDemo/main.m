//
//  main.m
//  InterfaceDemo
//
//  Created by LuisGin on 2018/6/28.
//  Copyright © 2018年 LuisGin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerBridge.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        [Printer printHello];
        [Printer world];
        
        [Loger logHello];
        [Loger logWorld];
        
        // hold the thread
        for (NSUInteger i =0; i<10; i++) {
            [NSThread sleepForTimeInterval:1.0f];
            [Loger logHello];
        }
    }
    return 0;
}
