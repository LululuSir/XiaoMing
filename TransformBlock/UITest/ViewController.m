//
//  ViewController.m
//  UITest
//
//  Created by luqiang/00465337 on 2019/8/19.
//  Copyright © 2019年 frank. All rights reserved.
//

#import "ViewController.h"
#import "Mission.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(80, 200, 200, 80);
    button.backgroundColor = [UIColor greenColor];
    [button setTitle:@"Async Mission" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(80, 300, 200, 80);
    button2.backgroundColor = [UIColor greenColor];
    [button2 setTitle:@"Sync MIssion" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(buttonClick2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

- (void)buttonClick:(id )sender {
    [self asyncInterfaceWithBlock];
}

- (void)buttonClick2:(id )sender {
    [self syncInterface];
}

- (void)asyncInterfaceWithBlock {
    // 无限制并发接口
    for (NSUInteger i =0; i<100; i++) {
        NSString *message = [NSString stringWithFormat:@"event%lu", i];
        NSLog(@"①send message %@", message);
        [[Mission new] sendMessage:message callback:^(NSString * _Nonnull result) {
            NSLog(@"①rece message %@", result);
        }];
    }
}

- (void)syncInterface {
    // 最大63方并发接口
    Mission *mission = [Mission new];
    for (NSUInteger i =0; i<63; i++) {
        NSString *message = [NSString stringWithFormat:@"event%lu", i];
        NSLog(@"②send message %@", message);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *result = [mission sendMessageSemaphore:message];
//            NSString *result = [mission sendMessageCondition:message];
//            NSString *result = [mission sendMessageConditionLock:message];
//            NSString *result = [mission sendMessageMutex:message];
//            NSString *result = [mission sendMessageSpin:message];
            NSLog(@"②receive message %@", result);
        });
    }
}

@end
