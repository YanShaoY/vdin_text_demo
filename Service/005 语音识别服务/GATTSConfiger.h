//
//  GATTSConfiger.h
//  Demo
//
//  Created by YanSY on 2018/5/16.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
//包含头文件
#import "iflyMSC/iflyMSC.h"

/**
 语音合成配置文件
 */
@interface GATTSConfiger : NSObject

/**
 以下参数，需要通过
 iFlySpeechSynthesizer
 进行设置
 ****/

/// 播放语速语速
@property (nonatomic, strong) NSString     * speed;
/// 音量
@property (nonatomic, strong) NSString     * volume;
/// 音调
@property (nonatomic, strong) NSString     * pitch;
/// 采样率
@property (nonatomic, strong) NSString     * sampleRate;
/// 发音人
@property (nonatomic, strong) NSString     * vcnName;
/// 编码格式
@property (nonatomic, strong) NSString     * textEnCoding;
/// 引擎类型,"auto","local","cloud" 目前只支持云端
@property (nonatomic, strong) NSString     * engineType;
/// URL合成是否自动播放 默认YES ,若设置为NO，请在返回代理中获取本地文件
@property (nonatomic, assign) BOOL           autoPlayURL;
/// URL合成文件保存路径
@property (nonatomic, strong) NSString     * uriPath;

/// 发音人名称数组
@property (nonatomic,strong) NSArray *vcnNickNameArray;
/// 发音人ID数组
@property (nonatomic,strong) NSArray *vcnIdentiferArray;

/**
 复制拷贝当前配置
 
 @return 返回拷贝后的配置
 */
- (GATTSConfiger *)configerCopy;

@end







