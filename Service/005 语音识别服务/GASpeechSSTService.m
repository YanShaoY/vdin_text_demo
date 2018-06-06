//
//  GASpeechSSTService.m
//  Demo
//
//  Created by YanSY on 2018/5/30.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GASpeechSSTService.h"

@interface GASpeechSSTService ()<IFlySpeechRecognizerDelegate,IFlyRecognizerViewDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer  * iFlySpeechRecognizer;   // 不带界面的翻译对象
@property (nonatomic, strong) IFlyRecognizerView    * iflyRecognizerView;     // 带界面的翻译对象

/// 是否取消
@property (nonatomic, assign) BOOL isCanceled;
/// 临时储存翻译结果的数据
@property (nonatomic, strong) NSMutableString * resultDataStr;

@end

@implementation GASpeechSSTService

#pragma mark -- 初始化
/**
 初始化语音翻译服务
 
 @return 返回服务对象
 */
+ (GASpeechSSTService *)sharedInstance{
    GASpeechSSTService * service = [[GASpeechSSTService alloc]init];
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
    
    self.baseConfig = [[GASSTConfiger alloc]init];
    self.resultDataStr = [[NSMutableString alloc]init];
}

- (void)setBaseConfig:(GASSTConfiger *)baseConfig{
    _baseConfig = baseConfig;
    [self initRecognizer];
}

#pragma mark -- 开始语音翻译
- (BOOL)startSSTToTranslation{
    
    BOOL ret = NO;
    self.isCanceled  = NO;
    
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

#pragma mark -- 停止语音翻译
- (void)stopSSTToTranslation{
    [_iFlySpeechRecognizer stopListening];
}

#pragma mark -- 取消语音翻译
-(void)cancelSSTToTranslation{
    self.isCanceled = YES;
    [_iFlySpeechRecognizer cancel];
}

#pragma mark -- 注销语音翻译（注：在界面消失时调用）
- (void)deallocToSST{
    
    if (self.baseConfig.haveView == NO) {
        
        [_iFlySpeechRecognizer cancel];
        [_iFlySpeechRecognizer setDelegate:nil];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
    }else{
        
        [_iflyRecognizerView cancel];
        [_iflyRecognizerView setDelegate:nil];
        [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    }
}

#pragma mark -- IFlySpeechRecognizerDelegate
- (void)onVolumeChanged:(int)volume{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechSSTService:soundVolumeChanged:)]) {
        [self.delegate speechSSTService:self soundVolumeChanged:volume];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onBeginOfSpeech{
    
    self.resultDataStr = [[NSMutableString alloc]init];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechSSTService:onBeginOfSpeech:)]) {
        [self.delegate speechSSTService:self onBeginOfSpeech:YES];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onEndOfSpeech{
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechSSTService:onEndOfSpeech:)]) {
        [self.delegate speechSSTService:self onEndOfSpeech:YES];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onCancel{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechSSTService:onCancel:)]) {
        [self.delegate speechSSTService:self onCancel:YES];
    }else{
        NSLog(@"%s-通用服务实现了这个代理",__func__);
    }
}

- (void)onError:(IFlySpeechError *)error{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechSSTService:onError:)]) {
        [self.delegate speechSSTService:self onError:error];
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
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechSSTService:onResult:)]) {
            [self.delegate speechSSTService:self onResult:self.resultDataStr];
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
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechSSTService:onResult:)]) {
            [self.delegate speechSSTService:self onResult:self.resultDataStr];
            self.resultDataStr = [[NSMutableString alloc]init];
        }else{
            NSLog(@"%s-通用服务实现了这个代理",__func__);
        }
    }
}

#pragma mark -- 初始化语音翻译对象
- (void)initRecognizer{
    
    if (!self.baseConfig) {
        self.baseConfig = [[GASSTConfiger alloc]init];
    }
    
    if (self.baseConfig.haveView == NO) {
        
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
//            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
//            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
////            [_iFlySpeechRecognizer setParameter: @"1" forKey: [IFlySpeechConstant ASR_SCH]];
//            [_iFlySpeechRecognizer setParameter: @"translate" forKey: @"addcap"];
        }
        
        _iFlySpeechRecognizer.delegate = self;
        
        if (_iFlySpeechRecognizer != nil) {
            
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
            [_iFlySpeechRecognizer setParameter: @"1" forKey: [IFlySpeechConstant ASR_SCH]];
            [_iFlySpeechRecognizer setParameter: @"translate" forKey: @"addcap"];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.netWorkWait forKey:[IFlySpeechConstant NET_TIMEOUT]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            [_iFlySpeechRecognizer setParameter:self.baseConfig.dot forKey:[IFlySpeechConstant ASR_PTT]];

            if (self.baseConfig.sstType == SST_Type_ZhToEn) {

                [_iFlySpeechRecognizer setParameter: @"zh" forKey: @"orilang"];
                [_iFlySpeechRecognizer setParameter: @"en" forKey: @"translang"];

            }else{

                [_iFlySpeechRecognizer setParameter: @"en" forKey: @"orilang"];
                [_iFlySpeechRecognizer setParameter: @"zh" forKey: @"translang"];

            }
        }
        
    }else{
        
        if (_iflyRecognizerView == nil) {
            UIWindow * window = [UIApplication sharedApplication].keyWindow;
            _iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:window.center];
            [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
            [_iFlySpeechRecognizer setParameter: @"1" forKey: [IFlySpeechConstant ASR_SCH]];
            [_iFlySpeechRecognizer setParameter: @"translate" forKey: @"addcap"];
        }
        
        _iflyRecognizerView.delegate = self;
        
        if (_iflyRecognizerView != nil) {
            
            [_iflyRecognizerView setParameter:self.baseConfig.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            [_iflyRecognizerView setParameter:self.baseConfig.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            [_iflyRecognizerView setParameter:self.baseConfig.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            [_iflyRecognizerView setParameter:self.baseConfig.netWorkWait forKey:[IFlySpeechConstant NET_TIMEOUT]];
            [_iflyRecognizerView setParameter:self.baseConfig.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            [_iflyRecognizerView setParameter:self.baseConfig.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
            if (self.baseConfig.sstType == SST_Type_ZhToEn) {
                
                [_iflyRecognizerView setParameter: @"zh" forKey: @"orilang"];
                [_iflyRecognizerView setParameter: @"en" forKey: @"translang"];
                
            }else{
                
                [_iflyRecognizerView setParameter: @"en" forKey: @"orilang"];
                [_iflyRecognizerView setParameter: @"zh" forKey: @"translang"];
                
            }
            
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
                    if ([label.text isEqualToString:@"语音翻译能力由讯飞输入法提供"]) {
                        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"语音翻译能力由中德宏泰提供"];
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
    [self deallocToSST];
}


@end










