//
//  iWatchWKSessionManager.h
//  iWatchApp Extension
//
//  Created by YanSY on 2018/6/27.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WCSession.h>

@class WatchConnectivity;

/**
 iWatch端WKSession管理类
 */
@interface iWatchWKSessionManager : NSObject

/**
 初始化函数
 
 @return 返回本类对象
 */
+ (iWatchWKSessionManager * _Nonnull )sharedInstance;

///**
// 获取会话的激活状态
//
// @return 返回会话激活状态
// */
//- (WCSessionActivationState)getActivationState;

@end















