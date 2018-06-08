//
//  GAiOSAudioRecorder.h
//  Demo
//
//  Created by YanSY on 2018/6/6.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 iOS录音器
 */
@interface GAiOSAudioRecorder : NSObject

#pragma mark -- 参数配置
/// 录音超时时间 默认为60s
@property (nonatomic, assign) NSUInteger speechTimeout;
/// 静音超时时间 默认为2s
@property (nonatomic, assign) NSUInteger muteTimeout;
/// 录音存储路径 默认在GA/User/
@property (nonatomic, strong) NSString * filePath;

#pragma mark -- 数据及状态获取方法
/// 是否正在录音
- (BOOL)isRecoding;
/// 文件URL地址
- (NSURL *)recordFileUrl;
/// 获取录音文件大小 录音完成后可用
- (NSUInteger)audioFileSize;

#pragma mark -- 公共方法
/**
 开始录音
 */
- (void)startRecord;
/**
 停止录音
 */
- (void)stopRecord;

@end












