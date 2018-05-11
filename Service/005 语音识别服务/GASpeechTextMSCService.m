//
//  GASpeechTextMSCService.m
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GASpeechTextMSCService.h"
#import "IFlyMSC/IFlyMSC.h"

@implementation GASpeechTextMSCService

#pragma mark -- 初始化
+ (void)initMSCServiceWithAPPId:(NSString *)appid{
    
    //设置sdk的log等级，log保存在下面设置的工作路径中
    [IFlySetting setLogFile:LVL_ALL];
    //打开输出在console的log开关
    [IFlySetting showLogcat:YES];
    //设置sdk的工作路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",appid];
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
}








@end












