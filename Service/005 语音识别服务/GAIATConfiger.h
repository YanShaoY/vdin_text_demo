//
//  GAIATConfiger.h
//  Demo
//
//  Created by YanSY on 2018/5/15.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 语音识别配置文件
 */
@interface GAIATConfiger : NSObject

#pragma mark -- 配置语音识别服务的参数
/**
 以下参数，需要通过
 iFlySpeechRecgonizer
 进行设置
 ****/
/// 语音输入超时时间 单位:ms 默认:30s
@property (nonatomic, strong) NSString * speechTimeout;
/// 后端静音超时时间。单位:ms 范围:0-10000
@property (nonatomic, strong) NSString * vadEos;
/// 前端静音超时时间。单位:ms 范围:0-10000
@property (nonatomic, strong) NSString * vadBos;
/// 设置网络等待时间
@property (nonatomic, strong) NSString * netWorkWait;
/// 设置语言
@property (nonatomic, strong) NSString * language;
/// 设置方言
@property (nonatomic, strong) NSString * accent;
/// 标点符号设置: 默认为 1，当设置为 0 时，将返回无标点符号文本
@property (nonatomic, strong) NSString * dot;
/// 采样率设置，推荐使用16K
@property (nonatomic, strong) NSString * sampleRate;

/// 是否显示录音动画
@property (nonatomic, assign) BOOL haveView;
/// 口音识别ID 注:废弃 暂时不使用
//@property (nonatomic, strong) NSArray * accentIdentifer;
/// 口音名称数组
@property (nonatomic, strong) NSArray * accentNickName;



#pragma mark -- 获取SDK对应设置参数的key
/*
注：下列方法为在配置语音识别参数时获取SDK设置指定参数的key值时调用
 */

/// 获取普通话的key
-(NSString *)mandarin;
/// 获取广东话的key
-(NSString *)cantonese;
/// 获取四川话的key
-(NSString *)sichuanese;
/// 获取中文的key
-(NSString *)chinese;
/// 获取英文的key
-(NSString *)english;

/// 获取低采样率的key
-(NSString *)lowSampleRate;
/// 获取高采样率的key
-(NSString *)highSampleRate;

/// 获取加入标点的key
-(NSString *)isDot;
/// 获取不加标点的key
-(NSString *)noDot;

@end




