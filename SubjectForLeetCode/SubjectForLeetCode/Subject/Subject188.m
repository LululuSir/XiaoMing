//
//  Subject188.m
//  SubjectForLeetCode
//
//  Created by 鲁强 on 2018/4/22.
//  Copyright © 2018年 鲁强. All rights reserved.
//

#import "Subject188.h"

@implementation Subject188

int maxProfitUtility(int k, int* makeMoney, int makeMoneyCount, int* lossMoney, int lossMoneyCount) {
    int result = 0;
    if (k >= makeMoneyCount) {
        for (int i =0; i<makeMoneyCount; i++) {
            result+=makeMoney[i];
        }
        return result;
    }
    
    int maxLossMoneyIndex = -1;
    int maxUnionMoney = 0;
    int maxLossMoney = -1000000000;
    for (int i =0; i< lossMoneyCount; i++) {
        if (lossMoney[i] >= maxLossMoney ) {
            int unionMoney = makeMoney[i] + makeMoney[i+1] + lossMoney[i];
            if (unionMoney >= makeMoney[i] &&  unionMoney >= makeMoney[i+1]) {
                maxUnionMoney = unionMoney;
                maxLossMoney = lossMoney[i];
                maxLossMoneyIndex = i;
            }
        }
    }

    if (maxLossMoneyIndex >= 0) {
        makeMoney[maxLossMoneyIndex] = maxUnionMoney;
        for (int i =maxLossMoneyIndex+1; i<makeMoneyCount-1; i++) {
            makeMoney[i] = makeMoney[i+1];
        }
        for (int i =maxLossMoneyIndex; i<lossMoneyCount-1; i++) {
            lossMoney[i] = lossMoney[i+1];
        }
        return maxProfitUtility(k, makeMoney, makeMoneyCount-1, lossMoney, lossMoneyCount-1);
    } else {
        // 冒泡排序
        for (int i =0;i<makeMoneyCount;i++) {
            for (int j=0;j<makeMoneyCount-1-i;j++) {
                if (makeMoney[j]<makeMoney[j+1] ) {
                    int tmp = makeMoney[j];
                    makeMoney[j] = makeMoney[j+1];
                    makeMoney[j+1] = tmp;
                }
            }
        }
        for (int i =0; i<k; i++) {
            result += makeMoney[i];
        }
        return result;
    }
}

int maxProfit2(int k, int* makeMoney, int makeMoneyCount) {
    int *newMakeMoney = (int *)malloc(sizeof(int)*makeMoneyCount);
    for (int i = 0;i<makeMoneyCount;i++) {
        newMakeMoney[i] = makeMoney[i];
    }
    
    int result = 0;
    // 冒泡排序
    for (int i =0;i<makeMoneyCount;i++) {
        for (int j=0;j<makeMoneyCount-1-i;j++) {
            if (newMakeMoney[j]<newMakeMoney[j+1] ) {
                int tmp = newMakeMoney[j];
                newMakeMoney[j] = newMakeMoney[j+1];
                newMakeMoney[j+1] = tmp;
            }
        }
    }
    for (int i =0; i<(k<makeMoneyCount?k:makeMoneyCount); i++) {
        result += newMakeMoney[i];
    }
    return result;
}
    
int maxProfit(int k, int* prices, int pricesSize) {
    if (pricesSize <=0) {
        return 0;
    }
    // 找到拐点
    int *lossMoney = (int *)malloc(sizeof(int)*pricesSize);
    int lossMoneyIndex = 0;
    int *makeMoney = (int *)malloc(sizeof(int)*pricesSize);
    int makeMoneyIndex = 0;
    int lastIndex = 0;
    for (int i =1; i<pricesSize-1; i++) {
        if ( (prices[i]-prices[i-1])*(prices[i]-prices[i+1]) >= 0 ) {
            if (prices[i]-prices[lastIndex] == 0) {
                continue;
            }
            if (prices[i]-prices[lastIndex] > 0) {
                printf("make ");
                if (lossMoneyIndex==makeMoneyIndex) {
                    makeMoney[makeMoneyIndex++] = prices[i]-prices[lastIndex];
                } else {
                    makeMoney[makeMoneyIndex-1] += prices[i]-prices[lastIndex];
                }
            }
            if (prices[i]-prices[lastIndex] < 0) {
                printf("loss ");
                if ( lossMoneyIndex<makeMoneyIndex ) {
                    lossMoney[lossMoneyIndex++] = prices[i]-prices[lastIndex];
                } else {
                    lossMoney[lossMoneyIndex-1] += + prices[i]-prices[lastIndex];
                }
            }
            printf("index | %d | %d\n", i+1, prices[i]-prices[lastIndex]);
            lastIndex = i;
        }
    }
    
    if (prices[pricesSize-1]-prices[lastIndex] > 0) {
        makeMoney[makeMoneyIndex++] = prices[pricesSize-1]-prices[lastIndex];
        printf("index | %d | %d\n", pricesSize-1, prices[pricesSize-1]-prices[lastIndex]);
    }
    
    // 两种策略
    int result1 = maxProfit2(k, makeMoney, makeMoneyIndex);
    int result2 = maxProfitUtility(k, makeMoney, makeMoneyIndex, lossMoney, lossMoneyIndex);
    return result1>result2?result1:result2;
}

+ (void)startSubject {
    int prices[7] = {2,1,4,5,2,9,7};
    // 2, -5, 3, -2,3
    NSLog(@"%d", maxProfit(2, prices, 7));
}

@end
