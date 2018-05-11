//
//  BaseView.h
//  Demo
//
//  Created by YanSY on 2017/12/20.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseView : UIView
/// 配置
- (void)configuration;
/// 添加 UI
- (void)addUI;
/// 添加约束
- (void)addConstraint;
/// 显示视图
- (void)showSelf;
/// 隐藏视图
- (void)dismissSelf;

@end
