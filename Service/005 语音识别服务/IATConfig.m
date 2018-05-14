//
//  IATConfig.m
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#define PUTONGHUA   @"mandarin"
#define YUEYU       @"cantonese"
#define ENGLISH     @"en_us"
#define CHINESE     @"zh_cn";
#define SICHUANESE  @"lmz";

#import "IATConfig.h"

@implementation IATConfig

#pragma mark -- 初始化
- (id)init{
    
    if (self == [super init]) {
        [self defaultSetting];
        return  self;
    }
    return nil;
}

#pragma -- 创建单例
+ (IATConfig *)sharedInstance {
    static IATConfig  * instance = nil;
    static dispatch_once_t predict;
    dispatch_once(&predict, ^{
        instance = [[IATConfig alloc] init];
    });
    return instance;
}

#pragma mark -- 默认设置参数
-(void)defaultSetting {
    _speechTimeout = @"30000";
    _vadEos = @"3000";
    _vadBos = @"3000";
    _dot = @"1";
    _sampleRate = @"16000";
    _language = CHINESE;
    _accent = PUTONGHUA;
    //默认是不带界面
    _haveView = NO;
    _accentNickName = [[NSArray alloc] initWithObjects:@"粤语",@"普通话",@"英文",@"四川话", nil];
}


+(NSString *)mandarin {
    return PUTONGHUA;
}

+(NSString *)cantonese {
    return YUEYU;
}

+(NSString *)chinese {
    return CHINESE;
}

+(NSString *)english {
    return ENGLISH;
}

+(NSString *)sichuanese {
    return SICHUANESE;
}

+(NSString *)lowSampleRate {
    return @"8000";
}

+(NSString *)highSampleRate {
    return @"16000";
}

+(NSString *)isDot {
    return @"1";
}

+(NSString *)noDot {
    return @"0";
}

@end
