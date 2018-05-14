//
//  IATConfig.h
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 语音识别配置
 */
@interface IATConfig : NSObject

/**
 创建实例对象

 @return 返回本类实例对象
 */
+(IATConfig *)sharedInstance;

/// 普通话
+(NSString *)mandarin;
/// 广东话
+(NSString *)cantonese;
/// 四川话
+(NSString *)sichuanese;
/// 中文
+(NSString *)chinese;
/// 英文
+(NSString *)english;

/// 低采样率
+(NSString *)lowSampleRate;
/// 高采样率
+(NSString *)highSampleRate;

/// 加入标点
+(NSString *)isDot;
/// 不加标点
+(NSString *)noDot;


/**
 以下参数，需要通过
 iFlySpeechRecgonizer
 进行设置
 ****/
@property (nonatomic, strong) NSString *speechTimeout;
@property (nonatomic, strong) NSString *vadEos;
@property (nonatomic, strong) NSString *vadBos;

@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *accent;

@property (nonatomic, strong) NSString *dot;
@property (nonatomic, strong) NSString *sampleRate;


/**
 以下参数无需设置
 不必管
 ****/
@property (nonatomic, assign) BOOL haveView;
@property (nonatomic, strong) NSArray *accentIdentifer;
@property (nonatomic, strong) NSArray *accentNickName;


@end
