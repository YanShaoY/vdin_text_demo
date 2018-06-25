//
//  GALocalNotificationService.m
//  Demo
//
//  Created by YanSY on 2017/12/29.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "GALocalNoticeService.h"
#import <UserNotifications/UserNotifications.h>

@interface GALocalNoticeService ()<UNUserNotificationCenterDelegate>{
    
}

/// 本地通知对象
@property (nonatomic , strong) UILocalNotification * localNote;

@end

@implementation GALocalNoticeService

#pragma mark - 初始化
/**
 初始化函数
 
 @return 返回本类对象
 */
+ (GALocalNoticeService * _Nonnull )sharedInstance{
    static GALocalNoticeService * service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] init];
        [service setLocalNotification];
    });
    return service;
}

/// 设置通知管理对象
- (void)setLocalNotification{
    self.localNote = [[UILocalNotification alloc]init];
    self.localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    self.localNote.alertAction = @"查看";
    self.localNote.hasAction = YES;
    self.localNote.alertLaunchImage = @"hill";
    self.localNote.soundName = UILocalNotificationDefaultSoundName;
    self.localNote.applicationIconBadgeNumber = 0;

}

#pragma mark -- 注册通知
/**
 注册通知
 */
- (void)registerLocalNotification{
    
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
        UNAuthorizationOptions options = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted){
                NSLog(@"通知打开成功");
            }
            if (error) {
                NSLog(@"UNUserNotification Error: %@", error);
            }
        }];

    }else{
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
}

#pragma mark -- 发送通知
- (void)sendNoticeWithId:(NSString *)identifier
                   Title:(NSString *)title
                subTitle:(NSString *)subTitle
                    Body:(NSString *)body
                    Info:(NSDictionary *)userInfo{
    
    [self sendNoticeWithId:identifier Title:title soundNamed:nil subTitle:subTitle Body:body Info:userInfo];
    
}

- (void)sendNoticeWithId:(NSString *)identifier
                   Title:(NSString *)title
              soundNamed:(NSString *)soundNamed
                subTitle:(NSString *)subTitle
                    Body:(NSString *)body
                    Info:(NSDictionary *)userInfo{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        if (state != UIApplicationStateActive) {
            return ;
        }
    });
    
    if (@available(iOS 10.0, *)) {
        
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.launchImageName               = @"LaunchImage";
        content.title    = title;//[NSString localizedUserNotificationStringForKey:title arguments:nil];
        content.subtitle = subTitle;//[NSString localizedUserNotificationStringForKey:subTitle arguments:nil];
        content.body     = body;//[NSString localizedUserNotificationStringForKey:body arguments:nil];
        content.userInfo = userInfo;
        content.badge    = @0;
        
        if (soundNamed == nil) {
            content.sound = [UNNotificationSound defaultSound];

        }else{
            content.sound = [UNNotificationSound soundNamed:soundNamed];
        }
        
        UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                      triggerWithTimeInterval:1 repeats:NO];
        
        NSString * requestId = identifier ? : @"Default";
        UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:requestId
                                                                              content:content
                                                                              trigger:trigger];
        
        
        UNUserNotificationCenter * localCenter = [UNUserNotificationCenter currentNotificationCenter];
        [localCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@",error);
            }
        }];
        
    }else{
        self.localNote.alertTitle = title;
        self.localNote.alertBody = body;
        self.localNote.userInfo = userInfo;
        [[UIApplication sharedApplication] presentLocalNotificationNow:self.localNote];
    }
}



#pragma mark -- ios10 以后通知的代理方法
// 当应用在前台的时候，收到本地通知，是用什么方式来展现。系统给了三种形式：
//代理回调方法，通知即将展示的时候
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    if (@available(iOS 10.0, *)) {
        completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    } else {
        completionHandler(UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    }
}

// 这个方法是在后台或者程序被杀死的时候，点击通知栏调用的，在前台的时候不会被调用
//用户与通知进行交互后的response，比如说用户直接点开通知打开App、用户点击通知的按钮或者进行输入文本框的文本
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    
    if (@available(iOS 10.0, *)) {
        UNNotificationRequest *request = response.notification.request;
        
        if ([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) return;
        
        NSString * identifer = request.identifier;
        if ([identifer isEqualToString:@"GPS_Permissions_Error"]) {
            [self performSelector:@selector(JumpToSetup) withObject:nil afterDelay:1];
        }
    } else {
//        BaseLog(@"不处理");
    }
    
    completionHandler();
}

- (void)JumpToSetup{
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


@end



















