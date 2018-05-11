//
//  CycleProgressView.h
//  Demo
//
//  Created by YanSY on 2017/11/29.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CycleProgressView : UIView

/**
 开始数字进度动画

 @param progess 设置进度 默认为1（100%）
 @param animation 动画时间 0-无动画
 */
- (void)startAnimationWithProgess:(CGFloat)progess andAnimation:(CGFloat)animation;

@end
