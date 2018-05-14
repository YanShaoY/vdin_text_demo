//
//  ISRDataHelper.h
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISRDataHelper : NSObject

/**
 解析命令词返回的结果

 @param params 传入命令解析数据
 @return 返回解析结果
 */
+ (NSString*)stringFromAsr:(NSString*)params;

/**
 解析JSON数据

 @param params 需要解析的json数据
 @return 解析后结果
 */
+ (NSString *)stringFromJson:(NSString*)params;

/**
 解析语法识别返回的结果

 @param params 语法识别结果
 @return 解析后的结果
 */
+ (NSString *)stringFromABNFJson:(NSString*)params;

@end





