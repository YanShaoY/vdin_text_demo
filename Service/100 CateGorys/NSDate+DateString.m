//
//  NSDate+DateString.m
//  GAProduct
//
//  Created by sunlang on 2017/4/10.
//  Copyright © 2017年 ZDHT. All rights reserved.
//

#import "NSDate+DateString.h"

@implementation NSDate (DateString)

/**
 *  根据时间生成名字
 *
 *  @param fileType 文件类型, 比如image.jpg, audio.amr等等
 *
 *  @return 文件名
 */
+ (NSString *)generateFileNameWithType:(NSString *)fileType;
{
    NSDateFormatter *formatter = [self formatter];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@-%@", dateStr, fileType];
    return fileName;
}

+ (NSDateFormatter *)formatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyMMddHHmmss";
        
    });
    
    return formatter;
}

@end
