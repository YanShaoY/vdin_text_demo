//
//  GASpeechTextMSCService.m
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GASpeechTextMSCService.h"

@implementation GASpeechTextMSCService

#pragma mark -- 设置语音服务的APPID
+ (void)setMSCWithAPPId:(NSString *)appid{
    
    [IFlySetting setLogFile:LVL_LOW];
    [IFlySetting showLogcat:NO];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];
    
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",appid];
    [IFlySpeechUtility createUtility:initString];
}

+ (GASpeechIATService *)initSpeechIATServiceWithConfig:(GAIATConfiger *)configer{
    GASpeechIATService * service = [GASpeechIATService sharedInstance];
    if (configer) {
        service.baseConfig = configer;
    }
    return service;
}

+ (GASpeechTTSService *)initSpeechTTSServiceWithConfig:(GATTSConfiger *)configer{
    GASpeechTTSService * service = [GASpeechTTSService sharedInstance];
    if (configer) {
        service.baseConfig = configer;
    }
    return service;
}

@end












