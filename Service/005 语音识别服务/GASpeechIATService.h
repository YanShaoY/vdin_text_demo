//
//  GASpeechIATService.h
//  Demo
//
//  Created by YanSY on 2018/5/15.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IFlyMSC/IFlyMSC.h"
#import "GAIATConfiger.h"
#import "GAXFMscDataHelper.h"

#pragma mark -- 语音识别服务
@protocol GASpeechIATServiceDelegate;

/**
 语音识别服务
 */
@interface GASpeechIATService : NSObject

#pragma mark -- 语音识别服务代理及配置对象
/// 设置委托对象
@property (nonatomic ,assign) id<GASpeechIATServiceDelegate> delegate;
/// 语音识别配置（注：若需更改原始配置，请设置。 默认原始配置）
@property (nonatomic, strong) GAIATConfiger         * baseConfig;

#pragma mark -- 语音识别服务状态获取方法
/// 是否是音频流识别
- (BOOL)isStreamRec;
/// 是否返回BeginOfSpeech回调
- (BOOL)isBeginOfSpeech;
/// 是否取消
- (BOOL)isCanceled;

#pragma mark -- 语音识别服务公共方法
/**
 初始化语音识别服务
 
 @return 返回服务对象
 */
+ (GASpeechIATService *)sharedInstance;

/**
 开始语音识别

 @return 返回是否开启成功
 */
- (BOOL)startASRToListening;

/**
 停止语音识别
 */
- (void)stopASRToListening;

/**
 取消语音识别
 */
- (void)cancelASRToListening;

/**
 启动音频流识别
 
 @return 返回启动状态
 */
- (BOOL)startAudioStream;

/**
 写入音频流
 注：1.在音频流识别且配置项-autoWriteAudio == No情况下写入
    2.建议分段写入，写入完成后调用- (void)stopASRToListening方法开始识别
 @param audioBuffer 音频数据
 @return 写入成功返回YES，写入失败返回NO
 */
- (BOOL)audioStreamWriteAudio:(NSData *)audioBuffer;

/**
 注销语音识别（注：在界面消失时调用）
 */
- (void)deallocToASR;

/**
 上传联系人信息
 
 @param block 上传回调
 */
- (void)upContactDataWithBlock:(void(^)(NSString *result, IFlySpeechError *error))block;

/**
 上传用户词表
 
 @param userWords 用户词表（json格式）
 @param block 上传回调
 */
- (void)upUserWordDataWithJson:(NSString *)userWords Block:(void(^)(NSString *result, IFlySpeechError *error))block;

@end



#pragma mark -- 语音识别代理
/**
 语音识别服务代理
 */
@protocol GASpeechIATServiceDelegate <NSObject>

/**
 音量变化回调函数

 @param service 语音识别服务
 @param volume 0-30
 */
- (void)speechIATService:(GASpeechIATService *)service
      soundVolumeChanged:(int)volume;

/**
 开始录音回调

 @param service 语音识别服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechIATService:(GASpeechIATService *)service
         onBeginOfSpeech:(BOOL)success;

/**
 停止录音回调
 
 @param service 语音识别服务
 @param success 是否成功 默认成功，当出现中断时返回失败
*/
- (void)speechIATService:(GASpeechIATService *)service
           onEndOfSpeech:(BOOL)success;

/**
 听写取消回调
 
 @param service 语音识别服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechIATService:(GASpeechIATService *)service
                onCancel:(BOOL)success;

/**
 听写结束回调（注：无论听写是否正确都会回调）

 @param service 语音识别服务
 @param error 0:听写正确 other:听写出错
 */
- (void)speechIATService:(GASpeechIATService *)service
                 onError:(IFlySpeechError *)error;

/**
 听写结果回调

 @param service 语音识别服务
 @param resultDataStr 听写结果
 */
- (void)speechIATService:(GASpeechIATService *)service
                onResult:(NSString *)resultDataStr;

@end












