//
//  GAXFMscPcmPlayer.h
//  Demo
//
//  Created by YanSY on 2018/5/15.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface GAXFMscPcmPlayer : NSObject <AVAudioPlayerDelegate>

/**
 是否在播放状态
 ****/
@property (nonatomic,assign) BOOL isPlaying;

/**
 * 初始化播放器，并传入音频的本地路径
 *
 * path   音频pcm文件完整路径
 * sample 音频pcm文件采样率，支持8000和16000两种
 ****/
-(id)initWithFilePath:(NSString *)path sampleRate:(long)sample;

/**
 * 初始化播放器，并传入音频数据
 *
 * data   音频数据
 * sample 音频pcm文件采样率，支持8000和16000两种
 ****/
-(id)initWithData:(NSData *)data sampleRate:(long)sample;

/**
 开始播放
 ****/
- (void)play;

/**
 停止播放
 ****/
- (void)stop;


@end








