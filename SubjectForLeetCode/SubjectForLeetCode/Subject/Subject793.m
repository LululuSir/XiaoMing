//
//  Subject793.m
//  SubjectForLeetCode
//
//  Created by 鲁强 on 2018/4/22.
//  Copyright © 2018年 鲁强. All rights reserved.
//

#import "Subject793.h"

@implementation Subject793
// leetcode 地址: https://leetcode-cn.com/problems/preimage-size-of-factorial-zeroes-function/description/
// 求阶乘n!的值，末尾有几个0；10的约数为1,2,5,10；
// 解：每隔5，增加1~x个0，凡是经过25时，0的个数跳过。

unsigned long getZeroCountOf(unsigned long n) {
    if (n == 0) {
        return 0;
    }
    return n/5 + getZeroCountOf(n/5);
}

int preimageSizeFZF(int K) {
    for (unsigned long i =(long long)K*4; i<-1;i++) {
        unsigned long zeroCount = getZeroCountOf(i);
        if (zeroCount == K) {
            return 5;
        }
        if (zeroCount > K) {
            return 0;
        }
    }
    return 0;
}

+ (void)startSubject {
    NSLog(@"%d", preimageSizeFZF(1000000000));
}

@end
