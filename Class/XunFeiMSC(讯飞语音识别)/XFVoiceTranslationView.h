//
//  XFVoiceTranslationView.h
//  Demo
//
//  Created by YanSY on 2018/6/4.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "BaseView.h"

@interface XFVoiceTranslationView : BaseView

@property (nonatomic , strong) UILabel                    * titleLabel;
@property (nonatomic , strong) UIButton                   * setUpBtn;
@property (nonatomic , strong) UITextView                 * textView;

@property (nonatomic , strong) UIButton                   * startRecBtn;
@property (nonatomic , strong) UIButton                   * stopRecBtn;
@property (nonatomic , strong) UIButton                   * cancelRecBtn;

@end
