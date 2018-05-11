//
//  UIButton+ImageTitleSpacing.h
//  Demo
//
//  Created by YanSY on 2017/12/21.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MKButtonEdgeInsetsStyle) {
    MKButtonEdgeInsetsStyleTop,     // image在上，label在下
    MKButtonEdgeInsetsStyleLeft,    // image在左，label在右
    MKButtonEdgeInsetsStyleBottom,  // image在下，label在上
    MKButtonEdgeInsetsStyleRight    // image在右，label在左
};

@interface UIButton (ImageTitleSpacing)

/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
/// style 布局样式，space titleLabel和imageView的间距
- (void)layoutButtonWithEdgeInsetsStyle:(MKButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;

/**
 *  设置button点击事件，扩大响应范围
 *
 *  @param top 上边距
 *  @param right 右边距
 *  @param bottom 下边距
 *  @param left 左边距
 */
/// top 上边距 right 右边距   bottom 下边距  left 左边距
- (void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

@end
