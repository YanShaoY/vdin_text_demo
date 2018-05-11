//
//  NSDate+DateString.h
//  GAProduct
//
//  Created by sunlang on 2017/4/10.
//  Copyright © 2017年 ZDHT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DateString)

/**
 *  根据时间生成名字
 *
 *  @param fileType 文件类型, 比如image.jpg, audio.amr等等
 *
 *  @return 文件名
 */
+ (NSString *)generateFileNameWithType:(NSString *)fileType;

@end
