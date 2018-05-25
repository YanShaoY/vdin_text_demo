//
//  PopupView.h
//  MSCDemo
//
//  Created by iflytek on 13-6-7.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupView : UIView

/**
 提示文本，固定显示时间2s

 @param text 显示文本
 @param view 父视图
 */
+ (void)showPopWithText:(NSString*)text toView:(UIView*)view;

/**
 提示文本, 指定延长时间
 
 @param text 文本
 @param view backView
 @param time 显示时间 若为0 则永久显示
 */
+ (void)hudWithText:(NSString*)text toView:(UIView*)view DealyTime:(NSInteger)time;


#pragma mark -- 隐藏视图
/**
 隐藏弹窗
 */
+ (void)hidePopUp;

/**
 从父视图中隐藏弹窗
 
 @param view 父视图
 */
+ (void)hidePopUpForView:(UIView *)view;

@end
