//
//  XFMscSetUpView.m
//  Demo
//
//  Created by YanSY on 2018/5/15.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XFMscSetUpView.h"
#import "PopupView.h"
#import "GASpeechTextMSCService.h"

@interface XFMscSetUpView ()<AKPickerViewDataSource,AKPickerViewDelegate>

/// 设置视图block回调
@property (strong, nonatomic) XFMscSetUpViewBlock setUpAlertBlock;
/// 传入显示的配置
@property (strong, nonatomic) id configer;
/// iPhone X适配顶部距离
@property (assign, nonatomic) CGFloat marginTop;

@end

@implementation XFMscSetUpView

#pragma mark -- 创建弹窗单例
+ (XFMscSetUpView *)sharedCustomAlert{
    CGRect frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    XFMscSetUpView * customAlert = [[XFMscSetUpView alloc]initWithFrame:frame];
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
        [self setupPickerView];
    }
    return self;
}

#pragma mark -- 适配iPhone X
- (void)safeAreaInsetsDidChange{
    UIEdgeInsets safeInsets = self.safeAreaInsets;
    self.marginTop = safeInsets.top;
}

#pragma mark --实现类方法
+ (void)disPlaySetUpView:(id)configer WithBlock:(XFMscSetUpViewBlock)block{
    [[XFMscSetUpView sharedCustomAlert]disPlaySetUpView:configer WithBlock:block];
}

- (void)disPlaySetUpView:(id)configer WithBlock:(XFMscSetUpViewBlock)block{
    self.configer = configer ;
    self.setUpAlertBlock = block;
    [self needUpdateView];
    [self showSetUpAlert];
}

#pragma mark -- 更新视图数据
-(void)needUpdateView {
    
    if (!self.configer) {
        return;
    }
    
    // 听写设置
    if ([self.configer isKindOfClass:[GAIATConfiger class]]) {
        
        GAIATConfiger * instance = (GAIATConfiger *)self.configer;

        self.titleLabel.text  = @"听写设置";
        self.leftLabel.text   = @"前端静音超时";
        self.centerLabel.text = @"后端静音超时";
        self.rightLabel.text  = @"语音录入超时";
        
        self.internalSec.maxValue = 10000;
        self.middleSec.maxValue   = 10000;
        self.outsideSec.maxValue  = 60000;
        
        self.internalSec.endValue = instance.vadBos.integerValue;
        self.middleSec.endValue   = instance.vadEos.integerValue;
        self.outsideSec.endValue  = instance.speechTimeout.integerValue;
        
        self.internalSecShow.text = instance.vadBos;
        self.middleSecShow.text   = instance.vadEos;
        self.outsideSecShow.text  = instance.speechTimeout;
        
        self.pickerViewTitle.text = @"识别语种";
        if ([instance.language isEqualToString:[IFlySpeechConstant LANGUAGE_CHINESE]]) {
            if ([instance.accent isEqualToString:[IFlySpeechConstant ACCENT_CANTONESE]]) {
                [_accentPicker selectItem:0 animated:NO];
                
            }else if ([instance.accent isEqualToString:[IFlySpeechConstant ACCENT_MANDARIN]]) {
                [_accentPicker selectItem:1 animated:NO];
                
            }else if ([instance.accent isEqualToString:[IFlySpeechConstant ACCENT_SICHUANESE]]) {
                [_accentPicker selectItem:3 animated:NO];
                
            }
        }else if ([instance.language isEqualToString:[IFlySpeechConstant LANGUAGE_ENGLISH]]) {
            [_accentPicker selectItem:2 animated:NO];
        }
        
        self.firstSegTitle.text = @"识别界面";
        [self.firstSeg removeAllSegments];
        [self.firstSeg insertSegmentWithTitle:@"无界面" atIndex:0 animated:NO];
        [self.firstSeg insertSegmentWithTitle:@"有界面" atIndex:1 animated:NO];
        
        if (instance.haveView == NO) {
            self.firstSeg.selectedSegmentIndex = 0;
        }else{
            self.firstSeg.selectedSegmentIndex = 1;
        }
        
        self.secondSegTitle.text = @"识别标点";
        [self.secondSeg removeAllSegments];
        [self.secondSeg insertSegmentWithTitle:@"无标点" atIndex:0 animated:NO];
        [self.secondSeg insertSegmentWithTitle:@"有标点" atIndex:1 animated:NO];
        if ([instance.dot isEqualToString:[IFlySpeechConstant ASR_PTT_NODOT]]) {
            self.secondSeg.selectedSegmentIndex = 0;
            
        }else if ([instance.dot isEqualToString:[IFlySpeechConstant ASR_PTT_HAVEDOT]]) {
            self.secondSeg.selectedSegmentIndex = 1;
        }
        
    }
    // 合成设置
    else if ([self.configer isKindOfClass:[GATTSConfiger class]]){
        
        GATTSConfiger * instance = (GATTSConfiger *)self.configer;
        
        self.titleLabel.text  = @"合成设置";
        self.leftLabel.text   = @"音量";
        self.centerLabel.text = @"语速";
        self.rightLabel.text  = @"音调";
        
        self.internalSec.maxValue = 100;
        self.middleSec.maxValue   = 100;
        self.outsideSec.maxValue  = 100;
        
        self.internalSec.endValue = instance.volume.integerValue;
        self.middleSec.endValue   = instance.speed.integerValue;
        self.outsideSec.endValue  = instance.pitch.integerValue;
        
        self.internalSecShow.text = instance.volume;
        self.middleSecShow.text   = instance.speed;
        self.outsideSecShow.text  = instance.pitch;
        
        self.pickerViewTitle.text = @"发音人";
        int vcnIndex= 0;
        if([instance.engineType isEqualToString: [IFlySpeechConstant TYPE_LOCAL]] || [instance.engineType isEqualToString: [IFlySpeechConstant TYPE_AUTO]]){
            for (int i = 0;i < instance.vcnIdentiferArray.count; i++) {
                if([[instance.vcnIdentiferArray objectAtIndex:i] isEqualToString:instance.vcnName]){
                    vcnIndex = i;
                    break;
                }
            }
            [_accentPicker selectItem:vcnIndex animated:NO];
        }
        else{
            for (int i = 0;i < instance.vcnIdentiferArray.count; i++) {
                if ([[instance.vcnIdentiferArray objectAtIndex:i] isEqualToString:instance.vcnName]) {
                    vcnIndex=i;
                    break;
                }
            }
            [_accentPicker selectItem:vcnIndex animated:NO];
        }
        
        self.firstSegTitle.text = @"采样率";
        [self.firstSeg removeAllSegments];
        [self.firstSeg insertSegmentWithTitle:@"16K" atIndex:0 animated:NO];
        [self.firstSeg insertSegmentWithTitle:@"8K" atIndex:1 animated:NO];
        
        NSString *sampleRate = instance.sampleRate;//采样率
        if ([sampleRate isEqualToString:[IFlySpeechConstant SAMPLE_RATE_16K]]) {
            self.firstSeg.selectedSegmentIndex = 0;
            
        }else if ([sampleRate isEqualToString:[IFlySpeechConstant SAMPLE_RATE_8K]]) {
            self.firstSeg.selectedSegmentIndex = 1;
            
        }
        
        self.secondSegTitle.text = @"引擎类型";
        [self.secondSeg removeAllSegments];
        [self.secondSeg insertSegmentWithTitle:@"自动" atIndex:0 animated:NO];
        [self.secondSeg insertSegmentWithTitle:@"云端" atIndex:1 animated:NO];
        [self.secondSeg insertSegmentWithTitle:@"本地" atIndex:2 animated:NO];

        NSString *type = instance.engineType;
        if ([type isEqualToString:[IFlySpeechConstant TYPE_AUTO]]) {
            self.secondSeg.selectedSegmentIndex = 0;
            
        }else if ([type isEqualToString:[IFlySpeechConstant TYPE_CLOUD]]) {
            self.secondSeg.selectedSegmentIndex = 1;
            
        }else if ([type isEqualToString:[IFlySpeechConstant TYPE_LOCAL]]) {
            self.secondSeg.selectedSegmentIndex = 2;
        }
        
    }
    
}


#pragma mark - 按钮点击响应
- (void)saveBtnClick {
    [self dismissSetUpAlert];
    if (self.setUpAlertBlock && self.configer) {
        self.setUpAlertBlock(self.configer);
    }
}

- (void)cancelBtnClick {
    [self dismissSetUpAlert];
}


- (void)multisectorValueChanged:(id)sender{

    if ([self.configer isKindOfClass:[GAIATConfiger class]]) {
        
        GAIATConfiger * instance = (GAIATConfiger *)self.configer;
        instance.vadBos =  [NSString stringWithFormat:@"%ld", (long)_internalSec.endValue];
        instance.vadEos =  [NSString stringWithFormat:@"%ld", (long)_middleSec.endValue];
        instance.speechTimeout =  [NSString stringWithFormat:@"%ld", (long)_outsideSec.endValue];
        
        self.internalSecShow.text = instance.vadBos;
        self.middleSecShow.text   = instance.vadEos;
        self.outsideSecShow.text  = instance.speechTimeout;
        
        _internalSec.endValue = [instance.vadBos integerValue];
        _middleSec.endValue   = [instance.vadEos integerValue];
        _outsideSec.endValue  = [instance.speechTimeout integerValue];
        
        self.configer = instance;
        
    }else if ([self.configer isKindOfClass:[GATTSConfiger class]]){
        GATTSConfiger * instance = (GATTSConfiger *)self.configer;
        instance.volume = [NSString stringWithFormat:@"%d", (int)_internalSec.endValue];
        instance.speed = [NSString stringWithFormat:@"%d", (int)_middleSec.endValue];
        instance.pitch = [NSString stringWithFormat:@"%d", (int)_outsideSec.endValue];
        
        self.internalSecShow.text = instance.volume;
        self.middleSecShow.text   = instance.speed;
        self.outsideSecShow.text  = instance.pitch;
        
        _internalSec.endValue = [instance.volume integerValue];
        _middleSec.endValue   = [instance.speed integerValue];
        _outsideSec.endValue  = [instance.pitch integerValue];
        
        self.configer = instance;
        
    }

}

- (void)firstSegChange:(UISegmentedControl *)sender{
    
    if ([self.configer isKindOfClass:[GAIATConfiger class]]) {
        GAIATConfiger * instance = (GAIATConfiger *)self.configer;
        if (sender.selectedSegmentIndex == 0 ) {
            instance.haveView = NO;
        }else if (sender.selectedSegmentIndex == 1 ){
            instance.haveView = YES;
        }
        self.configer = instance;
        
    }else if ([self.configer isKindOfClass:[GATTSConfiger class]]){
        GATTSConfiger * instance = (GATTSConfiger *)self.configer;
        if (sender.selectedSegmentIndex == 0) {
            instance.sampleRate = [IFlySpeechConstant SAMPLE_RATE_16K];
            
        }else if (sender.selectedSegmentIndex == 1) {
            
            if (instance.engineType == [IFlySpeechConstant TYPE_LOCAL] || instance.engineType == [IFlySpeechConstant TYPE_AUTO]){
                
                [PopupView showPopWithText:@"本地合成仅支持16K采样率" toView:nil];
                self.firstSeg.selectedSegmentIndex = 0;

            }else{
                instance.sampleRate = [IFlySpeechConstant SAMPLE_RATE_8K];
            }
            
        }
        self.configer = instance;

    }
    
}

- (void)secondSegChange:(UISegmentedControl *)sender{
    
    if ([self.configer isKindOfClass:[GAIATConfiger class]]) {
        GAIATConfiger * instance = (GAIATConfiger *)self.configer;
        if (sender.selectedSegmentIndex == 0 ) {
            instance.dot = [IFlySpeechConstant ASR_PTT_NODOT];
        }else if (sender.selectedSegmentIndex == 1 ){
            instance.dot = [IFlySpeechConstant ASR_PTT_HAVEDOT];
        }
        self.configer = instance;
        
    }else if ([self.configer isKindOfClass:[GATTSConfiger class]]){
        GATTSConfiger * instance = (GATTSConfiger *)self.configer;
        if (sender.selectedSegmentIndex == 0 ) {
            [PopupView showPopWithText:@"暂不支持自动合成项" toView:nil];
            self.secondSeg.selectedSegmentIndex = 1;
            
        }else if (sender.selectedSegmentIndex == 1 ){
            instance.engineType = [IFlySpeechConstant TYPE_CLOUD];
            
        }else if (sender.selectedSegmentIndex == 2 ){
            [PopupView showPopWithText:@"本地合成需购买" toView:nil];
            self.secondSeg.selectedSegmentIndex = 1;
        }
        
        self.configer = instance;
        
    }
    
}


#pragma mark - 识别语言选择器数据源
- (NSUInteger)numberOfItemsInPickerView:(AKPickerView *)pickerView{

    if ([self.configer isKindOfClass:[GAIATConfiger class]]) {
        GAIATConfiger * instance = (GAIATConfiger *)self.configer;
        return instance.accentNickName.count;
        
    }else if ([self.configer isKindOfClass:[GATTSConfiger class]]){
        GATTSConfiger * instance = (GATTSConfiger *)self.configer;
        if(instance.engineType == [IFlySpeechConstant TYPE_LOCAL] || instance.engineType == [IFlySpeechConstant TYPE_AUTO]){

        }
        else{
            return instance.vcnIdentiferArray.count;
        }
        

    }
    return 0;

}

- (NSString *)pickerView:(AKPickerView *)pickerView titleForItem:(NSInteger)item{

    if ([self.configer isKindOfClass:[GAIATConfiger class]]) {
        GAIATConfiger * instance = (GAIATConfiger *)self.configer;
        return [instance.accentNickName objectAtIndex:item];
        
    }else if ([self.configer isKindOfClass:[GATTSConfiger class]]){
        GATTSConfiger * instance = (GATTSConfiger *)self.configer;
        if(instance.engineType == [IFlySpeechConstant TYPE_LOCAL] || instance.engineType == [IFlySpeechConstant TYPE_AUTO]){

        }
        else{
            if(instance.vcnNickNameArray.count > item){
                return [instance.vcnNickNameArray objectAtIndex:item];
            }
        }
    }
    return @"未知";
}

#pragma mark - 识别语言选择器事件回调
- (void)pickerView:(AKPickerView *)pickerView didSelectItem:(NSInteger)item{
    
    if ([self.configer isKindOfClass:[GAIATConfiger class]]) {
        GAIATConfiger * instance = (GAIATConfiger *)self.configer;
        if (item == 0) { //粤语
            instance.language = [IFlySpeechConstant LANGUAGE_CHINESE];
            instance.accent = [IFlySpeechConstant ACCENT_CANTONESE];
        }else if (item == 1) {//普通话
            instance.language = [IFlySpeechConstant LANGUAGE_CHINESE];
            instance.accent = [IFlySpeechConstant ACCENT_MANDARIN];
        }else if (item == 3) {//四川话
            instance.language = [IFlySpeechConstant LANGUAGE_CHINESE];
            instance.accent = [IFlySpeechConstant ACCENT_SICHUANESE];
        }else if (item == 2) {//英文
            instance.language = [IFlySpeechConstant LANGUAGE_ENGLISH];
            instance.accent = @"";
        }
        self.configer = instance;
        
    }else if ([self.configer isKindOfClass:[GATTSConfiger class]]){
        GATTSConfiger * instance = (GATTSConfiger *)self.configer;
        //离线模式
        if(instance.engineType == [IFlySpeechConstant TYPE_LOCAL] || instance.engineType == [IFlySpeechConstant TYPE_AUTO]){
            
        }else {
            
            instance.vcnName = [instance.vcnIdentiferArray objectAtIndex:item];
        }
        self.configer = instance;
    }

}

#pragma mark -- 视图设置
/// 设置背景视图
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

/// 设置工具条
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
    
    self.titleLabel = [self createLabelWithFont:18 andTextColor:UIColorFromRGBA(0xFFFFFF, 1) andText:@"听写设置"];
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
    self.leftLabel = [self createLabelWithFont:13 andTextColor:redColor andText:@"内部滑块"];
    self.leftLabel.textAlignment = NSTextAlignmentCenter;
    
    self.centerLabel = [self createLabelWithFont:13 andTextColor:blueColor andText:@"中间滑块"];
    self.centerLabel.textAlignment = NSTextAlignmentCenter;
    
    self.rightLabel = [self createLabelWithFont:13 andTextColor:greenColor andText:@"外部滑块"];
    self.rightLabel.textAlignment = NSTextAlignmentCenter;
    
    // 数值
    self.internalSecShow = [self createLabelWithFont:15 andTextColor:UIColorFromRGBA(0x00A8FF, 1) andText:@"100"];
    self.internalSecShow.textAlignment = NSTextAlignmentCenter;
    
    self.middleSecShow = [self createLabelWithFont:15 andTextColor:UIColorFromRGBA(0x00A8FF, 1) andText:@"100"];
    self.middleSecShow.textAlignment = NSTextAlignmentCenter;
    
    self.outsideSecShow = [self createLabelWithFont:15 andTextColor:UIColorFromRGBA(0x00A8FF, 1) andText:@"100"];
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
        make.top.equalTo(self.roundSlider.mas_bottom).offset(20.f);
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
- (void)setupPickerView{
    
    // 选择器标题
    self.pickerViewTitle = [self createLabelWithFont:17 andTextColor:UIColorFromRGBA(0x22A419, 1) andText:@"识别语种"];
    self.pickerViewTitle.textAlignment = NSTextAlignmentRight;

    // 第一个分段控制器标题
    self.firstSegTitle = [self createLabelWithFont:17 andTextColor:UIColorFromRGBA(0x22A419, 1) andText:@"识别界面"];
    self.firstSegTitle.textAlignment = NSTextAlignmentRight;
    
    // 第一个分段控制器
    self.firstSeg = [[UISegmentedControl alloc]init];
    [self.firstSeg addTarget:self action:@selector(firstSegChange:) forControlEvents:UIControlEventValueChanged];
    
    // 第二个分段控制器标题
    self.secondSegTitle = [self createLabelWithFont:17 andTextColor:UIColorFromRGBA(0x22A419, 1) andText:@"识别标点"];
    self.secondSegTitle.textAlignment = NSTextAlignmentRight;
    
    // 第二个分段控制器
    self.secondSeg = [[UISegmentedControl alloc]init];
    [self.secondSeg addTarget:self action:@selector(secondSegChange:) forControlEvents:UIControlEventValueChanged];
    
    // 添加视图
    [self.setUpAlertBackView addSubview:self.pickerViewTitle];
    [self.setUpAlertBackView addSubview:self.accentPicker];
    [self.setUpAlertBackView addSubview:self.firstSegTitle];
    [self.setUpAlertBackView addSubview:self.firstSeg];
    [self.setUpAlertBackView addSubview:self.secondSegTitle];
    [self.setUpAlertBackView addSubview:self.secondSeg];
    
    
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
        make.right.equalTo(self.setUpAlertBackView.mas_right).offset(-20);
    }];
    
    [self.firstSegTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pickerViewTitle.mas_bottom).offset(10.f);
        make.left.equalTo(self.setUpAlertBackView.mas_left).offset(5.f);
        make.width.height.mas_equalTo(self.pickerViewTitle);
    }];
    
    [self.firstSeg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.firstSegTitle.mas_centerY);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.firstSegTitle.mas_right).offset(20.f);
        make.right.equalTo(self.setUpAlertBackView.mas_right).offset(-20.f);
    }];
    
    [self.secondSegTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.firstSegTitle.mas_bottom).offset(10.f);
        make.left.equalTo(self.setUpAlertBackView.mas_left).offset(5.f);
        make.width.height.mas_equalTo(self.pickerViewTitle);
    }];
    
    [self.secondSeg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.secondSegTitle.mas_centerY);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.secondSegTitle.mas_right).offset(20.f);
        make.right.equalTo(self.setUpAlertBackView.mas_right).offset(-20.f);
    }];
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

#pragma mark -- 创建基本视图
/// 标签初始化
- (UILabel *)createLabelWithFont:(CGFloat)size andTextColor:(UIColor *)color andText:(NSString *)text{
    
    UILabel * label = [[UILabel alloc]init];
    label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:size];
    label.textColor = color;
    label.text = text;
    return label;
}

- (AKPickerView *)accentPicker{
    if (!_accentPicker) {
        _accentPicker = [[AKPickerView alloc]init];
        _accentPicker.delegate = self;
        _accentPicker.dataSource = self;
        _accentPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _accentPicker.textColor = [UIColor grayColor];
        _accentPicker.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        _accentPicker.highlightedFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
        _accentPicker.highlightedTextColor = [UIColor colorWithRed:0.0 green:168.0/255.0 blue:255.0/255.0 alpha:1.0];
        _accentPicker.interitemSpacing = 20.0;
        _accentPicker.fisheyeFactor = 0.001;
        _accentPicker.pickerViewStyle = AKPickerViewStyle3D;
        _accentPicker.maskDisabled = false;
    }
    return _accentPicker;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
