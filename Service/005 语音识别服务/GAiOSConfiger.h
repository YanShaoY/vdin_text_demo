//
//  GAiOSConfiger.h
//  Demo
//
//  Created by YanSY on 2018/6/6.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAiOSConfiger : NSObject

/// 设置语言
@property (nonatomic, strong) NSString * language;


#pragma mark -- 获取SDK对应设置参数的key
/// 获取语言字典
- (NSDictionary *)languageDictKey;

/**
 复制拷贝当前配置
 
 @return 返回拷贝后的配置
 */
- (GAiOSConfiger *)configerCopy;

/**
 根据语言名称找到对应的key

 @param name 语言名字 如:简体中文
 @return 对应的key
 */
- (NSString *)foundLanguageKeyForName:(NSString *)name;

@end
























