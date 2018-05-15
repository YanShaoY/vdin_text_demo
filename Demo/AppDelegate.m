//
//  AppDelegate.m
//  Demo
//
//  Created by YanSY on 2017/11/21.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "AppDelegate.h"
#import "ChangeIconService.h"
#import "GASpeechTextMSCService.h"

#import "guidePage.h"
#import "MovieGuidePage.h"
#import "mainVC.h"


@interface AppDelegate ()

@end 

@implementation AppDelegate

#pragma mark --  NSLog(@"\n ===> 程序开始 !");
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[GALocalNoticeService sharedInstance]registerLocalNotification];

    // 000 Config ROOT VC
    UIViewController * vc = [[mainVC alloc] init];
    BaseNav * nav = [[BaseNav alloc] initWithRootViewController:vc];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];

    // 001 自动切换图标
//    [ChangeIconService automaticChangeIcon];
    
    // 002 引导页：指纹识别/人脸识别
//    [guidePage showGuideViewForWindow:self.window];
//    NSURL * movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"guideMovie" ofType:@"mp4"]];
//    [MovieGuidePage showGuideViewWithURL:movieURL];
    
    // 启动图片延时: 1秒
//    [NSThread sleepForTimeInterval:1];

    [GASpeechTextMSCService setMSCWithAPPId:@"5af397b8"];
    
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    
    keyboardManager.enable = NO; // 控制整个功能是否启用
    
    keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
    
    keyboardManager.enableAutoToolbar = NO; // 控制是否显示键盘上的工具条
    
    keyboardManager.shouldShowToolbarPlaceholder = YES; // 是否显示占位文字
    
    keyboardManager.placeholderFont = [UIFont fontWithName:@"HelveticaNeue" size:16]; // 设置占位文字的字体
    
    keyboardManager.keyboardDistanceFromTextField = 25.0f;
    
    
    return YES;
}

#pragma mark -->NSLog(@"\n ===> 程序挂起 !");  比如:当有电话进来或者锁屏，这时你的应用程会挂起，在这时，UIApplicationDelegate委托会收到通知，调用 applicationWillResignActive 方法，你可以重写这个方法，做挂起前的工作，比如关闭网络，保存数据。
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

#pragma mark --> NSLog(@"\n ===> 程序进入后台 !");
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

#pragma mark --> NSLog(@"\n ===> 程序进入前台 !");
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

}

#pragma mark -->  NSLog(@"\n ===> 程序重新激活 !"); 应用程序在启动时，在调用了 applicationDidFinishLaunching 方法之后也会调用 applicationDidBecomeActive 方法，所以你要确保你的代码能够分清复原与启动，避免出现逻辑上的bug。(大白话就是说:只要启动app就会走此方法)。
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

#pragma mark --> 当用户按下按钮，或者关机，程序都会被终止。当一个程序将要正常终止时会调用 applicationWillTerminate 方法。但是如果长主按钮强制退出，则不会调用该方法。这个方法该执行剩下的清理工作，比如所有的连接都能正常关闭，并在程序退出前执行任何其他的必要的工作.
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
