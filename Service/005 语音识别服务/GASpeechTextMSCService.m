//
//  GASpeechTextMSCService.m
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GASpeechTextMSCService.h"
#import "GAFileService.h"

@implementation GASpeechTextMSCService

#pragma mark -- 设置语音服务的APPID
+ (void)setMSCWithAPPId:(NSString *)appid{
    
    [IFlySetting setLogFile:LVL_NONE];
    [IFlySetting showLogcat:NO];
    
    NSString * path = [GAFileService obtainGADir];
    [IFlySetting setLogFilePath:path];
    
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

+ (GASpeechSSTService *)initSpeechSSTServiceWithConfig:(GASSTConfiger *)configer{
    
    GASpeechSSTService * service = [GASpeechSSTService sharedInstance];
    if (configer) {
        service.baseConfig = configer;
    }
    return service;
}


@end












