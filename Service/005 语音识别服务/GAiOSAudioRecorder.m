//
//  GAiOSAudioRecorder.m
//  Demo
//
//  Created by YanSY on 2018/6/6.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GAiOSAudioRecorder.h"

@interface GAiOSAudioRecorder ()

/// 录音器
@property (nonatomic, strong) AVAudioRecorder * recorder;

@end

@implementation GAiOSAudioRecorder


- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark -- 开始录音
- (void)start{
    
    AVAudioSession * session =  [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    if (session) {
        [session setActive:YES error:nil];
    }else{
        return;
    }
    
    
    
}

@end
















