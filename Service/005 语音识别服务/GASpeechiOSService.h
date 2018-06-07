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
    Error_Code_Author           = -10002,
    /// 识别出错
    Error_Code_Speech           = -10003,
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
/// 是否返回Begin回调
- (BOOL)isBegin;
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

/**
 停止语音识别
 */
- (void)stopiOSToListening;

/**
 识别本地音频文件

 @param url 本地音频文件URL路径
 @return 返回启动状态
 */
- (BOOL)startLocalAudioStreamWithUrl:(NSURL *)url;


/**
 注销语音识别（注：在界面消失时调用）
 */
- (void)deallocToiOS;


@end


#pragma mark -- iOS原生语音识别服务代理
/**
 iOS原生语音识别服务代理
 */
@protocol GASpeechiOSServiceDelegate <NSObject>




/**
 错误回调

 @param service 语音识别服务
 @param error 错误信息
 */
- (void)speechiOSService:(GASpeechiOSService *)service
                 onError:(NSError *)error;

@end











































