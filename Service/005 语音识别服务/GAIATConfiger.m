//
//  GAIATConfiger.m
//  Demo
//
//  Created by YanSY on 2018/5/15.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#define PUTONGHUA   @"mandarin"
#define YUEYU       @"cantonese"
#define ENGLISH     @"en_us"
#define CHINESE     @"zh_cn";
#define SICHUANESE  @"lmz";

#import "GAIATConfiger.h"

@implementation GAIATConfiger

#pragma mark -- 初始化
- (id)init{
    self = [super init];
    if (self) {
        [self defaultIATSetting];
        return  self;
    }
    return nil;
}

#pragma mark -- 语音识别设置参数
-(void)defaultIATSetting {
    _speechTimeout = @"30000";
    _vadEos = @"3000";
    _vadBos = @"3000";
    _netWorkWait = @"20000";
    _dot = @"1";
    _sampleRate = @"16000";
    _language = CHINESE;
    _accent = PUTONGHUA;
    _haveView = YES;
    _accentNickName = [[NSArray alloc] initWithObjects:@"粤语",@"普通话",@"英文",@"四川话", nil];
}


-(NSString *)mandarin {
    return PUTONGHUA;
}

-(NSString *)cantonese {
    return YUEYU;
}

-(NSString *)chinese {
    return CHINESE;
}

-(NSString *)english {
    return ENGLISH;
}

-(NSString *)sichuanese {
    return SICHUANESE;
}

-(NSString *)lowSampleRate {
    return @"8000";
}

-(NSString *)highSampleRate {
    return @"16000";
}

-(NSString *)isDot {
    return @"1";
}

-(NSString *)noDot {
    return @"0";
}

@end














