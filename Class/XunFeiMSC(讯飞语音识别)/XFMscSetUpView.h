//
//  XFMscSetUpView.h
//  Demo
//
//  Created by YanSY on 2018/5/15.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "BaseView.h"

#import "SAMultisectorControl.h"
#import "AKPickerView.h"

/**
 设置视图的block回调

 @param configer 设置后的配置
 */
typedef void(^XFMscSetUpViewBlock)(id configer);

@interface XFMscSetUpView : BaseView

#pragma mark -- 显示视图
@property (strong, nonatomic) UIView  * setUpAlertBackView;   // 设置弹窗背景视图
@property (strong, nonatomic) UIView  * toolView;             // 工具条
@property (strong, nonatomic) UILabel * titleLabel;           // 标题

@property (strong, nonatomic) SAMultisectorControl * roundSlider;  // 圆形滑块
@property (strong, nonatomic) SAMultisectorSector  * internalSec;  // 内部滑动控件
@property (strong, nonatomic) SAMultisectorSector  * middleSec;    // 中间滑动控件
@property (strong, nonatomic) SAMultisectorSector  * outsideSec;   // 外部滑动控件

@property (strong, nonatomic) UILabel * leftLabel;            // 左边文字
@property (strong, nonatomic) UILabel * centerLabel;          // 左边文字
@property (strong, nonatomic) UILabel * rightLabel;           // 右边文字

@property (strong, nonatomic) UILabel * internalSecShow;      // 内部滑动控件数值显示
@property (strong, nonatomic) UILabel * middleSecShow;        // 中间滑动控件数值显示
@property (strong, nonatomic) UILabel * outsideSecShow;       // 外部滑动控件数值显示

@property (strong, nonatomic) UILabel * pickerViewTitle;      // 选择器视图标题
@property (strong, nonatomic) AKPickerView * accentPicker;    // 选择器视图

@property (strong, nonatomic) UILabel * firstSegTitle;        // 第一个分段选择器标题
@property (strong, nonatomic) UISegmentedControl * firstSeg;  // 第一个分段选择器

@property (strong, nonatomic) UILabel * secondSegTitle;       // 第二个分段选择器标题
@property (strong, nonatomic) UISegmentedControl * secondSeg; // 第二个分段选择器

/**
 显示设置页面

 @param configer 原始配置
 @param block 返回修改后的配置
 */
+ (void)disPlaySetUpView:(id)configer WithBlock:(XFMscSetUpViewBlock)block;

@end




