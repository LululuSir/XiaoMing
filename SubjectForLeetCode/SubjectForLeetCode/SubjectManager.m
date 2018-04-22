//
//  SubjectManager.m
//  SubjectForLeetCode
//
//  Created by 鲁强 on 2018/4/21.
//  Copyright © 2018年 鲁强. All rights reserved.
//

#import "SubjectManager.h"

@implementation SubjectManager

+ (void)startSubjectsDebug:(NSArray *)subjects {
    SEL sel = NSSelectorFromString(@"startSubject");
    for (NSNumber *subjectIndex in subjects) {
        NSString *className = [NSString stringWithFormat:@"Subject%@",subjectIndex];
        Class clazz = NSClassFromString(className);
        if ([clazz respondsToSelector:sel]) {
            [clazz performSelector:sel];
        }
    }
}

@end
