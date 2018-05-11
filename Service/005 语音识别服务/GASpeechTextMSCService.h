//
//  GASpeechTextMSCService.h
//  Demo
//
//  Created by YanSY on 2018/5/10.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GASpeechTextMSCService : NSObject

/**
 初始化语音识别服务

 @param appid 注册的APPID
 */
+ (void)initMSCServiceWithAPPId:(NSString *)appid;

@end
