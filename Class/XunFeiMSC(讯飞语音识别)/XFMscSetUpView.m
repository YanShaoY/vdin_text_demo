//
//  XFMscSetUpView.m
//  Demo
//
//  Created by YanSY on 2018/5/15.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XFMscSetUpView.h"

#import "XFMscViewModel.h"

#import "GASpeechTextMSCService.h"
#import "SAMultisectorControl.h"
#import "AKPickerView.h"

@interface XFMscSetUpView ()<AKPickerViewDataSource,AKPickerViewDelegate>

#pragma mark -- 返回block回调
@property (strong, nonatomic) XFMscSetUpViewBlock setUpAlertBlock;
@property (strong, nonatomic) id configer;
@property (assign, nonatomic) CGFloat marginTop;

#pragma mark -- 显示视图
@property (strong, nonatomic) UIView  * setUpAlertBackView;   // 设置弹窗背景视图
@property (strong, nonatomic) UIView  * toolView;             // 工具条
@property (strong, nonatomic) UILabel * titleLabel;           // 标题

@property (strong, nonatomic) SAMultisectorControl * roundSlider;  // 圆形滑块
@property (strong, nonatomic) SAMultisectorSector  * internalSec;  // 内部滑动控件
@property (strong, nonatomic) SAMultisectorSector  * middleSec;    // 中间滑动控件
@property (strong, nonatomic) SAMultisectorSector  * outsideSec;   // 外部滑动控件

@property (strong, nonatomic) UILabel * leftLabel;           // 左边文字
@property (strong, nonatomic) UILabel * centerLabel;         // 左边文字
@property (strong, nonatomic) UILabel * rightLabel;          // 右边文字

@property (strong, nonatomic) UILabel * internalSecShow;     // 内部滑动控件数值显示
@property (strong, nonatomic) UILabel * middleSecShow;       // 中间滑动控件数值显示
@property (strong, nonatomic) UILabel * outsideSecShow;      // 外部滑动控件数值显示

@property (strong, nonatomic) UILabel * pickerViewTitle;     // 选择器视图标题
@property (strong, nonatomic) AKPickerView * accentPicker;   // 选择器视图

@property (strong, nonatomic) UILabel * firstSegTitle;       // 第一个分段选择器标题
@property (strong, nonatomic) UILabel * secondSegTitle;      // 第二个分段选择器标题

@end

@implementation XFMscSetUpView

#pragma mark -- 创建弹窗单例
+ (XFMscSetUpView *)sharedCustomAlert{
    static XFMscSetUpView * customAlert = nil;
    CGRect frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    customAlert = [[XFMscSetUpView alloc]initWithFrame:frame];
    return customAlert;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self == [super initWithFrame:frame]) {

        self.backgroundColor = UIColorFromRGBA(0xFFFFFF, .0f);
        self.alpha = 0.f;
        self.marginTop = 20.f;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        [self setupBackView];
        [self setupToolView];
        [self setupMultisectorControl];
    }
    return self;
}

- (void)safeAreaInsetsDidChange{
    UIEdgeInsets safeInsets = self.safeAreaInsets;
    self.marginTop = safeInsets.top;
}

#pragma mark --实现类方法
+ (void)disPlaySetUpView:(id)configer WithBlock:(XFMscSetUpViewBlock)block{
    
    [[XFMscSetUpView sharedCustomAlert]disPlaySetUpView:configer WithBlock:block];
    
}

- (void)disPlaySetUpView:(id)configer WithBlock:(XFMscSetUpViewBlock)block{
    
    self.configer = configer;
    self.setUpAlertBlock = block;
    
    [self needUpdateView];
    
//  [self setupAKPickerView];


    
    [self showSetUpAlert];
}

#pragma mark -- 视图配置
/// 配置背景视图
- (void)setupBackView{
    if (!_setUpAlertBackView) {
        CGRect frame = CGRectMake(SCREENWIDTH, 0, SCREENWIDTH, SCREENHEIGHT);
        _setUpAlertBackView = [[UIView alloc]initWithFrame:frame];
        _setUpAlertBackView.backgroundColor = UIColorFromRGBA(0xFFFFFF, .0f);
    }
    [self.setUpAlertBackView.subviews respondsToSelector:@selector(removeFromSuperview)];
    [self addSubview:self.setUpAlertBackView];
    
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Back"]];
    [self.setUpAlertBackView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.setUpAlertBackView);
    }];
}

/// 配置工具条
- (void)setupToolView {
    
    self.toolView = [[UIView alloc] init];
    self.toolView.backgroundColor = UIColorFromRGBA(0xFFFFFF, .0f);
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 43.f, SCREENWIDTH, 1.f);
    layer.backgroundColor = UIColorFromRGBA(0xFFFFFF, 1).CGColor;
    [_toolView.layer addSublayer:layer];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    [cancelBtn setTitleColor:UIColorFromRGBA(0xF83141, 1.f) forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = [XFMscViewModel createLabelWithFont:18 andTextColor:UIColorFromRGBA(0xFFFFFF, 1) andText:@"听写设置"];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.backgroundColor = [UIColor clearColor];
    saveBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    [saveBtn setTitleColor:UIColorFromRGBA(0x5C96FF, 1.f) forState:UIControlStateNormal];
    [saveBtn setTitle:@"确定" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.setUpAlertBackView addSubview:self.toolView];
    [self.toolView addSubview:cancelBtn];
    [self.toolView addSubview:self.titleLabel];
    [self.toolView addSubview:saveBtn];
    
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.setUpAlertBackView.mas_top).offset(self.marginTop);
        make.left.right.equalTo(self.setUpAlertBackView);
        make.height.mas_equalTo(44.f);
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

/// 设置圆形滑块
- (void)setupMultisectorControl{
    
    self.roundSlider = [[SAMultisectorControl alloc]init];
    [self.roundSlider addTarget:self action:@selector(multisectorValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIColor * redColor   = UIColorFromRGBA(0xF83141, 1.f);
    UIColor * blueColor  = UIColorFromRGBA(0x3B65FF, 1.f);
    UIColor * greenColor = UIColorFromRGBA(0x00F300, 1.f);
    
    self.internalSec = [SAMultisectorSector sectorWithColor:redColor];
    self.middleSec   = [SAMultisectorSector sectorWithColor:blueColor];
    self.outsideSec  = [SAMultisectorSector sectorWithColor:greenColor];
    
    [self.roundSlider addSector:self.internalSec];
    [self.roundSlider addSector:self.middleSec];
    [self.roundSlider addSector:self.outsideSec];
    
    // 标题
    self.leftLabel = [XFMscViewModel createLabelWithFont:13 andTextColor:redColor andText:@"内部滑块"];
    self.leftLabel.textAlignment = NSTextAlignmentCenter;
    
    self.centerLabel = [XFMscViewModel createLabelWithFont:13 andTextColor:blueColor andText:@"中间滑块"];
    self.centerLabel.textAlignment = NSTextAlignmentCenter;
    
    self.rightLabel = [XFMscViewModel createLabelWithFont:13 andTextColor:greenColor andText:@"外部滑块"];
    self.rightLabel.textAlignment = NSTextAlignmentCenter;
    
    // 数值
    self.internalSecShow = [XFMscViewModel createLabelWithFont:15 andTextColor:UIColorFromRGBA(0xFFFFFF, 1) andText:@"100"];
    self.internalSecShow.textAlignment = NSTextAlignmentCenter;
    
    self.middleSecShow = [XFMscViewModel createLabelWithFont:15 andTextColor:UIColorFromRGBA(0xFFFFFF, 1) andText:@"100"];
    self.middleSecShow.textAlignment = NSTextAlignmentCenter;
    
    self.outsideSecShow = [XFMscViewModel createLabelWithFont:15 andTextColor:UIColorFromRGBA(0xFFFFFF, 1) andText:@"100"];
    self.outsideSecShow.textAlignment = NSTextAlignmentCenter;
    
    // 添加视图
    [self.setUpAlertBackView addSubview:self.roundSlider];
    
    [self.setUpAlertBackView addSubview:self.leftLabel];
    [self.setUpAlertBackView addSubview:self.centerLabel];
    [self.setUpAlertBackView addSubview:self.rightLabel];
    
    [self.setUpAlertBackView addSubview:self.internalSecShow];
    [self.setUpAlertBackView addSubview:self.middleSecShow];
    [self.setUpAlertBackView addSubview:self.outsideSecShow];
    
    // 设置约束
    [self.roundSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolView.mas_bottom);
        make.left.right.equalTo(self.toolView);
        make.height.mas_equalTo(300.f);
    }];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.roundSlider.mas_bottom);
        make.left.equalTo(self.setUpAlertBackView.mas_left);
    }];
    
    [self.centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftLabel.mas_centerY);
        make.width.height.mas_equalTo(self.leftLabel);
        make.left.equalTo(self.leftLabel.mas_right);
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftLabel.mas_centerY);
        make.width.height.mas_equalTo(self.leftLabel);
        make.left.equalTo(self.centerLabel.mas_right);
        make.right.equalTo(self.setUpAlertBackView.mas_right);
    }];
    
    [self.internalSecShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftLabel.mas_bottom).offset(15.f);
        make.left.equalTo(self.setUpAlertBackView.mas_left);
    }];
    
    [self.middleSecShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.internalSecShow.mas_centerY);
        make.width.height.mas_equalTo(self.internalSecShow);
        make.left.equalTo(self.internalSecShow.mas_right);
    }];
    
    [self.outsideSecShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.internalSecShow.mas_centerY);
        make.width.height.mas_equalTo(self.internalSecShow);
        make.left.equalTo(self.middleSecShow.mas_right);
        make.right.equalTo(self.setUpAlertBackView.mas_right);
    }];
    
}


// 设置选择器视图
- (void)setupAKPickerView{
    
    // 选择器标题
    self.pickerViewTitle = [XFMscViewModel createLabelWithFont:17 andTextColor:UIColorFromRGBA(0x22A419, 1) andText:@"识别语种"];
    self.pickerViewTitle.textAlignment = NSTextAlignmentRight;
    
    // 选择器
    self.accentPicker = [[AKPickerView alloc]init];
    _accentPicker.delegate = self;
    _accentPicker.dataSource = self;
    _accentPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _accentPicker.textColor = [UIColor whiteColor];
    _accentPicker.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    _accentPicker.highlightedFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
    _accentPicker.highlightedTextColor = [UIColor colorWithRed:0.0 green:168.0/255.0 blue:255.0/255.0 alpha:1.0];
    _accentPicker.interitemSpacing = 20.0;
    _accentPicker.fisheyeFactor = 0.001;
    _accentPicker.pickerViewStyle = AKPickerViewStyle3D;
    _accentPicker.maskDisabled = false;
    
    // 第一个分段控制器标题
    self.firstSegTitle = [XFMscViewModel createLabelWithFont:17 andTextColor:UIColorFromRGBA(0x22A419, 1) andText:@"识别界面"];
    self.firstSegTitle.textAlignment = NSTextAlignmentRight;
    
    // 第二个分段控制器标题
    self.secondSegTitle = [XFMscViewModel createLabelWithFont:17 andTextColor:UIColorFromRGBA(0x22A419, 1) andText:@"识别标点"];
    self.secondSegTitle.textAlignment = NSTextAlignmentRight;
    
    // 添加视图
    [self.setUpAlertBackView addSubview:self.pickerViewTitle];
    [self.setUpAlertBackView addSubview:self.accentPicker];
    [self.setUpAlertBackView addSubview:self.firstSegTitle];
    [self.setUpAlertBackView addSubview:self.secondSegTitle];

    
    [self.pickerViewTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.internalSecShow.mas_bottom).offset(20.f);
        make.left.equalTo(self.setUpAlertBackView.mas_left).offset(5.f);
        make.height.mas_equalTo(45.f);
        make.width.mas_equalTo(80.f);
    }];
    
    [self.accentPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pickerViewTitle.mas_centerY);
        make.height.mas_equalTo(self.pickerViewTitle);
        make.left.equalTo(self.pickerViewTitle.mas_right).offset(20.f);
        make.right.equalTo(self.setUpAlertBackView.mas_right);
    }];
    
    [self.firstSegTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pickerViewTitle.mas_bottom).offset(20.f);
        make.left.equalTo(self.setUpAlertBackView.mas_left).offset(5.f);
        make.width.height.mas_equalTo(self.pickerViewTitle);
    }];
    
    [self.secondSegTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.firstSegTitle.mas_bottom).offset(20.f);
        make.left.equalTo(self.setUpAlertBackView.mas_left).offset(5.f);
        make.width.height.mas_equalTo(self.pickerViewTitle);
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


- (void)multisectorValueChanged:(id)sender{
    [self updateDataView];
}

#pragma mark -- 更新视图数据
- (void)updateDataView{
    
    if ([self.configer isKindOfClass:[GAIATConfiger class]]) {
        
        GAIATConfiger * instance = (GAIATConfiger *)self.configer;
        instance.vadBos =  [NSString stringWithFormat:@"%ld", (long)_internalSec.endValue];
        instance.vadEos =  [NSString stringWithFormat:@"%ld", (long)_middleSec.endValue];
        instance.speechTimeout =  [NSString stringWithFormat:@"%ld", (long)_outsideSec.endValue];

        self.internalSecShow.text = instance.vadBos;
        self.middleSecShow.text   = instance.vadEos;
        self.outsideSecShow.text  = instance.speechTimeout;
        
        _internalSec.endValue = [instance.vadBos integerValue];
        _middleSec.endValue = [instance.vadEos integerValue];
        _outsideSec.endValue = [instance.speechTimeout integerValue];
        
        self.configer = instance;
        
    }else{
        
        
    }
    
}


-(void)needUpdateView {
    
    if (!self.configer) {
        return;
    }
    
    if ([self.configer isKindOfClass:[GAIATConfiger class]]) {
 
        self.titleLabel.text = @"听写设置";

        GAIATConfiger * instance = (GAIATConfiger *)self.configer;
        
        self.leftLabel.text   = @"前端静音超时";
        self.centerLabel.text = @"后端静音超时";
        self.rightLabel.text  = @"语音输入超时";

        self.internalSec.maxValue = 10000;
        self.middleSec.maxValue   = 10000;
        self.outsideSec.maxValue  = 60000;
        
        self.internalSec.endValue = instance.vadBos.integerValue;
        self.middleSec.endValue   = instance.vadEos.integerValue;
        self.outsideSec.endValue  = instance.speechTimeout.integerValue;
        
        self.internalSecShow.text = instance.vadBos;
        self.middleSecShow.text   = instance.vadEos;
        self.outsideSecShow.text  = instance.speechTimeout;
        
        

    }else{

        self.titleLabel.text = @"合成设置";

        
    }
    
}





#pragma mark -- 显示隐藏视图
- (void)showSetUpAlert{
    
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint center = self.setUpAlertBackView.center;
        center.x -= self.setUpAlertBackView.frame.size.width;
        self.setUpAlertBackView.center = center;
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
    }];
}

- (void)dismissSetUpAlert{
    
    [UIView animateWithDuration:0.3f animations:^{
        CGPoint center = self.setUpAlertBackView.center;
        center.x += self.setUpAlertBackView.frame.size.width;
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
