//
//  GAiOSAudioRecorder.m
//  Demo
//
//  Created by YanSY on 2018/6/6.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GAiOSAudioRecorder.h"
#import "GAFileService.h"

@interface GAiOSAudioRecorder ()<AVAudioRecorderDelegate>{
    
}

/// 录音器
@property (nonatomic, strong) AVAudioRecorder * recorder;
/// 音频会话
@property (nonatomic, strong) AVAudioSession * session;

/// 录音状态(是否录音)
@property (nonatomic, assign) BOOL isRecoding;
/// 文件地址
@property (nonatomic, strong) NSURL * recordFileUrl;
/// 录音文件大小
@property (nonatomic, assign) NSUInteger audioFileSize;
/// 计时器中断
@property (nonatomic ,strong) CADisplayLink * displayLink;


@end

@implementation GAiOSAudioRecorder

#pragma mark -- 初始化
- (instancetype)init{
    self = [super init];
    if (self) {
        [self configuration];
    }
    return self;
}

- (void)configuration{

    self.speechTimeout = 60;
    self.muteTimeout = 2;
    NSString * path = [GAFileService obtainGADir];
    self.filePath = path;
    
}

#pragma mark -- 开始录音
- (void)startRecord{
    
    self.isRecoding = NO;
    self.audioFileSize = 0;
    
    if (self.recorder && [self.recorder isRecording]) {
        [self.recorder stop];
    }
    
    AVAudioSession * session =  [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if (session) {
        [session setActive:YES error:nil];
    }else{
        return;
    }
    
    self.session = session;
    self.recordFileUrl = [NSURL fileURLWithPath:self.filePath];
    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   // 采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 44100.0],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   // 采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   // 录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];
    
    
    self.recorder = [[AVAudioRecorder alloc]initWithURL:self.recordFileUrl settings:recordSetting error:nil];
    self.recorder.delegate = self;
    if(_recorder) {
        
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        self.isRecoding = YES;
        
        [_recorder recordForDuration:self.speechTimeout];
        [self updateMetering];
//        [_recorder record];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.speechTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self stopRecord];
//        });
        
    }else{
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
    }
    
}

#pragma mark -- 停止录音
- (void)stopRecord{
    
    if (self.recorder && [self.recorder isRecording]) {
        [self.recorder stop];
        self.isRecoding = NO;
        self.displayLink.paused = YES;
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:self.filePath]){
            NSDictionary * dict = [manager attributesOfItemAtPath:self.filePath error:nil];
            self.audioFileSize = [dict fileSize] / 1024.0;            
        }
    }
}

#pragma mark -- 添加计时器
-(void)updateMetering{
    
    if(self.displayLink==nil){
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeter)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    if(self.displayLink.isPaused){
        self.displayLink.paused=NO;
    }
    
}

-(void)updateMeter{
    
    [self.recorder updateMeters];
    
    CGFloat power = [self.recorder averagePowerForChannel:0];
    static int number;
    
    if(power < -60){
        
        number++;
        if(number/60 >= self.muteTimeout){
            
            [self stopRecord];
        }
    }else{
        number = 0;
    }
}

#pragma mark -- 设置方法
- (void)setFilePath:(NSString *)filePath{
    NSUInteger timerInt = [[NSDate date] timeIntervalSince1970];
    NSString * path = [filePath stringByAppendingString:[NSString stringWithFormat:@"/GA_%ld_Record.mp3",timerInt]];
    _filePath = path;
}

#pragma mark -- AVAudioRecorderDelegate
// 录音完成回调
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    
}

// 录音发生错误回调
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    
}

- (void)dealloc{
    
    [self.displayLink invalidate];

}

@end
















