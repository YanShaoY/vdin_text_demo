//
//  xunFeiMscPopMenuView.h
//  Demo
//
//  Created by YanSY on 2018/5/11.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "BaseView.h"

/**
 菜单按钮点击回调

 @param index 选中按钮位置
 */
typedef void(^menuBtClickedBlock)(NSUInteger index);

/**
 讯飞语音识别菜单栏
 */
@interface xunFeiMscPopMenuView : BaseView


/**
 弹窗菜单栏弹窗

 @param index 默认选中按钮的位置
 @param block 返回选中按钮的位置
 */
+ (void)showXFMscPopMenuViewWithType:(NSUInteger)index WithBlock:(menuBtClickedBlock)block;

@end
