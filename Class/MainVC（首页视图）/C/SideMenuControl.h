//
//  SideMenuVC.h
//  Demo
//
//  Created by YanSY on 2017/12/14.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 侧边栏tab类型

 - SideMenu_Tab_Type_Root: 主视图
 - SideMenu_Tab_Type_menu: 菜单栏
 */
typedef NS_ENUM(NSUInteger , SideMenu_Tab_Type) {
    SideMenu_Tab_Type_Root = 0,
    SideMenu_Tab_Type_menu = 1,
};

@class SideMenuControl;

@protocol SideMenuControlDelegate <NSObject>

@required
/**
 列表视图cell个数代理方法

 @param tableType 列表视图的类型标识
 @return 返回对应类型的cell个数
 */
- (NSInteger)numberOfListForTab:(SideMenu_Tab_Type)tableType;

/**
 列表视图cell子视图代理方法

 @param tableType 列表视图的类型标识
 @param row 列表视图cell的位置
 @return 返回对应位置cell的显示视图
 */
- (UIView *)viewForTabType:(SideMenu_Tab_Type)tableType andTabRow:(NSUInteger)row;

/**
 点击cell代理方法

 @param row 点击的行数
 @param tableType 被点击的tableview 类型标识
 */
- (void)didSelectAtRowNumber:(NSUInteger)row forTabType:(SideMenu_Tab_Type)tableType;

/**
 滑动cell代理方法

 @param row 滑动到的行数
 @param tableType 被滑动的tableview 类型标识
 */
- (void)didScrollAtRowNumber:(NSUInteger)row forTabType:(SideMenu_Tab_Type)tableType;

@end;


@interface SideMenuControl : UIView

#pragma mark -- parameter

@property (weak, nonatomic) id<SideMenuControlDelegate>delegate;

#pragma mark -- method
/**
 初始化显示视图

 @param frame 主视图大小
 @param srcController 主视图控制器
 @param percentage 菜单栏所占比例
 @return 返回当前视图
 */
- (instancetype)initWithFrame:(CGRect)frame withSource:(UIViewController *)srcController percentageToMenu:(CGFloat)percentage;

/**
 重置视图状态

 @param showType 需要显示的状态
 */
- (void)resetShowType:(SideMenu_Tab_Type)showType;

/**
 将列表视图滑动到指定位置

 @param tableType 列表视图的类型标识
 @param row 滑动的位置 行数
 */
- (void)scrollTabWithType:(SideMenu_Tab_Type)tableType toRowNumber:(NSUInteger)row;


@end













