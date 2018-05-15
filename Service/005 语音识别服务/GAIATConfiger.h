//
//  GAIATConfiger.h
//  Demo
//
//  Created by YanSY on 2018/5/15.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 语音识别配置文件
 */
@interface GAIATConfiger : NSObject

/// 普通话
-(NSString *)mandarin;
/// 广东话
-(NSString *)cantonese;
/// 四川话
-(NSString *)sichuanese;
/// 中文
-(NSString *)chinese;
/// 英文
-(NSString *)english;

/// 低采样率
-(NSString *)lowSampleRate;
/// 高采样率
-(NSString *)highSampleRate;

/// 加入标点
-(NSString *)isDot;
/// 不加标点
-(NSString *)noDot;

/**
 以下参数，需要通过
 iFlySpeechRecgonizer
 进行设置
 ****/

/// 设置最长录音时间
@property (nonatomic, strong) NSString *speechTimeout;
/// 设置后端点
@property (nonatomic, strong) NSString *vadEos;
/// 设置前端点
@property (nonatomic, strong) NSString *vadBos;
/// 设置网络等待时间
@property (nonatomic, strong) NSString *netWorkWait;
/// 设置语言
@property (nonatomic, strong) NSString *language;
/// 设置方言
@property (nonatomic, strong) NSString *accent;
/// 设置是否返回标点符号
@property (nonatomic, strong) NSString *dot;
/// 设置采样率，推荐使用16K
@property (nonatomic, strong) NSString *sampleRate;

/// 是否显示动画
@property (nonatomic, assign) BOOL haveView;
/// 口音识别ID
@property (nonatomic, strong) NSArray *accentIdentifer;
/// 口音名称数组
@property (nonatomic, strong) NSArray *accentNickName;


/**
 创建配置

 @param config 对应的对象
 @return 返回实例
 */
+(instancetype)createWithId:(id)config;

@end











