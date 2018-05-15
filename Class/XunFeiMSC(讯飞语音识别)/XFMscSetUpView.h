//
//  XFMscSetUpView.h
//  Demo
//
//  Created by YanSY on 2018/5/15.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "BaseView.h"

typedef void(^XFMscSetUpViewBlock)(id configer);

@interface XFMscSetUpView : BaseView

+ (void)disPlaySetUpView:(id)configer WithBlock:(XFMscSetUpViewBlock)block;

@end
