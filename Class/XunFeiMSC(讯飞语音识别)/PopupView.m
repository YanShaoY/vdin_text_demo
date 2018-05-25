//
//  PopupView.m
//  MSCDemo
//
//  Created by iflytek on 13-6-7.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//


#import "PopupView.h"

@interface PopupView ()

@property (nonatomic , strong) UILabel *  textLabel;
@property (nonatomic , strong) UIView  *  ParentView;
@property (nonatomic , assign) int queueCount;


@end

@implementation PopupView

#pragma mark -- 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.5f];
        self.layer.cornerRadius = 10.f;
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 150, 10)];
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont systemFontOfSize:17];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
        _queueCount = 0;
    }
    return self;
}

#pragma mark -- 弹出视图
/**
 提示文本，固定显示时间2s
 
 @param text 显示文本
 @param view 父视图
 */
+ (void)showPopWithText:(NSString*)text toView:(UIView*)view{
    
    [self hudWithText:text toView:view DealyTime:2];
}

/**
 提示文本, 指定延长时间
 
 @param text 文本
 @param view backView
 @param time 显示时间
 */
+ (void)hudWithText:(NSString *)text toView:(UIView *)view DealyTime:(NSInteger)time{
    
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    PopupView * popView = [self popUpFormView:view];
    if (!popView) {
        popView = [[PopupView alloc]init];
    }
    [popView hudWithText:text toView:view DealyTime:time];
}



- (void)hudWithText:(NSString*)text toView:(UIView*)view DealyTime:(NSInteger)time{
    
    _queueCount ++;
    self.ParentView = view;
    self.textLabel.text = text;
    self.alpha = 1.0f;
    [_textLabel sizeToFit];

    
    CGRect frame = CGRectMake(5, 0, _textLabel.frame.size.width, _textLabel.frame.size.height);
    
    _textLabel.frame = frame;
    _textLabel.frame = CGRectMake(_textLabel.frame.origin.x, _textLabel.frame.origin.y+10, _textLabel.frame.size.width, _textLabel.frame.size.height);
    
    frame =  CGRectMake((_ParentView.frame.size.width - frame.size.width)/2, self.frame.origin.y, _textLabel.frame.size.width+10, _textLabel.frame.size.height+20);
    self.frame = frame;
    
    CGPoint centerPoint = CGPointMake(self.ParentView.center.x, self.ParentView.center.y);
    self.center= centerPoint;
    
    if (self.ParentView != nil) {
        [self.ParentView addSubview:self];
    }
    
    [UIView animateWithDuration:time delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        if (self.queueCount == 1) {
            [self removeFromSuperview];
        }
        self.queueCount--;
    }];
    
}

#pragma mark -- 隐藏视图
/**
 隐藏弹窗
 */
+ (void)hidePopUp{
    
    [self hidePopUpForView:nil];
}

/**
 从父视图中隐藏弹窗

 @param view 父视图
 */
+ (void)hidePopUpForView:(UIView *)view{
    
    if (view == nil) {
        view = [[UIApplication sharedApplication] keyWindow];
    }
    
    PopupView * popUpView = [self popUpFormView:view];
    if (popUpView != nil) {
        [popUpView removeFromSuperview];
    }
    
}

#pragma mark -- 从父视图中寻找对应弹窗
/**
 从父视图中寻找对应弹窗

 @param view 父视图
 @return 返回寻找到的弹窗
 */
+ (PopupView *)popUpFormView:(UIView *)view{
    
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            PopupView * popView = (PopupView *)subview;
            if (popView.ParentView) {
                return popView;
            }
        }
    }
    return nil;
}


@end

