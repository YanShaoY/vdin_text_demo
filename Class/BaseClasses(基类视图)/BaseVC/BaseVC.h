//
//  BaseVC.h
//  Demo
//
//  Created by YanSY on 2017/11/23.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseVCProtocol <NSObject>

@optional

///配置
- (void)configuration;
///添加 UI
- (void)addUI;
///添加手势
- (void)addGesture;
///添加刷新
- (void)addRefresh;
///添加约束
- (void)addConstraint;
///注册通知
- (void)registerNotification;
///获取数据
- (void)fetchData;
///移除通知
- (void)removeNotification;

@end;

@interface BaseVC : UIViewController <BaseVCProtocol>

/**
 基类信息字典
 */
@property (nonatomic, strong) id info;

/**
 设置边缘布局，针对于 iPhoneX
 */
- (void)edgesForExtendedLayoutForIPhoneX;

/**
 是否在window前端显示

 @return YES/NO
 */
- (BOOL)isCurrentViewControllerVisible;

@end
