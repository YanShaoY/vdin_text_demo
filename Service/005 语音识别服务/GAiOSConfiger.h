//
//  GAiOSConfiger.h
//  Demo
//
//  Created by YanSY on 2018/6/6.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 iOS原生语音识别配置文件
 */
@interface GAiOSConfiger : NSObject

#pragma mark -- 配置语音识别服务的参数
/// 语音输入超时时间 单位:ms 默认:30s
@property (nonatomic, strong) NSString * speechTimeout;
/// 后端静音超时时间。单位:ms 范围:0-10000
@property (nonatomic, strong) NSString * vadEos;
/// 前端静音超时时间。单位:ms 范围:0-10000
@property (nonatomic, strong) NSString * vadBos;
/// 设置语言
@property (nonatomic, strong) NSString * language;
/// 标点符号设置: 默认为 1，当设置为 0 时，将返回无标点符号文本
@property (nonatomic, strong) NSString * dot;
/// 是否分段返回解析文本
@property (nonatomic, assign) BOOL isReportPartialResults;


#pragma mark -- 获取SDK对应设置参数的key
/// 获取语言字典
- (NSDictionary *)languageDictKey;

#pragma mark -- 实例方法
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
























