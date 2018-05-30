//
//  GASSTConfiger.h
//  Demo
//
//  Created by YanSY on 2018/5/30.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 语音翻译类型
 */
typedef NS_ENUM(NSUInteger , Speech_SST_Type) {
    /// 中文转英文（默认）
    SST_Type_ZhToEn           = 0,
    /// 英文转中文
    SST_Type_EnToZh           = 1,
};

/**
 语音翻译配置文件
 */
@interface GASSTConfiger : NSObject

#pragma mark -- 配置语音翻译服务的参数
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
/// 标点符号设置: 默认为 1，当设置为 0 时，将返回无标点符号文本
@property (nonatomic, strong) NSString * dot;
/// 采样率设置，推荐使用16K
@property (nonatomic, strong) NSString * sampleRate;
/// 是否显示录音动画
@property (nonatomic, assign) BOOL haveView;
/// 语音翻译模式 默认中文转英文
@property (nonatomic, assign) Speech_SST_Type sstType;

#pragma mark -- 获取SDK对应设置参数的key
/*
 注：下列方法为在配置语音识别参数时获取SDK设置指定参数的key值时调用
 */

/// 获取低采样率的key
-(NSString *)lowSampleRate;
/// 获取高采样率的key
-(NSString *)highSampleRate;
/// 获取加入标点的key
-(NSString *)isDot;
/// 获取不加标点的key
-(NSString *)noDot;

/**
 复制拷贝当前配置
 
 @return 返回拷贝后的配置
 */
- (GASSTConfiger *)configerCopy;

@end
