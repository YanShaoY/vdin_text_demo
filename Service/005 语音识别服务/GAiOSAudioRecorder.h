//
//  GAiOSAudioRecorder.h
//  Demo
//
//  Created by YanSY on 2018/6/6.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface GAiOSAudioRecorder : NSObject<AVAudioRecorderDelegate>

//录音存储路径

@property (nonatomic, strong)NSURL *tmpFile;




//录音状态(是否录音)

@property (nonatomic, assign)BOOL isRecoding;

@end












