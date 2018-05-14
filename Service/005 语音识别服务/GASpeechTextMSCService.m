//
//  GASpeechTextMSCService.m
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GASpeechTextMSCService.h"

#import <QuartzCore/QuartzCore.h>
#import "Definition.h"
#import "ISRDataHelper.h"
#import "IATConfig.h"


#define NAME        @"userwords"
#define USERWORDS   @"{\"userword\":[{\"name\":\"我的常用词\",\"words\":[\"佳晨实业\",\"蜀南庭苑\",\"高兰路\",\"复联二\"]},{\"name\":\"我的好友\",\"words\":[\"李馨琪\",\"鹿晓雷\",\"张集栋\",\"周家莉\",\"叶震珂\",\"熊泽萌\"]}]}"


@implementation GASpeechTextMSCService

#pragma mark -- 初始化
+ (void)initMSCServiceWithAPPId:(NSString *)appid{
    
    //设置sdk的log等级，log保存在下面设置的工作路径中
    [IFlySetting setLogFile:LVL_ALL];
    //打开输出在console的log开关
    [IFlySetting showLogcat:YES];
    //设置sdk的工作路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",appid];
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
}

#pragma mark -- 创建语音识别
- (void)createASR{
    
    self.uploader = [[IFlyDataUploader alloc] init];
    
    //demo录音文件保存路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    self.pcmFilePath = [[NSString alloc] initWithFormat:@"%@",[cachePath stringByAppendingPathComponent:@"asr.pcm"]];
    
    //初始化识别对象
    [self initRecognizer];
    
}
#pragma mark -- 启动听写
- (void)startToASR{
    NSLog(@"%s[IN]",__func__);

    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        self.isCanceled = NO;
        self.isStreamRec = NO;
        
        if(_iFlySpeechRecognizer == nil)
        {
            [self initRecognizer];
        }
        
        [_iFlySpeechRecognizer cancel];
        
        //设置音频来源为麦克风
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置听写结果格式为json
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [_iFlySpeechRecognizer setDelegate:self];
        
        BOOL ret = [_iFlySpeechRecognizer startListening];
        
    }else {
        
        if(_iflyRecognizerView == nil)
        {
            [self initRecognizer ];
        }
        
        
        //设置音频来源为麦克风
        [_iflyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置听写结果格式为json
        [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        BOOL ret = [_iflyRecognizerView start];
    }
    
    
}

#pragma mark -- 停止听写
- (void)stopToASR{
    NSLog(@"%s",__func__);
    
    if(self.isStreamRec && !self.isBeginOfSpeech){
        NSLog(@"%s,停止录音",__func__);
        [_pcmRecorder stop];
        //        [_popUpView showText: @"停止录音"];
    }
    
    [_iFlySpeechRecognizer stopListening];
}

#pragma mark -- 取消听写
- (void)cancelToASR{
    NSLog(@"%s",__func__);
    
    if(self.isStreamRec && !self.isBeginOfSpeech){
        NSLog(@"%s,停止录音",__func__);
        [_pcmRecorder stop];
        //        [_popUpView showText: @"停止录音"];
    }
    
    self.isCanceled = YES;
    
    [_iFlySpeechRecognizer cancel];
}

#pragma mark -- 注销识别
- (void)deallocToASR{
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        [_iFlySpeechRecognizer cancel]; //取消识别
        [_iFlySpeechRecognizer setDelegate:nil];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        [_pcmRecorder stop];
        _pcmRecorder.delegate = nil;
    }
    else
    {
        [_iflyRecognizerView cancel]; //取消识别
        [_iflyRecognizerView setDelegate:nil];
        [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    }
}

#pragma mark -- 上传联系人
- (void)upContactDataWithBlock:(void(^)(NSString *result, IFlySpeechError *error))block{
    
    [_iFlySpeechRecognizer stopListening];
    
    IFlyContact * iFlyContact = [[IFlyContact alloc] init];
    NSString *contact = [iFlyContact contact];
    
    [_uploader setParameter:@"uup" forKey:[IFlySpeechConstant SUBJECT]];
    [_uploader setParameter:@"contact" forKey:[IFlySpeechConstant DATA_TYPE]];
    [_uploader uploadDataWithCompletionHandler:block name:@"contact" data:contact];
    
}

#pragma mark -- 上传用户词表
- (void)upUserWordDataWithJson:(NSString *)userWords Block:(void(^)(NSString *result, IFlySpeechError *error))block{
    
    [_iFlySpeechRecognizer stopListening];
    
    IFlyUserWords *iFlyUserWords = [[IFlyUserWords alloc]initWithJson:userWords ];
    
    [_uploader setParameter:@"uup" forKey:[IFlySpeechConstant SUBJECT]];
    [_uploader setParameter:@"userword" forKey:[IFlySpeechConstant DATA_TYPE]];
    
    [_uploader uploadDataWithCompletionHandler:block name:@"userwords" data:[iFlyUserWords toString]];
    
}

#pragma mark -- 音频流识别启动
- (void)audioStreamStart{
    NSLog(@"%s[IN]",__func__);
    self.isStreamRec = YES;
    self.isBeginOfSpeech = NO;
    
    if ([IATConfig sharedInstance].haveView == YES) {
        return;
    }
    
    if(_iFlySpeechRecognizer == nil)
    {
        [self initRecognizer];
    }
    
    [_iFlySpeechRecognizer setDelegate:self];
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];    //设置音频数据模式为音频流
    BOOL ret  = [_iFlySpeechRecognizer startListening];
    
    
    if (ret) {
        self.isCanceled = NO; //启动发送数据线程
        //初始化录音环境
        [IFlyAudioSession initRecordingAudioSession];
        
        _pcmRecorder.delegate = self;
        
        //启动录音器服务
        BOOL ret = [_pcmRecorder start];
        
        //        [NSThread detachNewThreadSelector:@selector(sendAudioThread) toTarget:self withObject:nil];
        NSLog(@"%s[OUT],Success,Recorder ret=%d",__func__,ret);
        
        //        [NSThread sleepForTimeInterval:1];
        //        [IFlyAudioSession initRecordingAudioSession];
        //        _pcmRecorder.delegate = self;
        //        [_pcmRecorder start];
    }
    else
    {
        NSLog(@"%s[OUT],Failed",__func__);
    }
    
}

#pragma mark - IFlySpeechRecognizerDelegate
/**
 音量回调函数

 @param volume 0-30
 */
- (void)onVolumeChanged:(int)volume{
    
}

/**
 开始识别回调
 */
- (void)onBeginOfSpeech{
    
}

/**
 停止录音回调
 */
- (void)onEndOfSpeech{
    
}

/**
 听写取消回调
 */
- (void)onCancel{
    
}

/**
 听写结束回调（注：无论听写是否正确都会回调）

 @param error 0:听写正确 other:听写出错
 */
- (void)onError:(IFlySpeechError *)error{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO ) {
        
        //        if (self.isStreamRec) {
        //            //当音频流识别服务和录音器已打开但未写入音频数据时stop，只会调用onError不会调用onEndOfSpeech，导致录音器未关闭
        //            [_pcmRecorder stop];
        //            self.isStreamRec = NO;
        //            NSLog(@"error录音停止");
        //        }
        
        NSString *text ;
        
        if (self.isCanceled) {
            text = @"识别取消";
            
        } else if (error.errorCode == 0 ) {
            if (_result.length == 0) {
                text = @"无识别结果";
            }else {
                text = @"识别成功";
                //清空识别结果
                _result = nil;
            }
        }else {
            text = [NSString stringWithFormat:@"发生错误：%d %@", error.errorCode,error.errorDesc];
            NSLog(@"%@",text);
        }
        
//        [_popUpView showText: text];
        
    }else {
//        [_popUpView showText:@"识别结束"];
        NSLog(@"errorCode:%d",[error errorCode]);
    }
    
}


/**
 无界面，听写结果回调

 @param results 听写结果
 @param isLast 表示最后一次
 */
- (void)onResults:(NSArray *)results isLast:(BOOL)isLast{
//    NSMutableString *resultString = [[NSMutableString alloc] init];
//    NSDictionary *dic = results[0];
//    for (NSString *key in dic) {
//        [resultString appendFormat:@"%@",key];
//    }
//    _result =[NSString stringWithFormat:@"%@%@", _textView.text,resultString];
//    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
//    _textView.text = [NSString stringWithFormat:@"%@%@", _textView.text,resultFromJson];
//
//    if (isLast){
//        NSLog(@"听写结果(json)：%@测试",  self.result);
//    }
//    NSLog(@"_result=%@",_result);
//    NSLog(@"resultFromJson=%@",resultFromJson);
//    NSLog(@"isLast=%d,_textView.text=%@",isLast,_textView.text);
}


/**
 有界面，听写结果回调

 @param resultArray 听写结果
 @param isLast 表示最后一次
 */
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast{
//    NSMutableString *result = [[NSMutableString alloc] init];
//    NSDictionary *dic = [resultArray objectAtIndex:0];
//
//    for (NSString *key in dic) {
//        [result appendFormat:@"%@",key];
//    }
//    _textView.text = [NSString stringWithFormat:@"%@%@",_textView.text,result];
}

#pragma mark -- IFlyDataUploaderDelegate


#pragma mark -- 设置识别参数
-(void)initRecognizer
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        //单例模式，无UI的实例
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        _iFlySpeechRecognizer.delegate = self;
        
        if (_iFlySpeechRecognizer != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            
            //设置最长录音时间
            [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            //设置语言
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //设置方言
            [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            
            //设置是否返回标点符号
            [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
        
        //初始化录音器
        if (_pcmRecorder == nil)
        {
            _pcmRecorder = [IFlyPcmRecorder sharedInstance];
        }
        
        _pcmRecorder.delegate = self;
        
        [_pcmRecorder setSample:[IATConfig sharedInstance].sampleRate];
        
        [_pcmRecorder setSaveAudioPath:nil];    //不保存录音文件
        
    }else  {//有界面
        
//        //单例模式，UI的实例
//        if (_iflyRecognizerView == nil) {
//            //UI显示剧中
//
//            _iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
//
//            [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
//
//            //设置听写模式
//            [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
//
//        }
//        _iflyRecognizerView.delegate = self;
//
//        if (_iflyRecognizerView != nil) {
//            IATConfig *instance = [IATConfig sharedInstance];
//            //设置最长录音时间
//            [_iflyRecognizerView setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
//            //设置后端点
//            [_iflyRecognizerView setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
//            //设置前端点
//            [_iflyRecognizerView setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
//            //网络等待时间
//            [_iflyRecognizerView setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
//
//            //设置采样率，推荐使用16K
//            [_iflyRecognizerView setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
//            if ([instance.language isEqualToString:[IATConfig chinese]]) {
//                //设置语言
//                [_iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
//                //设置方言
//                [_iflyRecognizerView setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
//            }else if ([instance.language isEqualToString:[IATConfig english]]) {
//                //设置语言
//                [_iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
//            }
//            //设置是否返回标点符号
//            [_iflyRecognizerView setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
//
//        }
    }
}



@end












