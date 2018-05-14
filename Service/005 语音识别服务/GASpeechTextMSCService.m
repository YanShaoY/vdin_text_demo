//
//  GASpeechTextMSCService.m
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GASpeechTextMSCService.h"
// 类名声明
@class IFlyDataUploader;
@class IFlyPcmRecorder;
@class IFlySpeechRecognizer;

typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,//普通合成
    UriType             = 6, //uri合成
};


typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2, //高异常分析需要的级别
    Paused              = 4,
};

@interface GASpeechTextMSCService () <IFlySpeechRecognizerDelegate,IFlyRecognizerViewDelegate,IFlyPcmRecorderDelegate,IFlySpeechSynthesizerDelegate>

@property (nonatomic, strong) XFMSCConfiger         * configInstance;         // 语音识别配置
@property (nonatomic, strong) IFlySpeechRecognizer  * iFlySpeechRecognizer;   // 不带界面的识别对象
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property (nonatomic, strong) IFlyRecognizerView    * iflyRecognizerView;     // 带界面的识别对象
@property (nonatomic, strong) IFlyDataUploader      * uploader;               // 数据上传对象
@property (nonatomic, strong) IFlyPcmRecorder       * pcmRecorder;            // 录音器，用于音频流识别的数据传入
@property (nonatomic, assign) BOOL isStreamRec;             // 是否是音频流识别
@property (nonatomic, assign) BOOL isBeginOfSpeech;         // 是否返回BeginOfSpeech回调
@property (nonatomic, assign) BOOL isCanceled;              // 是否取消

@property (nonatomic, strong) NSString *uriPath;
@property (nonatomic, assign) Status state;
@property (nonatomic, assign) SynthesizeType synType;

/// 识别结果
@property (nonatomic, strong) NSMutableString * resultStr;

@end

@implementation GASpeechTextMSCService

#pragma mark -- 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [IFlySetting setLogFile:LVL_LOW];
        [IFlySetting showLogcat:YES];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        [IFlySetting setLogFilePath:cachePath];
        
        self.uploader = [[IFlyDataUploader alloc] init];
        self.configInstance = [[XFMSCConfiger alloc]init];
        self.resultStr = [[NSMutableString alloc]init];
    }
    return self;
}

#pragma mark -- 设置语音服务的APPID
+ (void)setMSCWithAPPId:(NSString *)appid{
    
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",appid];
    [IFlySpeechUtility createUtility:initString];
}

#pragma mark -- 启动听写
- (BOOL)startToASR{
    
    BOOL ret = NO;
    if (self.configInstance.haveView == NO) {
        
        self.isCanceled = NO;
        self.isStreamRec = NO;
        
        if(_iFlySpeechRecognizer == nil){
            [self initRecognizerWithConfig:self.configInstance];
        }
        
        [_iFlySpeechRecognizer cancel];
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        [_iFlySpeechRecognizer setDelegate:self];
        
        ret = [_iFlySpeechRecognizer startListening];
        
    }else {
        
        if(_iflyRecognizerView == nil){
            [self initRecognizerWithConfig:self.configInstance ];
        }
        [_iflyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
        [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        ret = [_iflyRecognizerView start];
    }
    
    return ret;
}

#pragma mark -- 停止听写
- (void)stopToASR{
    
    if(self.isStreamRec && !self.isBeginOfSpeech){
        [_pcmRecorder stop];
    }
    [_iFlySpeechRecognizer stopListening];
    
}

#pragma mark -- 取消听写
- (void)cancelToASR{
    
    if(self.isStreamRec && !self.isBeginOfSpeech){
        [_pcmRecorder stop];
    }
    
    self.isCanceled = YES;
    [_iFlySpeechRecognizer cancel];
    
}

#pragma mark -- 上传联系人
- (void)upContactDataWithBlock:(void(^)(NSString *result, IFlySpeechError *error))block{
    
    [_iFlySpeechRecognizer stopListening];
    
    IFlyContact * iFlyContact = [[IFlyContact alloc] init];
    NSString *contact = [iFlyContact contact];
    
    [_uploader setParameter:@"uup" forKey:[IFlySpeechConstant SUBJECT]];
    [_uploader setParameter:@"contact" forKey:[IFlySpeechConstant DATA_TYPE]];
    
    [_uploader uploadDataWithCompletionHandler:^(NSString *result, IFlySpeechError *error) {
        if ([error errorCode] == 0) {
            block(contact,error);
        }else{
            block(result,error);
        }
        
    } name:@"contact" data:contact];
    
}

#pragma mark -- 上传用户词表
- (void)upUserWordDataWithJson:(NSString *)userWords Block:(void(^)(NSString *result, IFlySpeechError *error))block{
    
    [_iFlySpeechRecognizer stopListening];
    IFlyUserWords *iFlyUserWords = [[IFlyUserWords alloc]initWithJson:userWords ];
    
    [_uploader setParameter:@"uup" forKey:[IFlySpeechConstant SUBJECT]];
    [_uploader setParameter:@"userword" forKey:[IFlySpeechConstant DATA_TYPE]];
    
    [_uploader uploadDataWithCompletionHandler:^(NSString *result, IFlySpeechError *error) {
        if ([error errorCode] == 0) {
            block([iFlyUserWords toString],error);
        }else{
            block(result,error);
        }
        
    } name:@"userwords" data:[iFlyUserWords toString]];
}

#pragma mark -- 音频流识别启动
- (BOOL)audioStreamStart{
    
    self.isStreamRec = YES;
    self.isBeginOfSpeech = NO;
    
    if (self.configInstance.haveView == YES) {
        return NO;
    }
    
    if(_iFlySpeechRecognizer == nil){
        [self initRecognizerWithConfig:self.configInstance];
    }
    
    [_iFlySpeechRecognizer setDelegate:self];
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];
    
    BOOL ret  = [_iFlySpeechRecognizer startListening];
    if (ret) {
        
        self.isCanceled = NO;
        [IFlyAudioSession initRecordingAudioSession];
        _pcmRecorder.delegate = self;
        ret = [_pcmRecorder start];
    }
    return ret;
}

#pragma mark - IFlySpeechRecognizerDelegate
- (void)onVolumeChanged:(int)volume{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onVolumeChanged:)]) {
        [self.delegate onVolumeChanged:volume];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onBeginOfSpeech{
    
    self.resultStr = [[NSMutableString alloc]init];

    if (self.isStreamRec == NO){
        self.isBeginOfSpeech = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBeginOfSpeech)]) {
        [self.delegate onBeginOfSpeech];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onEndOfSpeech{
    self.resultStr = [[NSMutableString alloc]init];

    [_pcmRecorder stop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEndOfSpeech)]) {
        [self.delegate onEndOfSpeech];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onCancel{
    self.resultStr = [[NSMutableString alloc]init];

    if (self.delegate && [self.delegate respondsToSelector:@selector(onCancel)]) {
        [self.delegate onCancel];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onError:(IFlySpeechError *)error{
    self.resultStr = [[NSMutableString alloc]init];

    if (self.delegate && [self.delegate respondsToSelector:@selector(onError:)]) {
        [self.delegate onError:error];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onResults:(NSArray *)results isLast:(BOOL)isLast{
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSString * resultFromJson = [ISRDataHelper stringFromJson:resultString];
    [self.resultStr appendString:resultFromJson];
    
    if (isLast) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onResult:)]) {
            [self.delegate onResult:self.resultStr];
            self.resultStr = [[NSMutableString alloc]init];
        }else{
            NSLog(@"%s-通用服务实现了这个代理",__func__);
        }
    }
}

- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast{
    
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];

    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    [self.resultStr appendString:result];

    if (isLast) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onResult:)]) {
            [self.delegate onResult:self.resultStr];
            self.resultStr = [[NSMutableString alloc]init];
        }else{
            NSLog(@"%s-通用服务实现了这个代理",__func__);
        }
    }
}

#pragma mark -- IFlyPcmRecorderDelegate
- (void)onIFlyRecorderBuffer:(const void *)buffer bufferSize:(int)size{
    
    NSData *audioBuffer = [NSData dataWithBytes:buffer length:size];
    int ret = [self.iFlySpeechRecognizer writeAudio:audioBuffer];
    
    if (!ret){
        [self.iFlySpeechRecognizer stopListening];
    }
    
}

- (void)onIFlyRecorderError:(IFlyPcmRecorder *)recoder theError:(int)error{
    
}

- (void)onIFlyRecorderVolumeChanged:(int)power{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onVolumeChanged:)]) {
        [self.delegate onVolumeChanged:power];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

#pragma mark -- 设置识别参数
-(void)initRecognizerWithConfig:(XFMSCConfiger *)instance{
    
    if (instance) {
        self.configInstance = instance;
    }
    
    if (self.configInstance.haveView == NO) {
        
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        _iFlySpeechRecognizer.delegate = self;
        
        if (_iFlySpeechRecognizer != nil) {
            
            [_iFlySpeechRecognizer setParameter:self.configInstance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            [_iFlySpeechRecognizer setParameter:self.configInstance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            [_iFlySpeechRecognizer setParameter:self.configInstance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            [_iFlySpeechRecognizer setParameter:self.configInstance.netWorkWait forKey:[IFlySpeechConstant NET_TIMEOUT]];
            [_iFlySpeechRecognizer setParameter:self.configInstance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            [_iFlySpeechRecognizer setParameter:self.configInstance.language forKey:[IFlySpeechConstant LANGUAGE]];
            [_iFlySpeechRecognizer setParameter:self.configInstance.accent forKey:[IFlySpeechConstant ACCENT]];
            [_iFlySpeechRecognizer setParameter:self.configInstance.dot forKey:[IFlySpeechConstant ASR_PTT]];
        }
        
        if (_pcmRecorder == nil){
            _pcmRecorder = [IFlyPcmRecorder sharedInstance];
        }
        _pcmRecorder.delegate = self;
        [_pcmRecorder setSample:self.configInstance.sampleRate];
        [_pcmRecorder setSaveAudioPath:nil];
        
    }
    else{

        if (_iflyRecognizerView == nil) {
            
            UIWindow * window = [UIApplication sharedApplication].keyWindow;
            _iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:window.center];
            [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];

        }
        _iflyRecognizerView.delegate = self;

        if (_iflyRecognizerView != nil) {
            
            [_iflyRecognizerView setParameter:self.configInstance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            [_iflyRecognizerView setParameter:self.configInstance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            [_iflyRecognizerView setParameter:self.configInstance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            [_iflyRecognizerView setParameter:self.configInstance.netWorkWait forKey:[IFlySpeechConstant NET_TIMEOUT]];
            [_iflyRecognizerView setParameter:self.configInstance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            if ([instance.language isEqualToString:self.configInstance.chinese]) {
                
                [_iflyRecognizerView setParameter:self.configInstance.language forKey:[IFlySpeechConstant LANGUAGE]];
                [_iflyRecognizerView setParameter:self.configInstance.accent forKey:[IFlySpeechConstant ACCENT]];
                
            }else if ([instance.language isEqualToString:self.configInstance.english]) {
                [_iflyRecognizerView setParameter:self.configInstance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            [_iflyRecognizerView setParameter:self.configInstance.dot forKey:[IFlySpeechConstant ASR_PTT]];

        }
    }
}

- (void)dealloc{
    
    [self deallocToASR];
}

#pragma mark -- 注销识别
- (void)deallocToASR{
    
    if (self.configInstance.haveView == NO) {
        
        [_iFlySpeechRecognizer cancel];
        [_iFlySpeechRecognizer setDelegate:nil];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        [_pcmRecorder stop];
        _pcmRecorder.delegate = nil;
        
    }else{
        
        [_iflyRecognizerView cancel];
        [_iflyRecognizerView setDelegate:nil];
        [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    }
}

@end












