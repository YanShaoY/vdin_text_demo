//
//  GASpeechTextMSCService.h
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFlyMSC/IFlyMSC.h"
#import <QuartzCore/QuartzCore.h>
#import "Definition.h"
#import "ISRDataHelper.h"
#import "IATConfig.h"

@protocol GASpeechTextMSCServiceDelegate <NSObject>

@required

/**
 听写结束回调（注：无论听写是否正确都会回调）
 
 @param error 0:听写正确 other:听写出错
 */
- (void)onError:(IFlySpeechError *)error;

/**
 听写结果回调
 
 @param resultStr 听写结果
 */
- (void)onResult:(NSString *)resultStr;

@optional

/**
 音量回调函数
 
 @param volume 0-30
 */
- (void)onVolumeChanged:(int)volume;

/**
 开始识别回调
 */
- (void)onBeginOfSpeech;

/**
 停止录音回调
 */
- (void)onEndOfSpeech;

/**
 听写取消回调
 */
- (void)onCancel;


@end

/**
 语音文字识别服务
 */
@interface GASpeechTextMSCService : NSObject

/*!
 *  设置委托对象
 */
@property(nonatomic,assign) id<GASpeechTextMSCServiceDelegate> delegate;

#pragma mark -- 设置注册APPID，服务启动前必须注册
/**
 设置语音服务的APPID

 @param appid 语音注册APP的ID
 */
+ (void)setMSCWithAPPId:(NSString *)appid;

#pragma mark -- 创建语音识别

/**
 初始化语音是识别参数（注：一般在参数变化后设置）

 @param instance 语音识别配置参数 nil:默认
 */
-(void)initRecognizerWithConfig:(IATConfig *)instance;

/**
 开始语音识别

 @return 返回是否开启成功
 */
- (BOOL)startToASR;

/**
 停止语音识别
 */
- (void)stopToASR;

/**
 取消语音识别
 */
- (void)cancelToASR;

/**
 启动音频流识别

 @return 返回启动状态
 */
- (BOOL)audioStreamStart;

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




















