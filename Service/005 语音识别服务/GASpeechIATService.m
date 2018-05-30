//
//  GASpeechIATService.m
//  Demo
//
//  Created by YanSY on 2018/5/15.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GASpeechIATService.h"

@interface GASpeechIATService ()<IFlySpeechRecognizerDelegate,IFlyRecognizerViewDelegate,IFlyPcmRecorderDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer  * iFlySpeechRecognizer;   // 不带界面的识别对象
@property (nonatomic, strong) IFlyRecognizerView    * iflyRecognizerView;     // 带界面的识别对象
@property (nonatomic, strong) IFlyDataUploader      * uploader;               // 数据上传对象
@property (nonatomic, strong) IFlyPcmRecorder       * pcmRecorder;            // 录音器，用于音频流识别的数据传入

/// 是否是音频流识别
@property (nonatomic, assign) BOOL isStreamRec;
/// 是否返回BeginOfSpeech回调
@property (nonatomic, assign) BOOL isBeginOfSpeech;
/// 是否取消
@property (nonatomic, assign) BOOL isCanceled;
/// 临时储存识别结果的数据
@property (nonatomic, strong) NSMutableString * resultDataStr;

@end

@implementation GASpeechIATService

#pragma mark -- 初始化
/**
 初始化语音识别服务
 
 @return 返回服务对象
 */
+ (GASpeechIATService *)sharedInstance{
    GASpeechIATService * service = [[GASpeechIATService alloc]init];
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

    self.uploader = [[IFlyDataUploader alloc] init];
    self.baseConfig = [[GAIATConfiger alloc]init];
    self.resultDataStr = [[NSMutableString alloc]init];
}

- (void)setBaseConfig:(GAIATConfiger *)baseConfig{
    _baseConfig = baseConfig;
    [self initRecognizer];
}

#pragma mark -- 开始语音识别
- (BOOL)startASRToListening{
    
    BOOL ret = NO;
    self.isCanceled  = NO;
    self.isStreamRec = NO;
    
    if (self.baseConfig.haveView == NO) {
        
        if (_iFlySpeechRecognizer == nil) {
            [self initRecognizer];
        }
        
        [_iFlySpeechRecognizer cancel];
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:[IFlySpeechConstant AUDIO_SOURCE]];
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        [_iFlySpeechRecognizer setParameter:nil forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        [_iFlySpeechRecognizer setDelegate:self];
        
        ret = [_iFlySpeechRecognizer startListening];
        
    }else{
        
        if (_iflyRecognizerView == nil) {
            [self initRecognizer];
        }
        
        [_iflyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:[IFlySpeechConstant AUDIO_SOURCE]];
        [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
        [_iflyRecognizerView setParameter:nil forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        [_iflyRecognizerView setDelegate:self];
        
        ret = [_iflyRecognizerView start];
    }
    
    return ret;
}

#pragma mark -- 停止语音识别
- (void)stopASRToListening{
    
    if(self.isStreamRec && !self.isBeginOfSpeech){
        [_pcmRecorder stop];
    }
    [_iFlySpeechRecognizer stopListening];
}

#pragma mark -- 取消语音识别
-(void)cancelASRToListening{
    
    if(self.isStreamRec && !self.isBeginOfSpeech){
        [_pcmRecorder stop];
    }
    
    self.isCanceled = YES;
    [_iFlySpeechRecognizer cancel];
}

#pragma mark -- 启动音频流识别
- (BOOL)startAudioStream{
    
    self.isStreamRec = YES;
    self.isBeginOfSpeech = NO;
    
    if (self.baseConfig.haveView == YES) {
        return NO;
    }
    
    if(_iFlySpeechRecognizer == nil){
        [self initRecognizer];
    }
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:[IFlySpeechConstant AUDIO_SOURCE]];
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [_iFlySpeechRecognizer setParameter:nil forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    [_iFlySpeechRecognizer setDelegate:self];
    
    BOOL ret  = [_iFlySpeechRecognizer startListening];
    if (ret) {
        self.isCanceled = NO;
        [IFlyAudioSession initRecordingAudioSession];
        _pcmRecorder.delegate = self;
        ret = [_pcmRecorder start];
    }
    return ret;
    
}

#pragma mark -- 注销语音识别（注：在界面消失时调用）
- (void)deallocToASR{
    
    if (self.baseConfig.haveView == NO) {
        
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

#pragma mark -- 上传联系人信息
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

#pragma mark -- IFlySpeechRecognizerDelegate
- (void)onVolumeChanged:(int)volume{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechIATService:soundVolumeChanged:)]) {
        [self.delegate speechIATService:self soundVolumeChanged:volume];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onBeginOfSpeech{
    
    self.resultDataStr = [[NSMutableString alloc]init];
    
    if (self.isStreamRec == NO){
        self.isBeginOfSpeech = YES;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechIATService:onBeginOfSpeech:)]) {
        [self.delegate speechIATService:self onBeginOfSpeech:YES];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onEndOfSpeech{
    
    [_pcmRecorder stop];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechIATService:onEndOfSpeech:)]) {
        [self.delegate speechIATService:self onEndOfSpeech:YES];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onCancel{

    if (self.delegate && [self.delegate respondsToSelector:@selector(speechIATService:onCancel:)]) {
        [self.delegate speechIATService:self onCancel:YES];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onError:(IFlySpeechError *)error{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechIATService:onError:)]) {
        [self.delegate speechIATService:self onError:error];
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
    NSString * resultFromJson = [GAXFMscDataHelper stringFromJson:resultString];
    [self.resultDataStr appendString:resultFromJson];
    if (isLast) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechIATService:onResult:)]) {
            [self.delegate speechIATService:self onResult:self.resultDataStr];
            self.resultDataStr = [[NSMutableString alloc]init];
        }else{
            NSLog(@"%s-通用服务实现了这个代理",__func__);
        }
    }
}

#pragma mark -- IFlyRecognizerViewDelegate
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    [self.resultDataStr appendString:result];
    
    if (isLast) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechIATService:onResult:)]) {
            [self.delegate speechIATService:self onResult:self.resultDataStr];
            self.resultDataStr = [[NSMutableString alloc]init];
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
        IFlySpeechError * onError = [IFlySpeechError initWithError:444];
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechIATService:onError:)]) {
            [self.delegate speechIATService:self onError:onError];
        }else{
            NSLog(@"%s-通用服务实现了这个代理",__func__);
        }
    }
}

- (void)onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error{
    
    self.resultDataStr = [[NSMutableString alloc]init];
    
    IFlySpeechError * onError = [IFlySpeechError initWithError:error];
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechIATService:onError:)]) {
        [self.delegate speechIATService:self onError:onError];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onIFlyRecorderVolumeChanged:(int)power{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechIATService:soundVolumeChanged:)]) {
        [self.delegate speechIATService:self soundVolumeChanged:power];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

#pragma mark -- 初始化语音识别对象
- (void)initRecognizer{
    
    if (!self.baseConfig) {
        self.baseConfig = [[GAIATConfiger alloc]init];
    }
    
    if (self.baseConfig.haveView == NO) {
        
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        
        _iFlySpeechRecognizer.delegate = self;

        if (_iFlySpeechRecognizer != nil) {
            [_iFlySpeechRecognizer setParameter:self.baseConfig.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.netWorkWait forKey:[IFlySpeechConstant NET_TIMEOUT]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.language forKey:[IFlySpeechConstant LANGUAGE]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.accent forKey:[IFlySpeechConstant ACCENT]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.dot forKey:[IFlySpeechConstant ASR_PTT]];
        }
        
        if (_pcmRecorder == nil){
            _pcmRecorder = [IFlyPcmRecorder sharedInstance];
        }
        _pcmRecorder.delegate = self;
        [_pcmRecorder setSample:self.baseConfig.sampleRate];
        [_pcmRecorder setSaveAudioPath:nil];
        
    }else{
        
        if (_iflyRecognizerView == nil) {
            UIWindow * window = [UIApplication sharedApplication].keyWindow;
            _iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:window.center];
            [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        
        _iflyRecognizerView.delegate = self;

        if (_iflyRecognizerView != nil) {
            
            [_iflyRecognizerView setParameter:self.baseConfig.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            [_iflyRecognizerView setParameter:self.baseConfig.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            [_iflyRecognizerView setParameter:self.baseConfig.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            [_iflyRecognizerView setParameter:self.baseConfig.netWorkWait forKey:[IFlySpeechConstant NET_TIMEOUT]];
            [_iflyRecognizerView setParameter:self.baseConfig.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            if ([self.baseConfig.language isEqualToString:self.baseConfig.chinese]) {
                
                [_iflyRecognizerView setParameter:self.baseConfig.language forKey:[IFlySpeechConstant LANGUAGE]];
                [_iflyRecognizerView setParameter:self.baseConfig.accent forKey:[IFlySpeechConstant ACCENT]];
                
            }else if ([self.baseConfig.language isEqualToString:self.baseConfig.english]) {
                [_iflyRecognizerView setParameter:self.baseConfig.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            [_iflyRecognizerView setParameter:self.baseConfig.dot forKey:[IFlySpeechConstant ASR_PTT]];
            [self resetTitleLabel];
        }
        
    }
}

#pragma mark -- 重置提示标题文字及点击事件
- (void)resetTitleLabel{
    for (UIView * view in _iflyRecognizerView.subviews) {
        if ([view isKindOfClass:[NSClassFromString(@"IFlyRecognizerViewImp") class]]) {
            
            for (UIView * subView in view.subviews) {
                if ([subView isKindOfClass:[UILabel class]]) {
                    UILabel * label = (UILabel *)subView;
                    if ([label.text isEqualToString:@"语音识别能力由讯飞输入法提供"]) {
                        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"语音识别能力由中德宏泰提供"];
                        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, str.length)];

                        [label setAttributedText:str];
                        UIView * tapView = [[UIView alloc]initWithFrame:label.frame];
                        tapView.backgroundColor = [UIColor clearColor];
                        [label.superview addSubview:tapView];
                        [label.superview bringSubviewToFront:tapView];
                        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchIdBegin)];
                        tap.numberOfTapsRequired = 1;
                        [tapView addGestureRecognizer:tap];
                    }
                }
                
            }
            
        }
    }
    
}

- (void)touchIdBegin{

    NSURL * VdinRrl = [NSURL URLWithString:@"http://www.vdin.com.cn/"];
    if ([[UIApplication sharedApplication]canOpenURL:VdinRrl]) {
        [[UIApplication sharedApplication]openURL:VdinRrl];
    }
}

- (void)dealloc{
    [self deallocToASR];
}

@end


















