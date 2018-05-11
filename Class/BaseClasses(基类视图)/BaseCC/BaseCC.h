//
//  BaseCC.h
//  Demo
//
//  Created by YanSY on 2017/12/20.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
// 寻找视图的VC控制器
#import "UIView+FindViewController.h"

@interface BaseCC : NSObject
/**
 跳转VC的回调
 */
@property (nonatomic, copy) UIViewController *(^VCGenerator)(id params);

/**
 初始化函数

 @return 返回本类对象
 */
+ (id)instanceCC;

/**
 获取背景视图View

 @return 返回背景视图
 */
- (UIView *)backView;

/**
 刷新CC数据
 */
- (void)fetchData;

/**
 设置跳转VC回调

 @param VCGenerator 传入的回调
 */
- (void)setVCGenerator:(UIViewController * (^)(id params))VCGenerator;

@end


















