//
//  XFMscViewModel.h
//  Demo
//
//  Created by YanSY on 2018/5/16.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "BaseModel.h"

@interface XFMscViewModel : BaseModel

/**
 创建一个按钮
 
 @param title 按钮文字
 @return 初始化后的按钮
 */
- (UIButton *)createButtonWithTitle:(NSString *)title;

@end
