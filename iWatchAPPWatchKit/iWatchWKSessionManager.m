//
//  iWatchWKSessionManager.m
//  iWatchApp Extension
//
//  Created by YanSY on 2018/6/27.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "iWatchWKSessionManager.h"
// 导入通讯框架
#import <WatchConnectivity/WatchConnectivity.h>


@interface iWatchWKSessionManager ()<WCSessionDelegate>

/// 请求会话
@property (strong , nonatomic) WCSession * requestSession;

@end

@implementation iWatchWKSessionManager

#pragma mark - 初始化
/**
 初始化函数
 
 @return 返回本类对象
 */
+ (iWatchWKSessionManager * _Nonnull )sharedInstance{
    static iWatchWKSessionManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
//        [manager setLocalNotification];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
//        [self configuration];
    }
    return self;
}

#pragma mark -- 配置方法
- (void)configuration{
    //激活会话
    if([WCSession isSupported]){
        [self.requestSession activateSession];
    }
}

#pragma mark -- 公共方法
/// 获取会话激活状态

- (void)sendMessage:(NSDictionary<NSString *, id> *)message replyHandler:(nullable void (^)(NSDictionary<NSString *, id> *replyMessage))replyHandler errorHandler:(nullable void (^)(NSError *error))errorHandler{
    
    
}


#pragma mark -- 懒加载


@end
















