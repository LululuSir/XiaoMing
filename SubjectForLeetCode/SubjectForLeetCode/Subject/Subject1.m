//
//  Subject0.m
//  SubjectForLeetCode
//
//  Created by 鲁强 on 2018/4/21.
//  Copyright © 2018年 鲁强. All rights reserved.
//

#import "Subject1.h"

@implementation Subject1

+ (void)startSubject {
    NSArray *result = [self getSubFor:9 from:@[@(2), @(7), @(11), @(15)]];
    NSLog(@"%@", result);
}

// 时间复杂度是n²/2，和冒泡排序算法基本一致
+ (NSArray *)getSubFor:(NSInteger)target from:(NSArray *)nums {
    for (NSUInteger i =0; i<nums.count-1; i++) {
        for (NSUInteger j =i+1; j<nums.count; j++) {
            if ([nums[i] integerValue] + [nums[j] integerValue] == target) {
                return @[@(i), @(j)];
            }
        }
    }
    
    return nil;
}

@end
