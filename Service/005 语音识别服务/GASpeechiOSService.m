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

/// 是否是音频流识别
@property (nonatomic, assign) BOOL isStreamRec;
/// 是否返回Begin回调
@property (nonatomic, assign) BOOL isBegin;
/// 是否取消
@property (nonatomic, assign) BOOL isCanceled;
/// 临时储存识别结果的数据
@property (nonatomic, strong) NSMutableString * resultDataStr;


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

    [self requestUserAuthorization];
    
    self.baseConfig = [[GAiOSConfiger alloc]init];
}

- (void)setBaseConfig:(GAiOSConfiger *)baseConfig{
    _baseConfig = baseConfig;
    [self initRecognizer];
}

/// 001 获取用户权限
- (void)requestUserAuthorization{
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        NSLog(@"%s---当前授权状态为:%ld",__FUNCTION__,status);
    }];
    
}

#pragma mark -- 开始语音识别
- (BOOL)startiOSToListening{

    BOOL ret = NO;
    self.isCanceled  = NO;
    self.isStreamRec = NO;
    
    // 001 判断权限
    NSString * reasonLog;
    switch ([SFSpeechRecognizer authorizationStatus]) {
            
        case SFSpeechRecognizerAuthorizationStatusNotDetermined:
            reasonLog = @"用户尚未对APP的语音识别权限进行授权";
            break;
            
        case SFSpeechRecognizerAuthorizationStatusDenied:
            reasonLog = @"语音识别服务权限被用户禁止";
            break;
            
        case SFSpeechRecognizerAuthorizationStatusRestricted:
            reasonLog = @"语音识别授权信息收到限制，请查看设置";
            break;
            
        case SFSpeechRecognizerAuthorizationStatusAuthorized:
            ret = YES;
            break;
            
        default:
            break;
    }
    
    if (reasonLog.length > 0 && ret == NO) {
        [self delegateToErrorWithCode:Error_Code_Author
                       andDescription:@"Speech_Permissions_Error"
                     andFailureReason:reasonLog];
        return ret;
    }
    
    if (self.recognitionTask.state == SFSpeechRecognitionTaskStateRunning){
        
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    ret = [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    NSParameterAssert(!error);
    ret = [audioSession setMode:AVAudioSessionModeMeasurement error:&error];
    NSParameterAssert(!error);
    ret = [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    NSParameterAssert(!error);
    
    self.speechRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];

    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    NSAssert(inputNode, @"录入设备没有准备好");
    NSAssert(_speechRequest, @"请求初始化失败");
    
    if (self.baseConfig.isReportPartialResults) {
        self.speechRequest.shouldReportPartialResults = YES;
    }else{
        self.speechRequest.shouldReportPartialResults = NO;
    }

    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.speechRequest delegate:self];
    
    AVAudioFormat * recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode removeTapOnBus:0];

    @weakify(self);
    [self.audioEngine.inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        @strongify(self);
        if (self.speechRequest) {
            [self.speechRequest appendAudioPCMBuffer:buffer];
        }
    }];
    [self.audioEngine prepare];
    
    ret = [self.audioEngine startAndReturnError: &error];
    NSParameterAssert(!error);

    return ret;
}

#pragma mark -- 停止语音识别
- (void)stopiOSToListening{
    
    self.isBegin = NO;
    self.isCanceled = YES;
    
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
    }
    
    if (self.speechRequest) {
        [self.speechRequest endAudio];
    }
    
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
}

#pragma mark -- 识别本地音频文件
- (BOOL)startLocalAudioStreamWithUrl:(NSURL *)url{
    
    BOOL ret = NO;
    self.isStreamRec = YES;
    self.isCanceled  = NO;
    
    if (!url) {
        return ret;
    }
    
    if (!self.speechRecognizer) {
        [self initRecognizer];
    }
    
    SFSpeechURLRecognitionRequest * res =[[SFSpeechURLRecognitionRequest alloc]initWithURL:url];
    [self.speechRecognizer recognitionTaskWithRequest:res delegate:self];
    
    return YES;
}
#pragma mark -- SFSpeechRecognizerDelegate
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark -- SFSpeechRecognitionTaskDelegate
/// 当任务首先检测到源音频中的语音时调用
- (void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task{
    NSLog(@"%s",__FUNCTION__);
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription{
    NSLog(@"%s",__FUNCTION__);
}

// 解析结果回调
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult{
    NSLog(@"%s",__FUNCTION__);
}

// 未接收到音频时回调
- (void)speechRecognitionTaskFinishedReadingAudio:(SFSpeechRecognitionTask *)task{
    NSLog(@"%s",__FUNCTION__);
}

// 任务取消时回调
- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task{
    NSLog(@"%s",__FUNCTION__);
}

// 当所有被请求的话语都被识别完毕时，调用。
// 如果成功为false，则任务的error属性将包含错误信息
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully{
    NSLog(@"%s",__FUNCTION__);
    if (successfully) {
        // 返回存储的结果字符串 TODO
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechiOSService:onError:)]) {
            [self.delegate speechiOSService:self onError:task.error];
        }
    }
    
    self.isBegin = NO;
    self.isCanceled = YES;

    [self.audioEngine stop];
    [self.audioEngine.inputNode removeTapOnBus:0];
    self.recognitionTask = nil;
    self.speechRequest = nil;
}

#pragma mark -- 写入音频流识别的音频数据
- (BOOL)audioStreamWriteAudio:(NSData *)audioBuffer{
    BOOL ret = NO;

    return ret;
}

#pragma mark -- 注销语音识别（注：在界面消失时调用）
- (void)deallocToiOS{
    [self.recognitionTask cancel];
    self.recognitionTask = nil;
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
    }
    
    
}


#pragma mark -- Tool方法

- (void)delegateToErrorWithCode:(SpeechiOS_Error_Code)errorCode
                 andDescription:(NSString *)description
               andFailureReason:(NSString *)reason{
    NSString *const ibeaconErrorDomain = [NSString stringWithFormat:@"%@ErrorDomain",NSStringFromClass(self.class)];
    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:description forKey:NSLocalizedDescriptionKey];
    [userInfo setValue:reason forKey:NSLocalizedFailureReasonErrorKey];
    NSError * error = [NSError errorWithDomain:ibeaconErrorDomain code:errorCode userInfo:userInfo];
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechiOSService:onError:)]) {
        [self.delegate speechiOSService:self onError:error];
    }
}

#pragma mark -- 懒加载
- (AVAudioEngine *)audioEngine{
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    return _audioEngine;
}



- (void)dealloc{
    [self.recognitionTask cancel];
    self.recognitionTask = nil;
}

@end
















