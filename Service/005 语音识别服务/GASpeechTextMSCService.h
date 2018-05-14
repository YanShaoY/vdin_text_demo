//
//  GASpeechTextMSCService.h
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFlyMSC/IFlyMSC.h"

// 类名声明
@class IFlyDataUploader;
@class IFlyPcmRecorder;
@class IFlySpeechRecognizer;

/**
 语音文字识别服务
 */
@interface GASpeechTextMSCService : NSObject<IFlySpeechRecognizerDelegate,IFlyRecognizerViewDelegate,IFlyPcmRecorderDelegate>

@property (nonatomic, strong) NSString *pcmFilePath;                      //音频文件路径
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer; // 不带界面的识别对象
@property (nonatomic, strong) IFlyRecognizerView *iflyRecognizerView;     // 带界面的识别对象
@property (nonatomic, strong) IFlyDataUploader *uploader;                 // 数据上传对象

@property (nonatomic, strong) NSString * result;           // 结果
@property (nonatomic, assign) BOOL isCanceled;             // 是否取消

@property (nonatomic,strong) IFlyPcmRecorder *pcmRecorder; // 录音器，用于音频流识别的数据传入
@property (nonatomic,assign) BOOL isStreamRec;             // 是否是音频流识别
@property (nonatomic,assign) BOOL isBeginOfSpeech;         // 是否返回BeginOfSpeech回调


/**
 初始化语音识别服务

 @param appid 注册的APPID
 */
+ (void)initMSCServiceWithAPPId:(NSString *)appid;

@end
