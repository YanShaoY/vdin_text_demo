//
//  XFMscSetUpView.m
//  Demo
//
//  Created by YanSY on 2018/5/15.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XFMscSetUpView.h"
#import "GASpeechTextMSCService.h"
#import "SAMultisectorControl.h"
#import "AKPickerView.h"

@interface XFMscSetUpView ()<AKPickerViewDataSource,AKPickerViewDelegate>

#pragma mark -- 返回block回调
@property (strong, nonatomic) XFMscSetUpViewBlock setUpAlertBlock;
@property (strong, nonatomic) id configer;

#pragma mark -- 显示视图
@property (strong, nonatomic) UIView  * setUpAlertBackView;   // 设置弹窗背景视图
@property (strong, nonatomic) UIView  * toolView;             // 工具条
@property (strong, nonatomic) UILabel * titleLabel;           // 标题

@property (strong, nonatomic) SAMultisectorControl * roundSlider; // 标题

@end

@implementation XFMscSetUpView

#pragma mark -- 创建弹窗单例
+ (XFMscSetUpView *)sharedCustomAlert{
    static XFMscSetUpView * customAlert = nil;
    CGRect frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    customAlert = [[XFMscSetUpView alloc]initWithFrame:frame];
    return customAlert;
}

- (void)safeAreaInsetsDidChange{
//    UIEdgeInsets safeInsets = self.safeAreaInsets;
    
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColorFromRGBA(0x999999, .5f);
        self.alpha = 0.f;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        [self configurationBackView];
        [self configurationToolView];

    }
    return self;
}

#pragma mark --实现类方法
+ (void)disPlaySetUpView:(id)configer WithBlock:(XFMscSetUpViewBlock)block{
    
    [[XFMscSetUpView sharedCustomAlert]disPlaySetUpView:configer WithBlock:block];
    
}

- (void)disPlaySetUpView:(id)configer WithBlock:(XFMscSetUpViewBlock)block{
    
    self.configer = configer;
    self.setUpAlertBlock = block;
    
    [self showSetUpAlert];
}

/// 配置背景视图
- (void)configurationBackView{
    if (!_setUpAlertBackView) {
        CGRect frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 500);
        _setUpAlertBackView = [[UIView alloc]initWithFrame:frame];
        _setUpAlertBackView.backgroundColor = [UIColor whiteColor];
    }
    [self addSubview:self.setUpAlertBackView];
}

/// 配置工具条
- (void)configurationToolView {
    self.toolView = [[UIView alloc] init];
    self.toolView.backgroundColor = UIColorFromRGBA(0xFFFFFF, 1.f);
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 44.5f, SCREENWIDTH, .5f);
    layer.backgroundColor = UIColorFromRGBA(0x999999, 1).CGColor;
    [_toolView.layer addSublayer:layer];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    [cancelBtn setTitleColor:UIColorFromRGBA(0xF83141, 1.f) forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    self.titleLabel.textColor = UIColorFromRGBA(0x000000, 1);
    self.titleLabel.text = @"听写设置";
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.backgroundColor = [UIColor clearColor];
    saveBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    [saveBtn setTitleColor:UIColorFromRGBA(0x5849B1, 1.f) forState:UIControlStateNormal];
    [saveBtn setTitle:@"确定" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.setUpAlertBackView addSubview:self.toolView];
    [self.toolView addSubview:cancelBtn];
    [self.toolView addSubview:self.titleLabel];
    [self.toolView addSubview:saveBtn];
    
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.setUpAlertBackView);
        make.height.mas_equalTo(45.f);
    }];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.toolView.mas_left).offset(10.f);
        make.centerY.equalTo(self.toolView.mas_centerY);
        make.width.mas_equalTo(45.f);
        make.height.mas_equalTo(30.f);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.toolView);
        make.left.equalTo(cancelBtn.mas_right);
        make.centerY.equalTo(self.toolView.mas_centerY);
        make.right.equalTo(saveBtn.mas_left);
    }];
    
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.toolView.mas_right).offset(-10.f);
        make.centerY.equalTo(self.toolView.mas_centerY);
        make.width.mas_equalTo(45.f);
        make.height.mas_equalTo(30.f);
    }];
}

#pragma mark - 按钮点击响应
- (void)saveBtnClick {
    [self dismissSetUpAlert];
    
//    if (self.fuelAlertBlock && self.selectFuelTypeStr) {
//        self.fuelAlertBlock(self.selectFuelTypeStr);
//    }
}

- (void)cancelBtnClick {
    [self dismissSetUpAlert];
}











#pragma mark -- 显示隐藏视图
- (void)showSetUpAlert{
    
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint center = self.setUpAlertBackView.center;
        center.y -= self.setUpAlertBackView.frame.size.height;
        self.setUpAlertBackView.center = center;
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
    }];
}

- (void)dismissSetUpAlert{
    
    [UIView animateWithDuration:0.3f animations:^{
        CGPoint center = self.setUpAlertBackView.center;
        center.y += self.setUpAlertBackView.frame.size.height;
        self.setUpAlertBackView.center = center;
    }];
    
    [UIView animateWithDuration:0.1f delay:0.3f options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.setUpAlertBackView removeFromSuperview];
        [self removeFromSuperview];
    }];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
