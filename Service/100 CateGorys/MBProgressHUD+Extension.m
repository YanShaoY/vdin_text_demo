//
//  MBProgressHUD+Extension.m
//  Demo
//
//  Created by YanSY on 2017/12/26.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "MBProgressHUD+Extension.h"

static const CGFloat kDetailsLabelFontSize = 16.f;

@implementation MBProgressHUD (Extension)

/**
 提示文本, 指定延长时间
 
 @param text 文本
 @param view backView
 @param time 显示时间
 */
+ (void)hudWithText:(NSString*)text toView:(UIView*)view DealyTime:(NSInteger)time
{
    [self hudWithText:text toView:view DealyTime:time complete:nil];
}

/**
 提示文本, 固定显示时间1s
 
 @param text 文本
 @param view backView
 */
+ (void)hudWithText:(NSString*)text toView:(UIView*)view
{
    [self hudWithText:text toView:view DealyTime:1];
}

//显示图片和文字
+ (void)hudWithText:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) {
        view = [[UIApplication sharedApplication] keyWindow];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.detailsLabel.text = text;
    hud.detailsLabel.font = [UIFont boldSystemFontOfSize:kDetailsLabelFontSize];
    [self customBackgroundViewWithHud:hud];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    hud.removeFromSuperViewOnHide = YES;
    hud.offset =  CGPointMake(hud.offset.y, (SCREENHEIGHT/2 - 80));
    [hud hideAnimated:YES afterDelay:0.7];
}

/**
 显示文本, 内部生成成功图片
 
 @param success 文本
 @param view    backView
 */
+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self hudWithText:success icon:@"hud_success.png" view:view];
}

/**
 显示文本, 内部生成失败图片
 
 @param error 文本
 @param view    backView
 */
+ (void)showError:(NSString *)error toView:(UIView *)view
{
    [self hudWithText:error icon:@"hud_error.png" view:view];
}

/**
 显示信息
 
 @param message 文本
 @param view    backView
 
 @return hud 对象,用户可以进行对此编辑
 */
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view
{
    if (view == nil) {
        view = [[UIApplication sharedApplication] keyWindow];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabel.text = message;
    hud.detailsLabel.font = [UIFont boldSystemFontOfSize:kDetailsLabelFontSize];
    [self customBackgroundViewWithHud:hud];
    hud.removeFromSuperViewOnHide = YES;
    
    return hud;
}

/**
 隐藏 hud
 
 @param view 哪个 backView
 */
+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) {
        view = [[UIApplication sharedApplication] keyWindow];
    }
    [self hideHUDForView:view animated:YES];
}

/**
 隐藏 hud
 */
+ (void)hideHUD
{
    [self hideHUDForView:nil];
}

/**
 显示文本
 
 @param text          文本
 @param view          backView
 @param interval      时长
 @param completeBlock 完成后的回调
 */
+ (void)hudWithText:(NSString *)text toView:(UIView *)view DealyTime:(NSTimeInterval)interval complete:(void (^)(void))completeBlock
{
    if (view == nil) {
        view = [[UIApplication sharedApplication] keyWindow];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = text;
    hud.detailsLabel.font = [UIFont boldSystemFontOfSize:kDetailsLabelFontSize];
    hud.margin = 10.f;
    [self customBackgroundViewWithHud:hud];
    hud.removeFromSuperViewOnHide = YES;
    hud.offset =  CGPointMake(hud.offset.y, (SCREENHEIGHT/2 - 80));
    
    if (completeBlock) {
        
        hud.completionBlock = completeBlock;
    }
    
    [hud hideAnimated:YES afterDelay:interval];
}

+ (void)customBackgroundViewWithHud:(MBProgressHUD *)hud
{
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:.2f];
}
@end
