//
//  GANetworkTool.h
//  GAProduct
//
//  Created by sunlang on 2017/3/20.
//  Copyright © 2017年 ZDHT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#if DEBUG
#define GALog(s, ...) NSLog( @"[%@ in line %d] ===============>%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define GALog(s, ...)
#endif

#define GA_REQUEST_TIMEINTERVAL    30     //网络请求默认超时时间
#define GA_FILEUPLOAD_TIMEINTERVAL 300    //文件上传默认超时时间

/**
 *  下载进度
 *
 *  @param bytesRead      已下载的大小
 *  @param totalBytesRead 文件大小
 */
typedef void (^GADownloadProgress)(int64_t bytesRead,
int64_t totalBytesRead);

typedef GADownloadProgress GAGetProgress;
typedef GADownloadProgress GAPostProgress;

/**
 *  上传进度
 *
 *  @param bytesWritten      已上传的大小
 *  @param totalBytesWritten 总上传大小
 */
typedef void (^GAUploadProgress)(int64_t bytesWritten,
int64_t totalBytesWritten);


typedef NS_ENUM(NSUInteger, GAResponseType) {
    
    kGAResponseTypeJSON = 1,  //默认 JSON
    kGAResponseTypeXML  = 2,  //XML
    kGAResponseTypeData = 3   //其他类型数据, 默认会先JSON转换, 若失败, 需要自己转换
};

typedef NS_ENUM(NSUInteger, GARequestType) {
    kGARequestTypeJSON = 1, // 默认
    kGARequestTypePlainText = 2, // 普通text/html
};

@class NSURLSessionTask;

typedef NSURLSessionTask GAURLSessionTask;

//响应成功
typedef void (^GAResponseSuccess)(id response);

//响应失败
typedef void (^GAResponseFail)(NSError *error);

/**
 *  基于AFNetworking的网络层封装
 */

@interface GANetworkTool : NSObject

#pragma mark --------------------  config  --------------------
/**
 *  设置或更新baseUrl, 一般设置一次就行了
 *
 *  @param baseUrl 网络接口的基础url
 */
+ (void)updateBaseUrl:(NSString *)baseUrl;

/**
 *  获取baseUrl
 *
 *  @return baseUrl
 */
+ (NSString *)baseUrl;

/**
 *  是否开启网络请求动画, 默认不开启
 *
 *  @param enabled 开启
 */
+ (void)enableActivityIndicator:(BOOL)enabled;

/**
 *
 *	默认只缓存GET请求的数据，对于POST请求是不缓存的。如果要缓存POST获取的数据，需要手动调用设置
 *  对JSON类型数据有效，对于PLIST、XML不确定！
 *
 *	@param isCacheGet		默认为NO
 *	@param shouldCachePost	默认为NO
 */
+ (void)cacheGetRequest:(BOOL)isCacheGet shouldCachePost:(BOOL)shouldCachePost;

/**
 *  获取缓存总大小
 *
 *  @return 缓存大小
 */
+ (unsigned long long)totalCacheSize;

/**
 *  清除缓存
 */
+ (void)clearCache;

/**
 *  开启或关闭接口打印信息
 *
 *  @param isBug  开发期，最好打开，默认是NO
 */
+ (void)enableInterfaceDebug:(BOOL)isBug;

/**
 *  配置请求格式，默认为JSON。如果要求传XML或者PLIST，请在全局配置一下
 *
 *  @param requestType                   请求格式，默认为JSON
 *  @param responseType                  响应格式，默认为JSO
 *  @param shouldAutoEncode              YES or NO,默认为NO，是否自动encode url
 *  @param shouldCallbackOnCancelRequest 当取消请求时，是否要回调，默认为YES
 */
+ (void)configRequestType:(GARequestType)requestType
             responseType:(GAResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
  callbackOnCancelRequest:(BOOL)shouldCallbackOnCancelRequest;

/**
 *  配置公共的请求头，只调用一次即可，通常放在应用启动的时候配置就可以了
 *
 *  @param httpHeaders 需要将与服务器商定的固定参数设置即可
 */
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders;

/**
 *  取消所有请求
 */
+ (void)cancelAllRequest;

/**
 *	取消某个请求。如果是要取消某个请求，最好是引用接口所返回来的HYBURLSessionTask对象，
 *  然后调用对象的cancel方法。如果不想引用对象，这里额外提供了一种方法来实现取消某个请求
 *
 *	@param url				URL，可以是绝对URL，也可以是path（也就是不包括baseurl）
 */
+ (void)cancelRequestWithURL:(NSString *)url;

/**
 *  获取manager
 */
+ (AFHTTPSessionManager *)getSessionManager;

#pragma mark --------------------  request  --------------------


//TODO:GET 请求

/**
 *  GRT请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url          接口路径 如/path/getArticleList
 *  @param refreshCache 是否刷新缓存。由于请求成功也可能没有数据，对于业务失败，只能通过人为手动判断
 *  @param sucess       接口成功请求到数据的回调
 *  @param fail         接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (GAURLSessionTask *)getWithUrl:(NSString *)url
                    refreshCache:(BOOL)refreshCache
                         success:(GAResponseSuccess)sucess
                            fail:(GAResponseFail)fail;

//多一个params参数
+ (GAURLSessionTask *)getWithUrl:(NSString *)url
                    refreshCache:(BOOL)refreshCache
                          params:(NSDictionary *)params
                         success:(GAResponseSuccess)sucess
                            fail:(GAResponseFail)fail;
//多一个进度回调
+ (GAURLSessionTask *)getWithUrl:(NSString *)url
                    refreshCache:(BOOL)refreshCache
                          params:(NSDictionary *)params
                        progress:(GAGetProgress)progress
                         success:(GAResponseSuccess)sucess
                            fail:(GAResponseFail)fail
                 timeoutInterval:(NSTimeInterval)interval;

//TODO:POST 请求
/**
 *  POST请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url      接口路径，如/path/getArticleList
 *  @param refreshCache 是否刷新缓存
 *  @param params   接口中所需的参数，如@{"categoryid" : @(12)}
 *  @param success  接口成功请求到数据的回调
 *  @param fail     接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (GAURLSessionTask *)postWithUrl:(NSString *)url
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary *)params
                          success:(GAResponseSuccess)success
                             fail:(GAResponseFail)fail;
//多一个进度回调
+ (GAURLSessionTask *)postWithUrl:(NSString *)url
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary *)params
                         progress:(GAPostProgress)progress
                          success:(GAResponseSuccess)success
                             fail:(GAResponseFail)fail
                  timeoutInterval:(NSTimeInterval)interval;

//TODO:DELETE 请求
+ (GAURLSessionTask *)deleteWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                            success:(GAResponseSuccess)success
                               fail:(GAResponseFail)fail;


// patch 请求
+ (GAURLSessionTask *)patchWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                           success:(GAResponseSuccess)success
                              fail:(GAResponseFail)fail;

/**
 图片上传接口，若不指定baseurl，可传完整的url

 @param imageData 图片对象
 @param url 上传图片的接口路径，如/path/images/
 @param filename 给图片起一个名字，默认为当前日期时间,格式为"yyyyMMddHHmmss"，后缀为`jpg`
 @param name 与指定的图片相关联的名称，这是由后端写接口的人指定的，如imagefiles
 @param mimeType 默认为image/jpeg
 @param parameters 参数
 @param progress 上传进度
 @param success 上传成功回调
 @param fail 上传失败回调
 @return task
 */
+ (GAURLSessionTask *)uploadWithImage:(NSData *)imageData
                                  url:(NSString *)url
                             filename:(NSString *)filename
                                 name:(NSString *)name
                             mimeType:(NSString *)mimeType
                           parameters:(NSDictionary *)parameters
                             progress:(GAUploadProgress)progress
                              success:(GAResponseSuccess)success
                                 fail:(GAResponseFail)fail;
//TODO:文件上传和下载

/**
 *	上传文件操作
 *
 *	@param url					上传路径
 *	@param uploadingFile        待上传文件的路径
 *	@param progress             上传进度
 *	@param success				上传成功回调
 *	@param fail					上传失败回调
 *
 *	@return task
 */
+ (GAURLSessionTask *)uploadFileWithUrl:(NSString *)url
                          uploadingFile:(NSString *)uploadingFile
                               progress:(GAUploadProgress)progress
                                succuss:(GAResponseSuccess)success
                                   fail:(GAResponseFail)fail;

/**
 *  下载文件
 *
 *  @param url           下载URL
 *  @param saveToPath    下载到哪个路径下
 *  @param progressBlock 下载进度
 *  @param success       下载成功后的回调
 *  @param failure       下载失败后的回调
 */
+ (GAURLSessionTask *)downloadWithUrl:(NSString *)url
                           saveToPath:(NSString *)saveToPath
                             progress:(GADownloadProgress)progressBlock
                              success:(GAResponseSuccess)success
                              failure:(GAResponseFail)failure;
@end

#pragma mark -------------------------  Extension  -------------------------
typedef void (^GAResponseModelSuccess)(id response, NSObject *model);
typedef void (^GAResponseArraySuccess)(id response, NSMutableArray *array);

/**
 *  只针对POST请求，格式为JSON
 */
@interface GANetworkTool (Extension)

//TODO:POST 请求JSON模型对象

/**
 *  POST请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url          接口路径，如/path/getArticleList
 *  @param params       接口中所需的参数，如@{"categoryid" : @(12)}
 *  @param modelClass   模型名
 *  @param progress     进度回调
 *  @param fail         接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (GAURLSessionTask *)postJsonModelWithUrl:(NSString *)url
                              refreshCache:(BOOL)refreshCache
                                    params:(NSDictionary *)params
                                modelClass:(Class)modelClass
                                  progress:(GAPostProgress)progress
                                   success:(GAResponseModelSuccess)sucess
                                      fail:(GAResponseFail)fail;


+ (GAURLSessionTask *)postJsonModelWithUrl:(NSString *)url
                              refreshCache:(BOOL)refreshCache
                                    params:(NSDictionary *)params
                                modelClass:(Class)modelClass
                                 requester:(id)requester
                                       key:(NSString *)key
                                  progress:(GAPostProgress)progress
                                   success:(GAResponseModelSuccess)sucess
                                      fail:(GAResponseFail)fail;

//TODO:POST 请求JSON模型数组
/**
 *  POST请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url          接口路径，如/path/getArticleList
 *  @param params       接口中所需的参数，如@{"categoryid" : @(12)}
 *  @param modelClass   模型名
 *  @param progress     进度回调
 *  @param success      接口成功请求到数据的回调
 *  @param fail         接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (GAURLSessionTask *)postArrayModelWithUrl:(NSString *)url
                               refreshCache:(BOOL)refreshCache
                                     params:(NSDictionary *)params
                                 modelClass:(Class)modelClass
                                   progress:(GAPostProgress)progress
                                    success:(GAResponseArraySuccess)success
                                       fail:(GAResponseFail)fail;

+ (GAURLSessionTask *)postArrayModelWithUrl:(NSString *)url
                               refreshCache:(BOOL)refreshCache
                                     params:(NSDictionary *)params
                                 modelClass:(Class)modelClass
                                  requester:(id)requester
                                        key:(NSString *)key
                                   progress:(GAPostProgress)progress
                                    success:(GAResponseArraySuccess)success
                                       fail:(GAResponseFail)fail;

//TODO:上传一打图片
//TODO:图片上传

/**
 *	图片上传接口，若不指定baseurl，可传完整的url
 *
 *	@param url				上传图片的接口路径，如/path/images/
 *	@param params           参数
 *  @param imageArray       图片数组
 *	@param progress         上传进度
 *	@param success          上传成功回调
 *	@param fail				上传失败回调
 *
 *	@return 返回的对象中有可取消请求的API
 */
+ (GAURLSessionTask *)uploadWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                         imageArray:(NSArray *)imageArray
                           progress:(GAUploadProgress)progress
                            success:(GAResponseSuccess)success
                               fail:(GAResponseFail)fail;


//TODO:上传语音
/**
 *  上传一段语音, 若不指定baseur, 可传完整的url
 *
 *  @param url       上传图片的接口路径，如/path/images/
 *  @param audioData 语音数据
 *  @param progress  进度
 *  @param success   上传成功回调
 *  @param fail      上传失败回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (GAURLSessionTask *)uploadAudioDataWithUrl:(NSString *)url
                                   audioData:(NSData *)audioData
                                    progress:(GAUploadProgress)progress
                                     success:(GAResponseSuccess)success
                                        fail:(GAResponseFail)fail;


//TODO:通用格式上传一张图片

+ (GAURLSessionTask *)uploadImageWithUrl:(NSString *)url
                                   image:(NSData *)imageData
                                progress:(GAUploadProgress)progress
                                 success:(GAResponseSuccess)success
                                    fail:(GAResponseFail)fail;

//TODO:上传一段视频和一张首帧图
/**
 *  上传一段视频
 *
 *  @param url      url
 *  @param params   params
 *  @param videoData 视频数据
 *  @param image    首帧图
 *  @param progress  进度
 *  @param success   上传成功回调
 *  @param fail      上传失败回调
 *
 *  @return GAURLSessionTask
 */
+ (GAURLSessionTask *)uploadVideoAndImageWithUrl:(NSString *)url
                                          params:(NSDictionary *)params
                                       videoData:(NSData *)videoData
                                           image:(UIImage *)image
                                        progress:(GAUploadProgress)progress
                                         success:(GAResponseSuccess)success
                                            fail:(GAResponseFail)fail;


@end

