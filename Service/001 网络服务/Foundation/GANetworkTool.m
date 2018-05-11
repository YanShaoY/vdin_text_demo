//
//  GANetworkTool.m
//  GAProduct
//
//  Created by sunlang on 2017/3/20.
//  Copyright © 2017年 ZDHT. All rights reserved.
//

#import "GANetworkTool.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

#import <YYModel/YYModel.h>

//加密
#import <CommonCrypto/CommonDigest.h>

#import "NSDate+DateString.h"

#import "UIImage+Extension.h"

typedef NS_ENUM(NSUInteger, GARequestMethod)
{
    kGARequestMethodGET = 1,
    kGARequestMethodPOST = 2,
    kGARequestMethodDELETE = 3,
    kGARequestMethodPATCH = 4,
    
};

#pragma mark - md5

@interface NSString (md5)

+ (NSString *)hybnetworking_md5:(NSString *)string;

@end

@implementation NSString (md5)

+ (NSString *)hybnetworking_md5:(NSString *)string
{
    if (string == nil || string.length ==0)
    {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([string UTF8String], (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [ms appendFormat:@"%02x", (int)digest[i]];
    }
    
    return [ms copy];
}

@end

#pragma end

#pragma mark - httptool

static NSString *ga_privateNetworkBaseUrl = nil;                //基础baseUrl
static BOOL ga_isEnableInterfaceDebug = NO;                     //DEBUG打印开关
static BOOL ga_shouldAutoEncode = NO;                           //自动编码开关
static NSDictionary *ga_httpHeaders = nil;                      //头信息
static GAResponseType ga_responseType = kGAResponseTypeJSON;    //响应类型, 默认json
static GARequestType ga_requestType = kGARequestTypeJSON;       //请求类型, 默认json
static NSMutableArray *ga_requestTasks;                         //任务栈
static BOOL ga_cacheGet = NO;                                  //GET缓存开关
static BOOL ga_cachePost = NO;                                  //POST缓存开关
static BOOL ga_shouldCallbackOnCancelRequest = YES;             //取消请求回调开关
static BOOL ga_enabledActivityIndicator = NO;                   //是否开启动画, 默认NO


@implementation GANetworkTool

#pragma mark --------------------  config  --------------------

+ (void)cacheGetRequest:(BOOL)isCacheGet shouldCachePost:(BOOL)shouldCachePost
{
    ga_cacheGet = isCacheGet;
    ga_cachePost = shouldCachePost;
}

+ (void)updateBaseUrl:(NSString *)baseUrl
{
    ga_privateNetworkBaseUrl = baseUrl;
}

+ (NSString *)baseUrl
{
    return ga_privateNetworkBaseUrl;
}

+ (void)enableInterfaceDebug:(BOOL)isBug
{
    ga_isEnableInterfaceDebug = isBug;
}

+ (void)enableActivityIndicator:(BOOL)enabled
{
    ga_enabledActivityIndicator = enabled;
}

+ (BOOL)isDebug
{
    return ga_isEnableInterfaceDebug;
}

//获取缓存路径
static inline NSString *cachePath() {
    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/GANetworkingCaches"];
}

+ (void)clearCache
{
    //获取缓存路径
    NSString *directoryPath = cachePath();
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil])
    {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error];
        
        if (error)
        {
            NSLog(@"GANetworkTool clear caches error: %@", error);
        }
        else
        {
            GALog(@"GANetworkTool clear caches ok");
        }
    }
}

+ (unsigned long long)totalCacheSize
{
    NSString *directoryPath = cachePath();
    BOOL isDir = NO;
    unsigned long long total = 0.f;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir])
    {
        if (isDir)
        {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            
            if (error == nil)
            {
                //遍历所有缓存下的目录, 计算出大小
                for (NSString *subpath in array)
                {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
                    
                    if (!error)
                    {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    
    return total;
}

+ (NSMutableArray *)allTasks {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //全局只初始化一次
        if (ga_requestTasks == nil)
        {
            ga_requestTasks = [[NSMutableArray alloc] init];
        }
    });
    
    return ga_requestTasks;
}

+ (void)cancelAllRequest
{
    //加锁
    @synchronized (self)
    {
        [[self allTasks] enumerateObjectsUsingBlock:^(GAURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([task isKindOfClass:[GAURLSessionTask class]])
            {
                [task cancel];
            }
            
            [[self allTasks] removeAllObjects];
            
        }];
    }
}

+ (void)cancelRequestWithURL:(NSString *)url
{
    if (url == nil) return;
    
    @synchronized (self)
    {
        [[self allTasks] enumerateObjectsUsingBlock:^(GAURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([task isKindOfClass:[GAURLSessionTask class]] && [task.currentRequest.URL.absoluteString hasSuffix:url])
            {
                [task cancel];
                [[self allTasks] removeObject:task];
                return ;
            }
        }];
    };
}

+ (void)configRequestType:(GARequestType)requestType
             responseType:(GAResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
  callbackOnCancelRequest:(BOOL)shouldCallbackOnCancelRequest
{
    ga_requestType = requestType;
    ga_responseType = responseType;
    ga_shouldAutoEncode = shouldAutoEncode;
    ga_shouldCallbackOnCancelRequest = shouldCallbackOnCancelRequest;
}

+ (BOOL)shouldEncode
{
    return ga_shouldAutoEncode;
}

+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders
{
    ga_httpHeaders = httpHeaders;
}

+ (AFHTTPSessionManager *)getSessionManager
{
    return [self manager];
}

#pragma mark --------------------  request  --------------------
//TODO:GET 请求

+ (GAURLSessionTask *)getWithUrl:(NSString *)url
                    refreshCache:(BOOL)refreshCache
                         success:(GAResponseSuccess)sucess
                            fail:(GAResponseFail)fail
{
    return [self getWithUrl:url
               refreshCache:refreshCache
                     params:nil success:sucess
                       fail:fail];
}

+ (GAURLSessionTask *)getWithUrl:(NSString *)url
                    refreshCache:(BOOL)refreshCache
                          params:(NSDictionary *)params
                         success:(GAResponseSuccess)sucess
                            fail:(GAResponseFail)fail
{
    return [self getWithUrl:url
               refreshCache:refreshCache
                     params:params
                   progress:nil
                    success:sucess
                       fail:fail
            timeoutInterval:GA_REQUEST_TIMEINTERVAL];
}

+ (GAURLSessionTask *)getWithUrl:(NSString *)url
                    refreshCache:(BOOL)refreshCache
                          params:(NSDictionary *)params
                        progress:(GAGetProgress)progress
                         success:(GAResponseSuccess)sucess
                            fail:(GAResponseFail)fail
                 timeoutInterval:(NSTimeInterval)interval;
{
    return [self requestWithUrl:url
                   refreshCache:refreshCache
                      httpMedth:kGARequestMethodGET
                         params:params
                       progress:progress
                        success:sucess
                           fail:fail
                timeoutInterval:interval];
}

//TODO:POST 请求

+ (GAURLSessionTask *)postWithUrl:(NSString *)url
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary *)params
                          success:(GAResponseSuccess)sucess
                             fail:(GAResponseFail)fail
{
    return [self postWithUrl:url
                refreshCache:refreshCache
                      params:params
                    progress:nil
                     success:sucess
                        fail:fail
             timeoutInterval:GA_REQUEST_TIMEINTERVAL];
}
+ (GAURLSessionTask *)postWithUrl:(NSString *)url
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary *)params
                         progress:(GAPostProgress)progress
                          success:(GAResponseSuccess)sucess
                             fail:(GAResponseFail)fail
                  timeoutInterval:(NSTimeInterval)interval;
{
    return [self requestWithUrl:url
                   refreshCache:refreshCache
                      httpMedth:kGARequestMethodPOST
                         params:params
                       progress:progress
                        success:sucess
                           fail:fail
                timeoutInterval:interval];
}

+ (GAURLSessionTask *)deleteWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                            success:(GAResponseSuccess)sucess
                               fail:(GAResponseFail)fail
{
    return [self requestWithUrl:url
                   refreshCache:NO
                      httpMedth:kGARequestMethodDELETE
                         params:params
                       progress:nil
                        success:sucess
                           fail:fail
                timeoutInterval:GA_REQUEST_TIMEINTERVAL];
}

// patch 请求
+ (GAURLSessionTask *)patchWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                           success:(GAResponseSuccess)sucess
                              fail:(GAResponseFail)fail
{
    return [self requestWithUrl:url
                   refreshCache:NO
                      httpMedth:kGARequestMethodPATCH
                         params:params
                       progress:nil
                        success:sucess
                           fail:fail
                timeoutInterval:GA_REQUEST_TIMEINTERVAL];
}

/**
 *  网络请求
 *
 *  @param url          若不指定baseurl，可传完整的url
 *  @param refreshCache 是否刷新缓存
 *  @param httpMethod   请求方式
 *  @param params       参数
 *  @param progress     进度
 *  @param success      成功
 *  @param fail         失败
 *
 *  @return task
 */
+ (GAURLSessionTask *)requestWithUrl:(NSString *)url
                        refreshCache:(BOOL)refreshCache
                           httpMedth:(GARequestMethod)httpMethod
                              params:(NSDictionary *)params
                            progress:(GADownloadProgress)progress
                             success:(GAResponseSuccess)success
                                fail:(GAResponseFail)fail
                     timeoutInterval:(NSTimeInterval)interval;
{
    AFHTTPSessionManager *manager = [self manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = interval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    //获取完成的地址
    NSString *absolute = [self absoluteUrlWitGAath:url];
    
    if ([self baseUrl] == nil) {
        
        if ([NSURL URLWithString:url] == nil) {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    } else {
        NSURL *absouluteURL = [NSURL URLWithString:absolute];
        
        if (absouluteURL == nil) {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    GAURLSessionTask *session = nil;
    
    //GET
    if (httpMethod == kGARequestMethodGET)
    {
        //判断有没有开启缓存, 获取需要刷新缓存
        if (ga_cacheGet && !refreshCache)
        {
            //在缓存中获取响应数据
            id response = [GANetworkTool cacheResponseWithUrl:absolute parameters:params];
            
            if (response) {
                
                if (success)
                {
                    [self successResponse:response callback:success];
                    
                    if ([self isDebug])
                    {
                        [self logWithSuccessResponse:response url:url params:params];
                    }
                }
                
                return nil;
            }
        }
        
        //不从缓存里获取, 进行网络请求
        session = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
            if (progress)
            {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            //尝试解析responseObject,转化成字典
            [self successResponse:responseObject callback:success];
            
            //如果开启Get缓存
            if (ga_cacheGet)
            {
                [self cacheResponseObject:responseObject request:task.currentRequest parameters:params];
            }
            
            //从任务栈中移除栈
            [[self allTasks] removeObject:task];
            
            if ([self isDebug])
            {
                //打印成功
                [self logWithSuccessResponse:responseObject url:absolute params:params];
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [[self allTasks] removeObject:task];
            
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug])
            {
                [self logWithFailError:error url:absolute params:params];
            }
        }];
        
    }
    else if (httpMethod == kGARequestMethodPOST)
    {
        if (ga_cachePost && !refreshCache)
        {
            //获取缓存
            id responce = [GANetworkTool cacheResponseWithUrl:absolute parameters:params];
            
            if (responce)
            {
                if (success)
                {
                    [self successResponse:responce callback:success];
                    
                    if ([self isDebug])
                    {
                        [self logWithSuccessResponse:responce url:absolute params:params];
                    }
                }
                return nil;
            }
        }
        //POST请求
        
        session = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
            if (progress)
            {
                progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
            }
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            //成功回调
            [self successResponse:responseObject callback:success];
            
            if (ga_cachePost)
            {
                //保存缓存
                [self cacheResponseObject:responseObject request:task.currentRequest parameters:params];
                
            }
            
            [[self allTasks] removeObject:task];
            
            if ([self isDebug])
            {
                [self logWithSuccessResponse:responseObject url:absolute params:params];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [[self allTasks] removeObject:task];
            
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug])
            {
                [self logWithFailError:error url:absolute params:params];
            }
            
        }];
    }
    else if (httpMethod == kGARequestMethodDELETE)
    {
        //DELETE请求
        session = [manager DELETE:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [[self allTasks] removeObject:task];
            
            [self successResponse:responseObject callback:success];
            
            if ([self isDebug])
            {
                [self logWithSuccessResponse:responseObject url:absolute params:params];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [[self allTasks] removeObject:task];
            
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug])
            {
                [self logWithFailError:error url:absolute params:params];
            }
        }];
    }
    else if (httpMethod == kGARequestMethodPATCH)
    {
        // patch 请求
        session = [manager PATCH:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [[self allTasks] removeObject:task];
            
            [self successResponse:responseObject callback:success];
            
            if ([self isDebug])
            {
                [self logWithSuccessResponse:responseObject url:absolute params:params];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [[self allTasks] removeObject:task];
            
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug])
            {
                [self logWithFailError:error url:absolute params:params];
            }
            
        }];
    }
    
    if (session)
    {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

//TODO:上传文件
+ (GAURLSessionTask *)uploadFileWithUrl:(NSString *)url
                          uploadingFile:(NSString *)uploadingFile
                               progress:(GAUploadProgress)progress
                                succuss:(GAResponseSuccess)success
                                   fail:(GAResponseFail)fail
{
    if ([NSURL URLWithString:uploadingFile] == nil)
    {
        GALog(@"无效的文件路径: %@ . 请检查待上传文件是否存在", uploadingFile);
        return nil;
    }
    
    NSURL *uploadUrl = nil;
    
    if ([self baseUrl] == nil)
    {
        uploadUrl = [NSURL URLWithString:url];
    }
    else
    {
        uploadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]];
    }
    
    if (uploadUrl == nil)
    {
        GALog(@"URLString无效，无法生成URL。可能是URL中有中文或特殊字符，请尝试Encode URL");
        return nil;
    }
    
    //判断是否编码
    if ([self shouldEncode])
    {
        url = [self encodeUrl:url];
    }
    
    AFHTTPSessionManager *manager = [self manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:uploadUrl];
    GAURLSessionTask *session = nil;
    
    [manager uploadTaskWithRequest:request fromFile:[NSURL URLWithString:uploadingFile] progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress)
        {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [[self allTasks] removeObject:session];
        
        [self successResponse:responseObject callback:success];
        
        if (error)
        {
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug])
            {
                [self logWithFailError:error url:response.URL.absoluteString params:nil];
            }
        }
        else
        {
            if ([self isDebug])
            {
                [self logWithSuccessResponse:responseObject url:response.URL.absoluteString params:nil];
            }
        }
        
    }];
    if (session)
    {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

+ (GAURLSessionTask *)uploadWithImage:(NSData *)imageData
                                  url:(NSString *)url
                             filename:(NSString *)filename
                                 name:(NSString *)name
                             mimeType:(NSString *)mimeType
                           parameters:(NSDictionary *)parameters
                             progress:(GAUploadProgress)progress
                              success:(GAResponseSuccess)success
                                 fail:(GAResponseFail)fail
{
    if ([self baseUrl] == nil)
    {
        if ([NSURL URLWithString:url] == nil)
        {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    else
    {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil)
        {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    
    if ([self shouldEncode])
    {
        url = [self encodeUrl:url];
    }
    
    NSString *absolute = [self absoluteUrlWitGAath:url];
    
    AFHTTPSessionManager *manager = [self manager];
    
    GAURLSessionTask *session = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSString *imageFileName = filename;
        
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0)
        {
            imageFileName = [NSDate generateFileNameWithType:@"image.jpg"];
        }
        
        //上传图片, 以文件流格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress)
        {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self allTasks] removeObject:task];
        
        [self successResponse:responseObject callback:success];
        
        if ([self isDebug])
        {
            [self logWithSuccessResponse:responseObject url:absolute params:parameters];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[self allTasks] removeObject:task];
        
        if ([self isDebug])
        {
            [self logWithFailError:error url:absolute params:nil];
        }
        
    }];
    
    [session resume];
    
    if (session)
    {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

+ (GAURLSessionTask *)downloadWithUrl:(NSString *)url
                           saveToPath:(NSString *)saveToPath
                             progress:(GADownloadProgress)progressBlock
                              success:(GAResponseSuccess)success
                              failure:(GAResponseFail)failure
{
    if ([self baseUrl] == nil)
    {
        if ([NSURL URLWithString:url] == nil)
        {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    else
    {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil)
        {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [self manager];
    GAURLSessionTask *session = nil;
    
    session = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (progressBlock)
        {
            progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //下载完成后的保存路径
        return [NSURL URLWithString:saveToPath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [[self allTasks] removeObject:session];
        
        if (error == nil)
        {
            if (success)
            {
                success(filePath.absoluteString);
            }
            
            if ([self isDebug])
            {
                GALog(@"Download success for url : %@", [self absoluteUrlWitGAath:url]);
            }
        }
        else
        {
            [self handleCallbackWithError:error fail:failure];
            
            if ([self isDebug])
            {
                GALog(@"Download fail for url : %@, reason : %@", [self absoluteUrlWitGAath:url], [error description]);
            }
        }
        
    }];
    
    [session resume];
    if (session)
    {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

#pragma mark - Private

//获取对应的manager
+ (AFHTTPSessionManager *)manager
{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = ga_enabledActivityIndicator;
    
    AFHTTPSessionManager *manager = nil;
    
    if ([self baseUrl] != nil)
    {
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self baseUrl]]];
    }
    else
    {
        manager = [AFHTTPSessionManager manager];
    }
    
    switch (ga_requestType) {
        case kGARequestTypeJSON: {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        }
        case kGARequestTypePlainText: {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        }
        default:
            break;
    }
    
    switch (ga_responseType) {
        case kGAResponseTypeJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case kGAResponseTypeXML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
        case kGAResponseTypeData: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        default:
            break;
    }
    //允许非权威机构颁发的证书
    manager.securityPolicy.allowInvalidCertificates = YES;
    //也不验证域名一致性
    manager.securityPolicy.validatesDomainName = NO;
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    for (NSString *key in ga_httpHeaders.allKeys)
    {
        if (ga_httpHeaders[key] != nil) {
            
            [manager.requestSerializer setValue:ga_httpHeaders[key] forHTTPHeaderField:key];
        }
    }
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"application/xml",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    
    // 设置允许同时最大并发数量，过大容易出问题
    manager.operationQueue.maxConcurrentOperationCount = 5;
    return manager;
}

//打印成功数据
+ (void)logWithSuccessResponse:(id)response url:(NSString *)url params:(NSDictionary *)params
{
    GALog(@"\nRequest success, URL: %@\n params:%@\n responce:%@\n\n",
          [self generateGETAbsoluteURL:url params:params],
          params?params:@"",
          [self tryToParseData:response]);
}

//TODO:打印失败请求
+ (void)logWithFailError:(NSError *)error url:(NSString *)url params:(id)params
{
    NSString *format = @" params: ";
    if (params == nil || ![params isKindOfClass:[NSDictionary class]])
    {
        format = @"";
        params = @"";
    }
    
    GALog(@"\n");
    
    if ([error code] == NSURLErrorCancelled)
    {
        GALog(@"请求被手动取消, URL:%@ %@%@\n\n",
              [self generateGETAbsoluteURL:url params:params],
              format,
              params);
    }
    else
    {
        GALog(@"请求失败, URL: %@ %@%@\n errorInfos:%@\n\n",
              [self generateGETAbsoluteURL:url params:params],
              format,
              params,
              [error localizedDescription]);
    }
}

//获取完整的地址
+ (NSString *)absoluteUrlWitGAath:(NSString *)path
{
    if (path == nil || path.length == 0)
    {
        return @"";
    }
    
    if ([self baseUrl] == nil || [[self baseUrl] length] == 0)
    {
        return path;
    }
    
    NSString *absoluteUrl = path;
    
    if (![path hasPrefix:@"http://"] && ![path hasPrefix:@"https://"]) {
        
        absoluteUrl = [NSString stringWithFormat:@"%@%@", [self baseUrl], path];
    }
    
    return absoluteUrl;
}

//生成完整的路径, 仅对一级字典结构起作用
+ (NSString *)generateGETAbsoluteURL:(NSString *)url params:(id)params
{
    if (params == nil || ![params isKindOfClass:[NSDictionary class]] || [(NSDictionary *)params count] == 0) {
        return url;
    }
    
    //解析params, 然后拼接
    NSString *queries = @"";
    for (NSString *key in params)
    {
        id value = [params objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]])
        {
            continue;
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            continue;
        }
        else if ([value isKindOfClass:[NSSet class]])
        {
            continue;
        }
        else
        {
            queries = [NSString stringWithFormat:@"%@%@=%@&",
                       (queries.length == 0 ? @"&" : queries),
                       key,
                       value];
        }
    }
    
    //参数本分庞斑成功
    if (queries.length > 1)
    {
        queries = [queries substringToIndex:queries.length - 1];
    }
    
    if (([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) && queries.length > 1)
    {
        if ([url rangeOfString:@"?"].location != NSNotFound || [url rangeOfString:@"#"].location != NSNotFound)
        {
            url = [NSString stringWithFormat:@"%@%@", url, queries];
        }
        else
        {
            queries = [queries substringFromIndex:1];
            url = [NSString stringWithFormat:@"%@?%@", url, queries];
        }
    }
    
    return url.length == 0 ? queries : url;
}

//尝试解析数据
+ (id)tryToParseData:(id)responseData
{
    if ([responseData isKindOfClass:[NSData class]])
    {
        // 尝试解析成JSON
        if (responseData == nil)
        {
            return responseData;
        }
        else
        {
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
            
            if (error != nil)
            {
                return responseData;
            }
            else
            {
                return response;
            }
        }
    }
    else
    {
        return responseData;
    }
}

//尝试解析返回数据
+ (void)successResponse:(id)responseData callback:(GAResponseSuccess)success {
    if (success) {
        success([self tryToParseData:responseData]);
    }
}

//TODO:从缓存中获取缓存数据

//从缓存中获取响应数据
+ (id)cacheResponseWithUrl:(NSString *)url parameters:(id)params {
    
    id cacheData = nil;
    
    //尝试在硬盘里面获取数据
    if (url)
    {
        //获取路径
        NSString *directoryPath = cachePath();
        
        //获取完整的地址
        NSString *absoluteUrl = [self generateGETAbsoluteURL:url params:params];
        
        //获取key, 可以是地址经过md5加密的
        NSString *key = [NSString hybnetworking_md5:absoluteUrl];
        
        NSString *path = [directoryPath stringByAppendingPathComponent:key];
        
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        if (data)
        {
            cacheData = data;
            
            GALog(@"Read data from cache for url: %@\n", url);
            
        }
    }
    
    return cacheData;
}

//堆url进行编码
+ (NSString *)encodeUrl:(NSString *)url {
    
    return [self ga_URLEncode:url];
}

//对url进行编码
+ (NSString *)ga_URLEncode:(NSString *)url
{
//    NSString *newString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                                    (CFStringRef)url,
//                                                                                    NULL,
//                                                                                    CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
//                                                                                    CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    
    NSString *newString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if (newString) {
        return newString;
    }
    
    return url;
}

//TODO:缓存数据

//将接受收到的响应数据进行缓存
+ (void)cacheResponseObject:(id)responseObject request:(NSURLRequest *)request parameters:params
{
    if (request && responseObject && ![responseObject isKindOfClass:[NSNull class]])
    {
        //获取缓存目录路径
        NSString *directoryPath = cachePath();
        
        NSError *error;
        
        //判断有没有这个目录文件夹
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            
            if (error)
            {
                GALog(@"创建缓存目录失败 : %@", error);
                return;
            }
        }
        
        //生成完整的URL, 包含参数
        NSString *absoluteUrl = [self generateGETAbsoluteURL:request.URL.absoluteString params:params];
        
        //将完成URL经过MD5加密生成key, ps:md5没有密匙, 加密更快, 不过更容易破解
        NSString *key = [NSString hybnetworking_md5:absoluteUrl];
        
        //完整的路径
        NSString *path = [directoryPath stringByAppendingPathComponent:key];
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSData *data = nil;
        
        if ([dict isKindOfClass:[NSData class]])
        {
            data = responseObject;
        }
        else
        {
            data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        }
        
        if (data && error == nil)
        {
            BOOL isOK = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
            
            if (isOK)
            {
                GALog(@"cache file ok for request : %@\n", absoluteUrl);
            }
            else
            {
                GALog(@"cache file error for request : %@\n", absoluteUrl);
            }
        }
        
    }
}

//管理回调的失败 (如果是取消导致的失败, 可以有取消后的回掉)
+ (void)handleCallbackWithError:(NSError *)error fail:(GAResponseFail)fail
{
    if ([error code] == NSURLErrorCancelled)
    {
        if (ga_shouldCallbackOnCancelRequest)
        {
            if (fail)
            {
                fail(error);
            }
        }
    }
    else
    {
        if (fail)
        {
            fail(error);
        }
    }
}

@end

#pragma end

#pragma mark - extension
@implementation GANetworkTool (Extension)

+ (GAURLSessionTask *)postJsonModelWithUrl:(NSString *)url
                              refreshCache:(BOOL)refreshCache
                                    params:(NSDictionary *)params
                                modelClass:(Class)modelClass
                                  progress:(GAPostProgress)progress
                                   success:(GAResponseModelSuccess)sucess
                                      fail:(GAResponseFail)fail
{
    if (modelClass == nil)
    {
        GALog(@"\n\nmodelClass == nil\n\n");
        return nil;
    }
    
    return  [self requestWithUrl:url
                    refreshCache:refreshCache
                       httpMedth:kGARequestMethodPOST
                          params:params
                        progress:progress
                         success:^(id response) {
                             
                             //成功
                             if (![response isKindOfClass:[NSDictionary class]])
                             {
                                 if (sucess)
                                 {
                                     sucess(response, nil);
                                 }
                             }
                             else
                             {
                                 //其实可以不用YYModel, 自己写个, 不过怎么说呢, 有就用呗
                                 id model = [[modelClass class] yy_modelWithJSON:response];
                                 
                                 if (sucess)
                                 {
                                     sucess(response, model);
                                 }
                             }
                             
                         }
                            fail:fail
                 timeoutInterval:GA_REQUEST_TIMEINTERVAL];
}

+ (GAURLSessionTask *)postJsonModelWithUrl:(NSString *)url
                              refreshCache:(BOOL)refreshCache
                                    params:(NSDictionary *)params
                                modelClass:(Class)modelClass
                                 requester:(id)requester
                                       key:(NSString *)key
                                  progress:(GAPostProgress)progress
                                   success:(GAResponseModelSuccess)sucess
                                      fail:(GAResponseFail)fail
{
    if (requester == nil || key == nil)
    {
        GALog(@"\n\nrequester == nil, or key == nil\n\n");
        return nil;
    }
    
    return [self postJsonModelWithUrl:url
                         refreshCache:refreshCache
                               params:params
                           modelClass:modelClass
                             progress:progress
                              success:^(id response, NSObject *model) {
                                  
                                  [requester setValue:model forKey:key];
                                  
                                  if (sucess)
                                  {
                                      sucess(response, model);
                                  }
                                  
                              }
                                 fail:fail];
}

+ (GAURLSessionTask *)postArrayModelWithUrl:(NSString *)url
                               refreshCache:(BOOL)refreshCache
                                     params:(NSDictionary *)params
                                 modelClass:(Class)modelClass
                                   progress:(GAPostProgress)progress
                                    success:(GAResponseArraySuccess)sucess
                                       fail:(GAResponseFail)fail
{
    if (modelClass == nil)
    {
        NSLog(@"\n\nmodelClass == nil\n\n");
        return nil;
    }
    
    return [self requestWithUrl:url
                   refreshCache:refreshCache
                      httpMedth:kGARequestMethodPOST
                         params:params
                       progress:progress
                        success:^(id response) {
                            
                            if (![response isKindOfClass:[NSArray class]])
                            {
                                if (![response isEqualToString:@""])
                                {
                                    sucess(response, nil);
                                    return;
                                }
                                response = [NSArray array];
                            }
                            
                            NSMutableArray *models = [NSMutableArray array];
                            
                            for (NSDictionary *model in response)
                            {
                                [models addObject:[[modelClass class] yy_modelWithJSON:model]];
                            }
                            
                            if (sucess)
                            {
                                sucess(response, models);
                            }
                            
                        }
                           fail:fail
                timeoutInterval:GA_REQUEST_TIMEINTERVAL];
}

+ (GAURLSessionTask *)postArrayModelWithUrl:(NSString *)url
                               refreshCache:(BOOL)refreshCache
                                     params:(NSDictionary *)params
                                 modelClass:(Class)modelClass
                                  requester:(id)requester
                                        key:(NSString *)key
                                   progress:(GAPostProgress)progress
                                    success:(GAResponseArraySuccess)sucess
                                       fail:(GAResponseFail)fail
{
    // 检查实参
    if (requester == nil || key == nil)
    {
        
        GALog(@"\n\nrequester == nil, or key == nil\n\n");
        
        return nil;
    }
    
    return [self postArrayModelWithUrl:url
                          refreshCache:refreshCache
                                params:params
                            modelClass:modelClass
                              progress:progress
                               success:^(id response, NSMutableArray *array) {
                                   
                                   [requester setValue:array forKey:key];
                                   
                                   if (sucess)
                                   {
                                       sucess(response, array);
                                   }
                               }
                                  fail:fail];
}


//TODO:异步上传多张图片
+ (GAURLSessionTask *)uploadWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                         imageArray:(NSArray *)imageArray
                           progress:(GAUploadProgress)progress
                            success:(GAResponseSuccess)success
                               fail:(GAResponseFail)fail
{
    if ([self baseUrl] == nil)
    {
        if ([NSURL URLWithString:url] == nil)
        {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    else
    {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil)
        {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    
    if ([self shouldEncode])
    {
        url = [self encodeUrl:url];
    }
    
    NSString *absolute = [self absoluteUrlWitGAath:url];
    
    AFHTTPSessionManager *manager = [self manager];
    
    GAURLSessionTask *session = [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (NSInteger i = 0; i < imageArray.count; i++)
        {
            UIImage *image = imageArray[i];
            NSData *imageData = UIImageJPEGRepresentation(image, 1);
            
            NSString *name = [NSDate generateFileNameWithType:[NSString stringWithFormat:@"image%ld", (long)i]];
            
            NSString *imageFileName = [NSDate generateFileNameWithType:[NSString stringWithFormat:@"image%ld.jpg", (long)i]];
            
            [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:@"image/jpg"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress)
        {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self allTasks] removeObject:task];
        
        [self successResponse:responseObject callback:success];
        
        if ([self isDebug])
        {
            [self logWithSuccessResponse:responseObject url:absolute params:params];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[self allTasks] removeObject:task];
        
        if ([self isDebug])
        {
            [self logWithFailError:error url:absolute params:nil];
        }
        
    }];
    
    [session resume];
    
    if (session)
    {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

//TODO:上传一段语音
+ (GAURLSessionTask *)uploadAudioDataWithUrl:(NSString *)url
                                   audioData:(NSData *)audioData
                                    progress:(GAUploadProgress)progress
                                     success:(GAResponseSuccess)success
                                        fail:(GAResponseFail)fail
{
    if (url == nil || audioData == nil)
    {
        return nil;
    }
    
    NSString *name = [NSDate generateFileNameWithType:@"audio"];
    
    NSString *audioFileName = [NSDate generateFileNameWithType:@"audio.amr"];
    
    return [self uploadDataWithUrl:url
                              data:audioData
                              name:name
                          fileName:audioFileName
                          mimeType:@"audio/amr"
                          progress:progress
                           success:success
                              fail:fail];
}


//TODO:通用格式上传一张图片
+ (GAURLSessionTask *)uploadImageWithUrl:(NSString *)url
                                   image:(NSData *)imageData
                                progress:(GAUploadProgress)progress
                                 success:(GAResponseSuccess)success
                                    fail:(GAResponseFail)fail
{
    if (url == nil || imageData == nil) {
        
        return nil;
        
    }
//    NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
    
    NSString *name = [NSDate generateFileNameWithType:@"image"];
    
    NSString *imageFileName = [NSDate generateFileNameWithType:@"image.jpg"];
    
    return [self uploadDataWithUrl:url
                              data:imageData
                              name:name
                          fileName:imageFileName
                          mimeType:@"image/jpg"
                          progress:progress
                           success:success
                              fail:fail];
}

//TODO:上传一段视频和一张首帧图
+ (GAURLSessionTask *)uploadVideoAndImageWithUrl:(NSString *)url
                                          params:(NSDictionary *)params
                                       videoData:(NSData *)videoData
                                           image:(UIImage *)image
                                        progress:(GAUploadProgress)progress
                                         success:(GAResponseSuccess)success
                                            fail:(GAResponseFail)fail
{
    if (url == nil || videoData == nil || image == nil) {
        
        return nil;
    }
    if ([self baseUrl] == nil)
    {
        if ([NSURL URLWithString:url] == nil)
        {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    else
    {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil)
        {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    
    if ([self shouldEncode])
    {
        url = [self encodeUrl:url];
    }
    
    NSString *absolute = [self absoluteUrlWitGAath:url];
    
    AFHTTPSessionManager *manager = [self manager];
    
    GAURLSessionTask *session = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSString *videoName = [NSDate generateFileNameWithType:@"av"];
        
        NSString *videoFileName = [NSDate generateFileNameWithType:@"av.mp4"];
        
        //上传数据, 以文件流格式
        [formData appendPartWithFileData:videoData name:videoName fileName:videoFileName mimeType:@"video/mpeg"];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
        
        NSString *imageName = [NSDate generateFileNameWithType:@"image"];
        
        NSString *imageFileName = [NSDate generateFileNameWithType:@"image.jpg"];
        
        [formData appendPartWithFileData:imageData name:imageName fileName:imageFileName mimeType:@"image/jpg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress)
        {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self allTasks] removeObject:task];
        
        [self successResponse:responseObject callback:success];
        
        if ([self isDebug])
        {
            [self logWithSuccessResponse:responseObject url:absolute params:nil];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[self allTasks] removeObject:task];
        
        if ([self isDebug])
        {
            [self logWithFailError:error url:absolute params:nil];
        }
        
    }];
    
    [session resume];
    
    if (session)
    {
        [[self allTasks] addObject:session];
    }
    
    return session;
    
    return nil;
}

//上传一段二进制数据
+ (GAURLSessionTask *)uploadDataWithUrl:(NSString *)url
                                   data:(NSData *)data
                                   name:(NSString *)name
                               fileName:(NSString *)fileName
                               mimeType:(NSString *)mimeType
                               progress:(GAUploadProgress)progress
                                success:(GAResponseSuccess)success
                                   fail:(GAResponseFail)fail
{
    if (data == nil || fileName || name == nil || mimeType == nil)
    {
        return nil;
    }
    
    if ([self baseUrl] == nil)
    {
        if ([NSURL URLWithString:url] == nil)
        {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    else
    {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil)
        {
            GALog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    
    if ([self shouldEncode])
    {
        url = [self encodeUrl:url];
    }
    
    NSString *absolute = [self absoluteUrlWitGAath:url];
    
    AFHTTPSessionManager *manager = [self manager];
    
    GAURLSessionTask *session = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        //上传数据, 以文件流格式
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress)
        {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self allTasks] removeObject:task];
        
        [self successResponse:responseObject callback:success];
        
        if ([self isDebug])
        {
            [self logWithSuccessResponse:responseObject url:absolute params:nil];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[self allTasks] removeObject:task];
        
        if ([self isDebug])
        {
            [self logWithFailError:error url:absolute params:nil];
        }
        
    }];
    
    [session resume];
    
    if (session)
    {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

#pragma mark - 自定义表单上传图片或者文件

//除了AFNetworking支持的表单上传文件, 下面是自己写的一个(上传的是图片, 文件也差不多，文件传进来一个地址)
- (NSData *)getHttpBodyWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType image:(UIImage *)image
{
    NSString *boundary = @"与服务器定义的boundary";
    NSMutableData *dataM = [NSMutableData data];
    NSString *strTop = [NSString stringWithFormat:@"--%@\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\nContent-type: %@\n\n", boundary, name, fileName, mimeType];
    NSString *strBottom = [NSString stringWithFormat:@"\n--%@--", boundary];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    [dataM appendData:[strTop dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData:imageData];
    [dataM appendData:[strBottom dataUsingEncoding:NSUTF8StringEncoding]];
    
    return dataM;
}

- (void)uploadFileWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType image:(UIImage *)image
{
    /*
     这是表单请求体里面的构造方式
     
     ---------boundary
     Content-Disposition; form-data; name="name"; filename="filename"
     Content-Type: type
     
     文件数据(data);
     ---------boundary--
     
     
     这是请求头的需要添加的
     Content-Length dataLength
     Content-Type multipart/form-data; boundary=boundary
     */
    //创建url
    NSString *urlStr = @"http://www.我们的路径.com";
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    //创建请求，上传文件或者图片一般都是post
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    //构建数据
    NSData *data = [self getHttpBodyWithName:name fileName:fileName mimeType:mimeType image:image];
    request.HTTPBody = data;
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", @"与服务器定义的boundary"] forHTTPHeaderField:@"Content-Type"];
    
    //创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error)
        {
            NSString *dataStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",dataStr);
        }
        else
        {
            NSLog(@"error is :%@",error.localizedDescription);
        }
        
    }];
    [uploadTask resume];
}

#pragma end
@end


