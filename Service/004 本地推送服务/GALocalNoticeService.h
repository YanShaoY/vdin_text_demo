//
//  GALocalNotificationService.h
//  Demo
//
//  Created by YanSY on 2017/12/29.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 本地推送通知服务
 */
@interface GALocalNoticeService : NSObject

/**
 初始化函数
 
 @return 返回本类对象
 */
+ (GALocalNoticeService * _Nonnull )sharedInstance;

/**
 注册通知
 */
- (void)registerLocalNotification;

- (void)sendNoticeWithId:(NSString     *_Nullable)identifier
                   Title:(NSString     *_Nonnull )title
                subTitle:(NSString     *_Nullable)subTitle
                    Body:(NSString     *_Nonnull )body
                    Info:(NSDictionary *_Nullable)userInfo;

- (void)sendNoticeWithId:(NSString     *_Nullable)identifier
                   Title:(NSString     *_Nonnull )title
              soundNamed:(NSString     *_Nullable)soundNamed
                subTitle:(NSString     *_Nullable)subTitle
                    Body:(NSString     *_Nonnull )body
                    Info:(NSDictionary *_Nullable)userInfo;
@end








