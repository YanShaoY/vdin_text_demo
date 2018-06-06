//
//  GASSTConfiger.m
//  Demo
//
//  Created by YanSY on 2018/5/30.
//  Copyright © 2018年 YanSY. All rights reserved.
//


#import "GASSTConfiger.h"

@implementation GASSTConfiger

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
    _vadEos = @"2000";
    _vadBos = @"3000";
    _netWorkWait = @"60000";
    _dot = @"1";
    _sampleRate = @"16000";
    _haveView = NO;
    _sstType = SST_Type_ZhToEn;
}

-(NSString *)lowSampleRate{
    return @"8000";
}

-(NSString *)highSampleRate{
    return @"16000";
}

-(NSString *)isDot{
    return @"1";
}

-(NSString *)noDot{
    return @"0";
}

- (GASSTConfiger *)configerCopy{
    
    GASSTConfiger * configer = [[GASSTConfiger alloc]init];
    configer.speechTimeout = self.speechTimeout;
    configer.vadEos = self.vadEos;
    configer.vadBos = self.vadBos;
    configer.netWorkWait = self.netWorkWait;
    configer.dot = self.dot;
    configer.sampleRate = self.sampleRate;
    configer.haveView = self.haveView;
    configer.sstType = self.sstType;
    
    return configer;
}


@end
