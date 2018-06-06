//
//  GASpeechiOSService.h
//  Demo
//
//  Created by YanSY on 2018/6/6.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAiOSConfiger.h"

typedef NS_ENUM(NSUInteger , SpeechiOS_Error_Code) {
    /// 识别参数错误
    Error_Code_Parameter        = -10001,
    /// 系统权限错误
    Error_Code_GPS              = -10002,
    /// 识别出错
    Error_Code_Beacon           = -10003,
    /// 其他类型错误
    Error_Code_Other            = -10004,
};

#pragma mark -- iOS原生语音识别服务
@protocol GASpeechiOSServiceDelegate;

/**
 iOS原生语音识别服务
 */
@interface GASpeechiOSService : NSObject

#pragma mark -- iOS原生语音识别服务代理及配置对象
/// 设置委托对象
@property (nonatomic ,assign) id<GASpeechiOSServiceDelegate> delegate;
/// 语音识别配置（注：若需更改原始配置，请设置。 默认原始配置）
@property (nonatomic, strong) GAiOSConfiger         * baseConfig;


#pragma mark -- iOS原生语音识别服务状态获取方法
/// 是否是音频流识别
- (BOOL)isStreamRec;
/// 是否返回BeginOfSpeech回调
- (BOOL)isBeginOfSpeech;
/// 是否取消
- (BOOL)isCanceled;

#pragma mark -- iOS原生语音识别服务公共方法
/**
 初始化语音识别服务
 
 @return 返回服务对象
 */
+ (GASpeechiOSService *)sharedInstance;

/**
 开始语音识别
 
 @return 返回是否开启成功
 */
- (BOOL)startiOSToListening;


@end

















































