//
//  GASpeechTTSService.m
//  Demo
//
//  Created by YanSY on 2018/5/16.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GASpeechTTSService.h"

// 类名声明
@class IFlySpeechSynthesizer;

@interface GASpeechTTSService ()<IFlySpeechSynthesizerDelegate>

/// 语音合成对象
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
/// 语音播放对象
@property (nonatomic, strong) GAXFMscPcmPlayer * audioPlayer;

/// 当前合成类型
@property (nonatomic, assign) SynthesizeType synType;
/// 当前合成状态
@property (nonatomic, assign) Status state;
/// 是否取消
@property (nonatomic, assign) BOOL isCanceled;
/// 是否包含错误
@property (nonatomic, assign) BOOL hasError;

@end

@implementation GASpeechTTSService

#pragma mark -- 初始化
/**
 初始化语音合成服务
 
 @return 返回服务对象
 */
+ (GASpeechTTSService *)sharedInstance{
    GASpeechTTSService * service = [[GASpeechTTSService alloc]init];
    return  service;
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
    
    self.baseConfig = [[GATTSConfiger alloc]init];
    self.audioPlayer = [[GAXFMscPcmPlayer alloc]init];
}

- (void)setBaseConfig:(GATTSConfiger *)baseConfig{
    _baseConfig = baseConfig;
    [self initRecognizer];
}

#pragma mark -- 开始通用语音合成
- (BOOL)startTTSToNormalSpeaking:(NSString *)speakStr{
    
    BOOL ret = NO;
    if ([speakStr isEqualToString:@""]) {
        return ret;
    }
    
    if (_iFlySpeechSynthesizer == nil) {
        [self initRecognizer];
    }
    
    if (_audioPlayer != nil && _audioPlayer.isPlaying == YES) {
        [_audioPlayer stop];
    }
    
    _synType = NomalType;
    self.hasError = NO;
    [NSThread sleepForTimeInterval:0.05];
    
    self.isCanceled = NO;
    _iFlySpeechSynthesizer.delegate = self;
    
    [_iFlySpeechSynthesizer startSpeaking:speakStr];
    if (_iFlySpeechSynthesizer.isSpeaking) {
        _state = Playing;
        ret = YES;
    }
    return ret;
}
#pragma mark -- 开始URL语音合成
- (BOOL)startTTSToURLSpeaking:(NSString *)speakStr{
    
    BOOL ret = NO;
    if ([speakStr isEqualToString:@""]) {
        return ret;
    }
    
    if (_iFlySpeechSynthesizer == nil) {
        [self initRecognizer];
    }
    
    if (_audioPlayer != nil && _audioPlayer.isPlaying == YES) {
        [_audioPlayer stop];
    }
    
    _synType = UriType;
    
    self.hasError = NO;
    
    [NSThread sleepForTimeInterval:0.05];
    
    self.isCanceled = NO;
    _iFlySpeechSynthesizer.delegate = self;
    
    [_iFlySpeechSynthesizer synthesize:speakStr toUri:self.baseConfig.uriPath];
    
    if (_iFlySpeechSynthesizer.isSpeaking) {
        _state = Playing;
        ret = YES;
    }
    return ret;
}

#pragma mark -- 取消语音合成
- (void)cancelTTSToSpeaking{
    [_iFlySpeechSynthesizer stopSpeaking];
}

#pragma mark -- 恢复播放
- (void)resumeTTSToSpeaking{
    [_iFlySpeechSynthesizer resumeSpeaking];
}

#pragma mark -- 暂停播放
- (void)pauseTTSToSpeaking{
    [_iFlySpeechSynthesizer pauseSpeaking];
}

#pragma mark -- 注销语音合成（注：在界面消失时调用）
- (void)deallocToTTS{
    
    [_iFlySpeechSynthesizer stopSpeaking];
    [_audioPlayer stop];
    _iFlySpeechSynthesizer.delegate = nil;
}

#pragma mark -- 合成回调 IFlySpeechSynthesizerDelegate
- (void)onSpeakBegin{
    
    self.isCanceled = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechTTSService:onSpeakBegin:)]) {
        [self.delegate speechTTSService:self onSpeakBegin:YES];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
    _state = Playing;

}

- (void)onSpeakCancel{
    
    self.isCanceled = YES;

    if (self.delegate && [self.delegate respondsToSelector:@selector(speechTTSService:onSpeakCancel:)]) {
        [self.delegate speechTTSService:self onSpeakCancel:YES];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
    _state = NotStart;
    
}

- (void)onSpeakPaused{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechTTSService:onSpeakPaused:)]) {
        [self.delegate speechTTSService:self onSpeakPaused:YES];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
    _state = Paused;
}

- (void)onSpeakResumed{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechTTSService:onSpeakResumed:)]) {
        [self.delegate speechTTSService:self onSpeakResumed:YES];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
    _state = Playing;
}

- (void)onBufferProgress:(int)progress message:(NSString *)msg{
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechTTSService:onBufferProgress:message:)]) {
        [self.delegate speechTTSService:self onBufferProgress:progress message:msg];
    }
}

- (void)onSpeakProgress:(int)progress beginPos:(int)beginPos endPos:(int)endPos{
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechTTSService:onSpeakProgress:beginPos:endPos:)]) {
        [self.delegate speechTTSService:self onSpeakProgress:progress beginPos:beginPos endPos:endPos];
    }
}

- (void)onCompleted:(IFlySpeechError *)error{
    
    if (!self.isCanceled && error.errorCode != 0) {
        self.hasError = YES;
    }
    _state = NotStart;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechTTSService:onCompleted:)]) {
        [self.delegate speechTTSService:self onCompleted:error];
    }
    
    if (_synType == UriType && self.baseConfig.autoPlayURL) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:self.baseConfig.uriPath]) {
            [self playUriAudio];
        }
    }
}

#pragma mark - 播放uri合成音频
- (void)playUriAudio{
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    _audioPlayer = [[GAXFMscPcmPlayer alloc] initWithFilePath:self.baseConfig.uriPath sampleRate:[self.baseConfig.sampleRate integerValue]];
    [_audioPlayer play];
    
}

#pragma mark -- 初始化语音合成对象
- (void)initRecognizer{
    
    if (!self.baseConfig) {
        self.baseConfig = [[GATTSConfiger alloc]init];
    }
    
    if (_iFlySpeechSynthesizer == nil) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    _iFlySpeechSynthesizer.delegate = self;
    
    [[IFlySpeechUtility getUtility] setParameter:@"tts" forKey:[IFlyResourceUtil ENGINE_START]];
    
    NSString * resPath    = [[NSBundle mainBundle] resourcePath];
    NSString * newResPath = [[NSString alloc] initWithFormat:@"%@/tts64res/common.jet;%@/tts64res/xiaoyan.jet",resPath,resPath];
    
    [_iFlySpeechSynthesizer setParameter:newResPath forKey:@"tts_res_path"];
    [_iFlySpeechSynthesizer setParameter:self.baseConfig.speed forKey:[IFlySpeechConstant SPEED]];
    [_iFlySpeechSynthesizer setParameter:self.baseConfig.volume forKey:[IFlySpeechConstant VOLUME]];
    [_iFlySpeechSynthesizer setParameter:self.baseConfig.pitch forKey:[IFlySpeechConstant PITCH]];
    [_iFlySpeechSynthesizer setParameter:self.baseConfig.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    [_iFlySpeechSynthesizer setParameter:self.baseConfig.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    [_iFlySpeechSynthesizer setParameter:self.baseConfig.textEnCoding forKey:[IFlySpeechConstant TEXT_ENCODING]];
    [_iFlySpeechSynthesizer setParameter:self.baseConfig.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
    [_iFlySpeechSynthesizer setParameter:nil forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
}

- (void)dealloc{
    [self deallocToTTS];
}



@end












