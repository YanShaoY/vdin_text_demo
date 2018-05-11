//
//  GANetworkService.h
//  GAProduct
//
//  Created by sunlang on 2017/3/20.
//  Copyright © 2017年 ZDHT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANetworkTool.h"

typedef void (^GAHttpSuccessBlock)(id responseObject);    // http请求成功回调
typedef void (^GAHttpFailureBlock)(NSError *error);       // http请求失败回调

typedef void (^GAUploadProgressBlock)(int64_t bytesWritten,    //上传进度
int64_t totalBytesWritten);

typedef void (^GADownloadProgressBlock)(int64_t bytesRead,     //下载进度
int64_t totalBytesRead);

static NSString * const JSONResponseSerializerWithDataKey = @"com.alamofire.serialization.response.error.data"; //获取详细信息的key

@interface GANetworkService : NSObject

/**
 配置网络, 程序启动后调用, 既 AppDelegate 里调用
 */
+ (void)configureNetwork;

//判断有无网
+ (BOOL)isReachable;

//判断是不是 WiFi
+ (BOOL)isReachableViaWiFi;

//判断是不是万维网
+ (BOOL)isReachableViaWWAN;

//取消请求
+ (void)cancelRequestWithURL:(NSString *)url;

/**
 get 请求

 @param strUrl   URL 地址
 @param params   参数
 @param success  成功的回调
 @param failure  失败的回调
 @param interval 请求超时时间
 */
+ (void)get:(NSString *)strUrl params:(id)params success:(GAHttpSuccessBlock)success failure:(GAHttpFailureBlock)failure timeoutInterval:(NSTimeInterval)interval;

/**
 post 请求

 @param strUrl   URL 地址
 @param params   参数
 @param success  成功的回调
 @param failure  失败的回调
 @param interval 请求超时时间
 */
+ (void)post:(NSString *)strUrl params:(id)params success:(GAHttpSuccessBlock)success failure:(GAHttpFailureBlock)failure timeoutInterval:(NSTimeInterval)interval;

/**
 delete 请求

 @param strUrl  URL 地址
 @param params  参数
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)deleteWithUrl:(NSString *)strUrl params:(id)params success:(GAHttpSuccessBlock)success failure:(GAHttpFailureBlock)failure;

/**
 patch 请求

 @param strUrl  URL 地址
 @param params  参数
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)patch:(NSString *)strUrl params:(id)params success:(GAHttpSuccessBlock)success failure:(GAHttpFailureBlock)failure;

/**
 *  监听网络状态
 *
 *  @param changeBlcok 改变回调
 */
+ (void)reachabilityNotwekAndNetworkStatuChange:(void (^)(AFNetworkReachabilityStatus status))changeBlcok;

/**
 解析 Error
 
 @param error   error
 @param message 解析不出, 默认返回的字符串.
 
 @return 解析出的错误信息
 */
+ (NSString *)analysisError:(NSError *)error defaultMessage:(NSString *)message;

@end
