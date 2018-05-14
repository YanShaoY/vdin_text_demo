//
//  XFVoiceDictationModel.h
//  Demo
//
//  Created by YanSY on 2018/5/13.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "BaseModel.h"

@interface XFVoiceDictationModel : BaseModel



/**
 初始化语音听写界面的按钮

 @param title 按钮文字
 @return 初始化后的按钮
 */
- (UIButton *)createButtonWithTitle:(NSString *)title;

@end
