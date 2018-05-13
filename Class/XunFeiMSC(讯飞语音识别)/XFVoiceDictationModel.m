//
//  XFVoiceDictationModel.m
//  Demo
//
//  Created by YanSY on 2018/5/13.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XFVoiceDictationModel.h"

@implementation XFVoiceDictationModel

#pragma mark -- 按钮初始化;
- (UIButton *)createButtonWithTitle:(NSString *)title{
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = UIColorFromRGBA(0x5C96FF, 1);
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 6.f;
    [button setTitleColor:UIColorFromRGBA(0xFFFFFF, 1.f) forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
    
}





@end
