//
//  GASpeechiOSService.m
//  Demo
//
//  Created by YanSY on 2018/6/6.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GASpeechiOSService.h"
#import <Speech/Speech.h>

@interface GASpeechiOSService ()<SFSpeechRecognitionTaskDelegate,SFSpeechRecognizerDelegate>

/// 声音处理器
@property (nonatomic, strong) AVAudioEngine                         * audioEngine;
/// 语音识别服务请求任务类
@property (nonatomic ,strong) SFSpeechRecognizer                    * speechRecognizer;
/// 语音识别请求对象
@property (strong, nonatomic) SFSpeechAudioBufferRecognitionRequest * speechRequest;
/// 当前语音识别进程
@property (nonatomic ,strong) SFSpeechRecognitionTask               * recognitionTask;




@end

@implementation GASpeechiOSService

#pragma mark -- 初始化
+ (GASpeechiOSService *)sharedInstance{
    GASpeechiOSService * service = [[GASpeechiOSService alloc]init];
    return service;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self configuration];
    }
    return self;
}


#pragma mark -- 设置基础配置
- (void)configuration{

    self.baseConfig = [[GAiOSConfiger alloc]init];
    [self requestUserAuthorization];
}

- (void)setBaseConfig:(GAiOSConfiger *)baseConfig{
    _baseConfig = baseConfig;
    [self initRecognizer];
}

/// 001 获取用户权限
- (void)requestUserAuthorization{
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                NSLog(@"没有授权语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                NSLog(@"用户被拒绝访问语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                NSLog(@"不能在该设备上进行语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                NSLog(@"可以语音识别");
                break;
            default:
                break;
        }
    }];
    


}

//停止录音
- (void)stopRecording{
    //    [self.recognitionRequest endAudio];
    // 停止声音处理器，停止语音识别请求进程
    [self.audioEngine stop];
    [self.speechRequest endAudio];
}

//开始录音
-(void)startRecording{
    
    // 001 判断权限
    switch ([SFSpeechRecognizer authorizationStatus]) {
            
        case SFSpeechRecognizerAuthorizationStatusNotDetermined:
            NSLog(@"01没有授权语音识别");
            break;
        case SFSpeechRecognizerAuthorizationStatusDenied:
            NSLog(@"01用户被拒绝访问语音识别");
            break;
        case SFSpeechRecognizerAuthorizationStatusRestricted:
            NSLog(@"01不能在该设备上进行语音识别");
            break;
        case SFSpeechRecognizerAuthorizationStatusAuthorized:
            NSLog(@"01可以语音识别");
            break;
        default:
            break;
    }
    
    if (self.recognitionTask.state == SFSpeechRecognitionTaskStateRunning)
    {   // 如果当前进程状态是进行中
        
        // 停止语音识别
    }
    else
    {   // 进程状态不在进行中
        // 开启语音识别
    }
    
    NSError *error;
    // 启动声音处理器
    [self.audioEngine startAndReturnError: &error];
    // 初始化
    self.speechRequest = [SFSpeechAudioBufferRecognitionRequest new];
    // 使用speechRequest请求进行识别
    self.recognitionTask =
    [self.speechRecognizer recognitionTaskWithRequest:self.speechRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result,NSError * _Nullable error)
     {
         // 识别结果，识别后的操作
         if (result == NULL) return;
     }];
    
    //3.开始识别任务
    //    self.recognitionTask = [self recognitionTaskWithRequest1:request];
    
}

#pragma mark -- 初始化语音识别对象
- (void)initRecognizer{
    if (!self.baseConfig) {
        self.baseConfig = [[GAiOSConfiger alloc]init];
    }
    
    NSString * localeIdentifier = [self.baseConfig foundLanguageKeyForName:self.baseConfig.language];
    NSLocale * locale           = [[NSLocale alloc]initWithLocaleIdentifier:localeIdentifier];
    NSSet    * localeSet        =  [SFSpeechRecognizer supportedLocales];

    if (!self.speechRecognizer && [localeSet containsObject:locale]) {
        self.speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:locale];
    }
    
    if (self.speechRecognizer) {
        
        if (![self.speechRecognizer.locale isEqual:locale] && [localeSet containsObject:locale]) {
            self.speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:locale];
        }
        
        self.speechRecognizer.delegate = self;
        self.audioEngine = [[AVAudioEngine alloc]init];
        // 初始化语音处理器的输入模式
        [self.audioEngine.inputNode installTapOnBus:0 bufferSize:1024 format:[self.audioEngine.inputNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
            // 为语音识别请求对象添加一个AudioPCMBuffer，来获取声音数据
            [self.speechRequest appendAudioPCMBuffer:buffer];
        }];
        // 语音处理器准备就绪（会为一些audioEngine启动时所必须的资源开辟内存）
        [self.audioEngine prepare];
        
    }
    
    
}


#pragma mark -- 懒加载



- (void)dealloc{
    [self.recognitionTask cancel];
    self.recognitionTask = nil;
}

@end
















