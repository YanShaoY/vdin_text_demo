//
//  iOSVoiceDictationView.m
//  Demo
//
//  Created by YanSY on 2018/6/7.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "iOSVoiceDictationView.h"

#import "XFMscViewModel.h"
#import "PopupView.h"
#import "XFMscSetUpView.h"

#import "GASpeechiOSService.h"

@interface iOSVoiceDictationView ()<GASpeechiOSServiceDelegate>

@property (nonatomic , strong) XFMscViewModel             * myModel;
@property (nonatomic , strong) GASpeechiOSService         * speechService;

@end

@implementation iOSVoiceDictationView

#pragma mark -- 初始化
- (instancetype)init{
    
    self = [super init];
    if (self) {
        [self configuration];
        [self addUI];
        [self addConstraint];
    }
    return self;
}

#pragma mark -- 配置
- (void)configuration{
    
    self.myModel = [[XFMscViewModel alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (pauseGuideAnimation) name: UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark -- 添加 UI
- (void)addUI{
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.setUpBtn];
    self.setUpBtn.hidden = YES;
    [self addSubview:self.textView];
    
    self.startRecBtn = [self.myModel createButtonWithTitle:@"开始识别"];
    [self.startRecBtn addTarget:self action:@selector(startRecBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.startRecBtn];
    
    self.stopRecBtn = [self.myModel createButtonWithTitle:@"停止识别"];
    [self.stopRecBtn addTarget:self action:@selector(stopRecBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.stopRecBtn];
    
    self.audioStreamBtn = [self.myModel createButtonWithTitle:@"本地音频文件翻译"];
    [self.audioStreamBtn addTarget:self action:@selector(audioStreamBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.audioStreamBtn];
    
}

#pragma mark -- 事件响应
- (void)pauseGuideAnimation{
    [_textView resignFirstResponder];
}

- (void)setUpBtnClick:(UIButton *)sender{
    
    [self.speechService stopiOSToListening];
    [_textView resignFirstResponder];
    
    GAiOSConfiger * config = [self.speechService.baseConfig configerCopy];
    [XFMscSetUpView disPlaySetUpView:config WithBlock:^(id configer) {
        self.speechService.baseConfig = configer;
    }];
}

- (void)startRecBtnClick:(UIButton *)sender{
    
    BOOL ret = [self.speechService startiOSToListening];
    if (ret) {
        [_textView setText:@""];
        [_textView resignFirstResponder];
    }else{
        [PopupView showPopWithText:@"启动识别服务失败，请稍后重试" toView:self.textView];
    }
}

- (void)stopRecBtnClick:(UIButton *)sender{
    [self.speechService stopiOSToListening];
    [_textView resignFirstResponder];
}

- (void)audioStreamBtnClick:(UIButton *)sender{
    [self.speechService startLocalAudioStreamWithUrl:nil];
    [PopupView hidePopUpForView:self.textView];
    [_textView resignFirstResponder];
}

#pragma mark - GASpeechiOSServiceDelegate
/**
 错误回调
 
 @param service 语音识别服务
 @param error 错误信息
 */
- (void)speechiOSService:(GASpeechiOSService *)service
                 onError:(NSError *)error{
    NSLog(@"%s----%@",__FUNCTION__,error);
}

#pragma mark -- 添加约束
- (void)addConstraint{
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(25.f);
        make.left.equalTo(self.mas_left).offset(15.f);
        make.right.equalTo(self.mas_right).offset(-15.f);
    }];
    
    [self.setUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(5.f);
        make.right.equalTo(self.mas_right).offset(-15.f);
        make.bottom.equalTo(self.textView.mas_top).offset(-5);
        make.width.mas_equalTo(50.f);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15.f);
        make.left.equalTo(self.mas_left).offset(15.f);
        make.right.equalTo(self.mas_right).offset(-15.f);
        make.height.mas_greaterThanOrEqualTo(200.f);
    }];
    
    [self.startRecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).offset(15.f);
        make.left.equalTo(self.mas_left).offset(15.f);
        make.right.equalTo(self.mas_right).offset(-15.f);
        make.height.mas_equalTo(50.f);
    }];
    
    [self.stopRecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startRecBtn.mas_bottom).offset(20.f);
        make.centerX.equalTo(self.startRecBtn.mas_centerX);
        make.width.height.mas_equalTo(self.startRecBtn);
    }];
    
    [self.audioStreamBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stopRecBtn.mas_bottom).offset(20.f);
        make.centerX.equalTo(self.startRecBtn.mas_centerX);
        make.width.height.mas_equalTo(self.startRecBtn);
        make.bottom.equalTo(self.mas_bottom).offset(-50);
    }];
    
    
    
}

#pragma mark -- 懒加载
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        _titleLabel.textColor = UIColorFromRGBA(0xF83141, 1);
        _titleLabel.text = @"语音识别反馈：";
    }
    return _titleLabel;
}

- (UIButton *)setUpBtn{
    if (!_setUpBtn) {
        _setUpBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_setUpBtn setImage:[UIImage imageNamed:@"setUp"] forState:UIControlStateNormal];
        [_setUpBtn addTarget:self action:@selector(setUpBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setUpBtn;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc]init];
        _textView.autoresizingMask= UIViewAutoresizingFlexibleHeight;
        _textView.textContainerInset = UIEdgeInsetsMake(10.f, 3.f, 10.f, 0.f);
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        _textView.textColor = UIColorFromRGBA(0x333333, 1.f);
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 10.f;
        _textView.backgroundColor = UIColorFromRGBA(0xCCFFFF, 1);
        _textView.editable = NO;
        _textView.showsVerticalScrollIndicator = NO;
    }
    return _textView;
}

- (GASpeechiOSService *)speechService{
    if (!_speechService) {
        _speechService = [GASpeechiOSService sharedInstance];
        _speechService.delegate = self;
    }
    return _speechService;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.speechService deallocToiOS];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end














