//
//  WSTopSlidMenuView.h
//  Demo
//
//  Created by YanSY on 2018/6/20.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WSTopSlidMenuViewDelegate;

@interface WSTopSlidMenuView : UIView

#pragma mark -- 代理及参数设置
/// 设置委托对象
@property (nonatomic ,assign) id<WSTopSlidMenuViewDelegate> delegate;

#pragma mark -- 公共方法
/**
 设置菜单栏选中状态
 
 @param selectCount 0:房态 1:订单 2:统计
 */
- (void)setSlidMenuViewSelectWithCount:(NSUInteger)selectCount;

/**
 被选中按钮查询

 @return 选中按钮 0:房态 1:订单 2:统计
 */
- (NSUInteger)selectBtCount;

@end

#pragma mark -- 代理方法
@protocol WSTopSlidMenuViewDelegate <NSObject>

/**
 菜单按钮选中事件回调

 @param slidMenuView 菜单栏视图
 @param buttonCount 选中菜单按钮
 */
- (void)WSTopSlidMenuView:(WSTopSlidMenuView *)slidMenuView ClickWithButtonCount:(NSUInteger)buttonCount;

/**
 菜单栏搜索按钮点击回调

 @param slidMenuView 菜单栏视图
 @param sender 搜索按钮
 */
- (void)WSTopSlidMenuView:(WSTopSlidMenuView *)slidMenuView searchButtonAction:(UIButton *)sender;

/**
 菜单栏加好按钮点击回调

 @param slidMenuView 菜单栏视图
 @param sender 加好按钮
 */
- (void)WSTopSlidMenuView:(WSTopSlidMenuView *)slidMenuView addButtonAction:(UIButton *)sender;

@end












