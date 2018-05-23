//
//  XFVoiceDictationView.h
//  Demo
//
//  Created by YanSY on 2018/5/13.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "BaseView.h"

@interface XFVoiceDictationView : BaseView

@property (nonatomic , strong) UILabel                    * titleLabel;
@property (nonatomic , strong) UIButton                   * setUpBtn;
@property (nonatomic , strong) UITextView                 * textView;
@property (nonatomic , strong) UIButton                   * startRecBtn;
@property (nonatomic , strong) UIButton                   * stopRecBtn;
@property (nonatomic , strong) UIButton                   * cancelRecBtn;
@property (nonatomic , strong) UIButton                   * audioStreamBtn;
@property (nonatomic , strong) UILabel                    * messageLabel;
@property (nonatomic , strong) UIButton                   * upContactBtn;
@property (nonatomic , strong) UIButton                   * upWordListBtn;

@end
