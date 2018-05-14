//
//  MBProgressHUD+Extension.h
//  Demo
//
//  Created by YanSY on 2017/12/26.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (Extension)

/**
 提示文本, 指定延长时间
 
 @param text 文本
 @param view backView
 @param time 显示时间
 */
+ (void)hudWithText:(NSString*)text toView:(UIView*)view DealyTime:(NSInteger)time;

/**
 提示文本, 固定显示时间1s
 
 @param text 文本
 @param view backView
 */
+ (void)hudWithText:(NSString*)text toView:(UIView*)view;

/**
 显示文本, 内部生成成功图片
 
 @param success 文本
 @param view    backView
 */
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

/**
 显示文本, 内部生成失败图片
 
 @param error 文本
 @param view    backView
 */
+ (void)showError:(NSString *)error toView:(UIView *)view;

/**
 显示信息
 
 @param message 文本
 @param view    backView
 
 @return hud 对象,用户可以进行对此编辑
 */
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;

/**
 隐藏 hud
 
 @param view 哪个 backView
 */
+ (void)hideHUDForView:(UIView *)view;

/**
 隐藏 hud
 */
+ (void)hideHUD;

/**
 显示文本
 
 @param text          文本
 @param view          backView
 @param interval      时长
 @param completeBlock 完成后的回调
 */
+ (void)hudWithText:(NSString *)text toView:(UIView *)view DealyTime:(NSTimeInterval)interval complete:(void (^)(void))completeBlock;

@end









