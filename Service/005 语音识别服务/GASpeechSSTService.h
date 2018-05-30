//
//  GASpeechSSTService.h
//  Demo
//
//  Created by YanSY on 2018/5/30.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IFlyMSC/IFlyMSC.h"
#import "GASSTConfiger.h"
#import "GAXFMscDataHelper.h"

#pragma mark -- 语音翻译服务
@protocol GASpeechSSTServiceDelegate;

/**
 语音翻译服务
 */
@interface GASpeechSSTService : NSObject

#pragma mark -- 语音翻译服务代理及配置对象
/// 设置委托对象
@property (nonatomic ,assign) id<GASpeechSSTServiceDelegate> delegate;
/// 语音翻译配置（注：若需更改原始配置，请设置。 默认原始配置）
@property (nonatomic, strong) GASSTConfiger         * baseConfig;

#pragma mark -- 语音翻译服务状态获取方法
/// 是否取消
- (BOOL)isCanceled;

#pragma mark -- 语音翻译服务公共方法
/**
 初始化语音翻译服务
 
 @return 返回服务对象
 */
+ (GASpeechSSTService *)sharedInstance;

/**
 开始语音翻译
 
 @return 返回是否开启成功
 */
- (BOOL)startSSTToTranslation;

/**
 停止语音翻译
 */
- (void)stopSSTToTranslation;

/**
 取消语音翻译
 */
- (void)cancelSSTToTranslation;

/**
 注销语音翻译（注：在界面消失时调用）
 */
- (void)deallocToSST;

@end


#pragma mark -- 语音翻译代理
/**
 语音翻译服务代理
 */
@protocol GASpeechSSTServiceDelegate <NSObject>

/**
 音量变化回调函数
 
 @param service 语音翻译服务
 @param volume 0-30
 */
- (void)speechSSTService:(GASpeechSSTService *)service
      soundVolumeChanged:(int)volume;

/**
 开始录音回调
 
 @param service 语音翻译服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechSSTService:(GASpeechSSTService *)service
         onBeginOfSpeech:(BOOL)success;

/**
 停止录音回调
 
 @param service 语音翻译服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechSSTService:(GASpeechSSTService *)service
           onEndOfSpeech:(BOOL)success;

/**
 翻译取消回调
 
 @param service 语音翻译服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechSSTService:(GASpeechSSTService *)service
                onCancel:(BOOL)success;

/**
 翻译结束回调（注：无论翻译是否正确都会回调）
 
 @param service 语音翻译服务
 @param error 0:翻译正确 other:翻译出错
 */
- (void)speechSSTService:(GASpeechSSTService *)service
                 onError:(IFlySpeechError *)error;

/**
 翻译结果回调
 
 @param service 语音翻译服务
 @param resultDataStr 翻译结果
 */
- (void)speechSSTService:(GASpeechSSTService *)service
                onResult:(NSString *)resultDataStr;

@end












