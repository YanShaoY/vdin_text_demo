//
//  GASpeechTTSService.h
//  Demo
//
//  Created by YanSY on 2018/5/16.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iflyMSC/iflyMSC.h"
#import "GATTSConfiger.h"
#import "GAXFMscPcmPlayer.h"

#pragma mark -- 语音合成服务
/// 合成类型
typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5, //普通合成
    UriType             = 6, //uri合成
};

/// 合成状态
typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2, //高异常分析需要的级别
    Paused              = 4,
};

@protocol GASpeechTTSServiceDelegate;

/**
 语音合成服务
 */
@interface GASpeechTTSService : NSObject

#pragma mark -- 语音合成服务代理及配置对象
/// 设置委托对象
@property (nonatomic ,assign) id<GASpeechTTSServiceDelegate> delegate;
/// 语音合成配置（注：若需更改原始配置，请设置。 默认原始配置）
@property (nonatomic, strong) GATTSConfiger         * baseConfig;

#pragma mark -- 语音合成服务状态获取方法
/// 当前合成类型
- (SynthesizeType)synType;
/// 当前合成状态
- (Status)state;
/// 是否取消
- (BOOL)isCanceled;
/// 是否包含错误
- (BOOL)hasError;

#pragma mark -- 语音合成服务公共方法
/**
 初始化语音合成服务
 
 @return 返回服务对象
 */
+ (GASpeechTTSService *)sharedInstance;

/**
 开始通用语音合成

 @param speakStr 需要合成的文字信息
 @return 是否开启成功
 */
- (BOOL)startTTSToNormalSpeaking:(NSString *)speakStr;

/**
 开始URL语音合成
 
 @param speakStr 需要合成的文字信息
 @return 是否开启成功
 */
- (BOOL)startTTSToURLSpeaking:(NSString *)speakStr;

/**
 取消语音合成
 注：
 1、取消通用合成，并停止播放；
 2、uri合成取消时会保存已经合成的pcm；
 */
- (void)cancelTTSToSpeaking;

/**
 暂停播放
 注：
 对通用合成方式有效，
 对uri合成无效
 */
- (void)pauseTTSToSpeaking;

/**
 恢复播放
 注：
 对通用合成方式有效，
 对uri合成无效
 */
- (void)resumeTTSToSpeaking;

/**
 注销语音识别（注：在界面消失时调用）
 */
- (void)deallocToTTS;

@end


#pragma mark -- 语音合成代理
/**
 语音合成服务代理
 */
@protocol GASpeechTTSServiceDelegate <NSObject>

@optional
/**
 开始播放回调
 注：
 对通用合成方式有效，
 对uri合成无效
 @param service 语音合成服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechTTSService:(GASpeechTTSService *)service
            onSpeakBegin:(BOOL)success;

/**
 取消合成回调
 注：
 对通用合成方式有效，
 对uri合成无效
 @param service 语音合成服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechTTSService:(GASpeechTTSService *)service
           onSpeakCancel:(BOOL)success;

/**
 暂停合成回调
 注：
 对通用合成方式有效，
 对uri合成无效
 @param service 语音合成服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechTTSService:(GASpeechTTSService *)service
           onSpeakPaused:(BOOL)success;

/**
 恢复合成回调
 注：
 对通用合成方式有效，
 对uri合成无效
 @param service 语音合成服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechTTSService:(GASpeechTTSService *)service
          onSpeakResumed:(BOOL)success;

/**
 缓冲进度回调
 注：
 对通用合成方式有效，
 对uri合成无效
 
 @param service 语音合成服务
 @param progress 缓冲进度
 @param msg 附加信息
 */
- (void)speechTTSService:(GASpeechTTSService *)service
        onBufferProgress:(int)progress
                 message:(NSString *)msg;

/**
 播放进度回调

 @param service 语音合成服务
 @param progress 缓冲进度
 @param beginPos 开始点
 @param endPos 结束点
 */
- (void)speechTTSService:(GASpeechTTSService *)service
         onSpeakProgress:(int)progress beginPos:(int)beginPos
                  endPos:(int)endPos;

@required
/**
 合成结束（完成）回调
 注:
 1. 无论合成是否正确都会回调
 2. 若为URL合成，且设置不自动播放，在该方法内获取合成文件
 @param service 语音合成服务
 @param error 错误信息 0:合成结束 other:合成取消或出错
 */
- (void)speechTTSService:(GASpeechTTSService *)service
             onCompleted:(IFlySpeechError *)error;

@end;
















