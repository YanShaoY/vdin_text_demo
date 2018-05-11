//
//  GANetworkService.m
//  GAProduct
//
//  Created by sunlang on 2017/3/20.
//  Copyright © 2017年 ZDHT. All rights reserved.
//

#import "GANetworkService.h"

@implementation GANetworkService

+ (void)configureNetwork
{
#ifdef DEBUG
    [GANetworkTool enableInterfaceDebug:NO];
#endif
    
    [GANetworkTool configRequestType:kGARequestTypeJSON responseType:kGAResponseTypeJSON shouldAutoEncodeUrl:NO callbackOnCancelRequest:YES];
}

//判断有无网
+ (BOOL)isReachable
{
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

//判断是不是 WiFi
+ (BOOL)isReachableViaWiFi
{
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
}

//判断是不是万维网
+ (BOOL)isReachableViaWWAN
{
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
}

+ (void)cancelRequestWithURL:(NSString *)url
{
    [GANetworkTool cancelRequestWithURL:url];
}

+ (void)get:(NSString *)strUrl params:(id)params success:(GAHttpSuccessBlock)success failure:(GAHttpFailureBlock)failure timeoutInterval:(NSTimeInterval)interval;
{
    if (interval <= 0) {
        interval = GA_REQUEST_TIMEINTERVAL;
    }
    
    GAURLSessionTask *task = [GANetworkTool getWithUrl:strUrl refreshCache:NO params:params progress:nil success:^(id response) {
        
        !success ? : success(response);
        
    } fail:^(NSError *error) {
        
        if (failure)
        {
            if (error != nil) {
                
                error = [self defulteErrorWithError:error];
            }
            failure(error);
        }
        
    } timeoutInterval:interval];
    
    task ? : failure([self generateError]);
}

+ (void)post:(NSString *)strUrl params:(id)params success:(GAHttpSuccessBlock)success failure:(GAHttpFailureBlock)failure timeoutInterval:(NSTimeInterval)interval;
{
    if (interval <= 0) {
        interval = GA_REQUEST_TIMEINTERVAL;
    }
    
    GAURLSessionTask *task = [GANetworkTool postWithUrl:strUrl refreshCache:NO params:params progress:nil success:^(id response) {
        
        !success ? : success(response);
        
    } fail:^(NSError *error) {
        
        if (failure)
        {
            if (error != nil) {
                
                error = [self defulteErrorWithError:error];
            }
            failure(error);
        }
        
    } timeoutInterval:interval];
    
    task ? : failure([self generateError]);
}

//TODO:DELETE请求
+ (void)deleteWithUrl:(NSString *)strUrl params:(id)params success:(GAHttpSuccessBlock)success failure:(GAHttpFailureBlock)failure
{
    GAURLSessionTask *task = [GANetworkTool deleteWithUrl:strUrl params:params success:^(id response) {
        
        !success ? : success(response);
        
    } fail:^(NSError *error) {
        
        !failure ? : failure(error);

    }];
    
    task ? : failure([self generateError]);

}

+ (void)patch:(NSString *)strUrl params:(id)params success:(GAHttpSuccessBlock)success failure:(GAHttpFailureBlock)failure{
    
    GAURLSessionTask *task = [GANetworkTool patchWithUrl:strUrl params:params success:^(id response) {
        
        !success ? : success(response);
        
    } fail:^(NSError *error) {
        
        !failure ? : failure(error);

    }];
    
    task ? : failure([self generateError]);

}

#pragma mark - 网络状态监听
//监听网络状态
+ (void)reachabilityNotwekAndNetworkStatuChange:(void (^)(AFNetworkReachabilityStatus status))changeBlcok
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"GA:当前网络状态-->%ld", (long)status);
        changeBlcok(status);
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

//生成标准的 error
+ (NSError *)defulteErrorWithError:(NSError *)error
{
    NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
    
    NSData *data = [userInfo valueForKey:JSONResponseSerializerWithDataKey];
    if (data)
    {
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (responseBody) {
            
            userInfo[JSONResponseSerializerWithDataKey] = responseBody;
            
        } else {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            userInfo[JSONResponseSerializerWithDataKey] = result;
        }
        
    }
    
    NSError *newError = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
    return newError;
}

+ (NSError *)generateError
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"URL格式错误或者是请求终止, 具体看 log打印" forKey:JSONResponseSerializerWithDataKey];
    NSError *error = [NSError errorWithDomain:@"Unknow" code:NSURLErrorUnknown userInfo:userInfo];
    return error;
}

/**
 解析 Error
 
 @param error   error
 @param message 解析不出, 默认返回的字符串.
 
 @return 解析出的错误信息
 */
+ (NSString *)analysisError:(NSError *)error defaultMessage:(NSString *)message
{
    id responseBody = error.userInfo[JSONResponseSerializerWithDataKey];
    NSString *msg;
    if (responseBody){
        if ([responseBody isKindOfClass:[NSDictionary class]]) {
            msg = responseBody[@"message"];
        } else if ([responseBody isKindOfClass:[NSString class]]) {
            msg = responseBody;
        } else {
            msg = [message mutableCopy];
        }
    } else {
        msg = [message mutableCopy];
    }
    
    return msg;
}


@end
