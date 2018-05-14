//
//  BaseVC.m
//  Demo
//
//  Created by YanSY on 2017/11/23.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "BaseVC.h"
#import <objc/runtime.h>
#import "CollapseAnimator.h"

@interface BaseVC ()<UIViewControllerTransitioningDelegate>

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00];
    [self edgesForExtendedLayoutForIPhoneX];
    [self runtimeReplaceAlert];
    
    [self configuration];
    [self addUI];
    [self addGesture];
    [self addRefresh];
    [self addConstraint];
    [self registerNotification];
    [self fetchData];
    [self removeNotification];
    
    //避免同时产生多个按钮事件
    [self setExclusiveTouchForButtons:self.view];
    
}

#pragma mark -- 设置边缘布局，针对于 iPhoneX
- (void)edgesForExtendedLayoutForIPhoneX
{
    if (@available(iOS 11, *)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    CollapseAnimator *animator = [[CollapseAnimator alloc] init];
    return animator;
}

#pragma mark -- 利用runtime来替换展现弹出框的方法
- (void)runtimeReplaceAlert
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method presentM = class_getInstanceMethod(self.class, @selector(presentViewController:animated:completion:));
        Method presentSwizzlingM = class_getInstanceMethod(self.class, @selector(YanSY_presentViewController:animated:completion:));
        method_exchangeImplementations(presentM, presentSwizzlingM);
    });
}

- (void)YanSY_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    
    if ([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
        // 换图标时的提示框的title和message都是nil，由此可特殊处理
        UIAlertController *alertController = (UIAlertController *)viewControllerToPresent;
        if (alertController.title == nil && alertController.message == nil) {
            // 是换图标的提示
            return;
        } else {
            // 其他提示还是正常处理
            [self YanSY_presentViewController:viewControllerToPresent animated:flag completion:completion];
            return;
        }
    }
    [self YanSY_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

#pragma mark -- 是否在window前端显示
- (BOOL)isCurrentViewControllerVisible
{
    return (self.isViewLoaded && self.view.window);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}
#pragma mark -- 所有子类都应该实现的方法
///配置
- (void)configuration{
//    BaseLog(@"");
}
///添加 UI
- (void)addUI{
//    BaseLog(@"");
}
///添加手势
- (void)addGesture{
//    BaseLog(@"");
}
///添加刷新
- (void)addRefresh{
//    BaseLog(@"");
}
///添加约束
- (void)addConstraint{
//    BaseLog(@"");
}
///注册通知
- (void)registerNotification{
//    BaseLog(@"");
}
///获取数据
- (void)fetchData{
//    BaseLog(@"");
}
///移除通知
- (void)removeNotification{
//    BaseLog(@"");
}

/**
 设置UIButton的ExclusiveTouch属性
 ****/
-(void)setExclusiveTouchForButtons:(UIView *)myView
{
    for (UIView * button in [myView subviews]) {
        if([button isKindOfClass:[UIButton class]])
        {
            [((UIButton *)button) setExclusiveTouch:YES];
        }
        else if ([button isKindOfClass:[UIView class]])
        {
            [self setExclusiveTouchForButtons:button];
        }
    }
}

@end



