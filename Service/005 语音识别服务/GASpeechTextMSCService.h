//
//  GASpeechTextMSCService.h
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GASpeechIATService.h"
#import "GASpeechTTSService.h"
#import "GASpeechSSTService.h"

/**
 语音文字识别服务
 */
@interface GASpeechTextMSCService : NSObject

#pragma mark -- 设置注册APPID，服务启动前必须注册
/**
 设置语音服务的APPID

 @param appid 语音注册APP的ID
 */
+ (void)setMSCWithAPPId:(NSString *)appid;

#pragma mark -- 创建语音识别
/**
 初始化语音识别服务

 @param configer 需要设置的配置 nil:默认
 @return 返回语音识别服务
 */
+ (GASpeechIATService *)initSpeechIATServiceWithConfig:(GAIATConfiger *)configer;

#pragma mark -- 创建语音合成
/**
 初始化语音合成服务
 
 @param configer 需要设置的配置 nil:默认
 @return 返回语音识别服务
 */
+ (GASpeechTTSService *)initSpeechTTSServiceWithConfig:(GATTSConfiger *)configer;

#pragma mark -- 创建语音翻译
/**
 初始化语音翻译服务
 
 @param configer 需要设置的配置 nil:默认
 @return 返回语音翻译服务
 */
+ (GASpeechSSTService *)initSpeechSSTServiceWithConfig:(GASSTConfiger *)configer;

@end




















