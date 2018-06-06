//
//  XFVoiceTranslationView.m
//  Demo
//
//  Created by YanSY on 2018/6/4.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XFVoiceTranslationView.h"

#import "XFMscViewModel.h"
#import "PopupView.h"
#import "XFMscSetUpView.h"

#import "GASpeechTextMSCService.h"

#import "GASpeechiOSService.h"


@interface XFVoiceTranslationView ()<GASpeechSSTServiceDelegate>

@property (nonatomic , strong) XFMscViewModel             * myModel;
@property (nonatomic , strong) GASpeechSSTService         * speechService;

@end

@implementation XFVoiceTranslationView

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
    [GASpeechiOSService sharedInstance];
}

#pragma mark -- 添加 UI
- (void)addUI{
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.setUpBtn];
    [self addSubview:self.textView];
    
    self.startRecBtn = [self.myModel createButtonWithTitle:@"开始翻译"];
    [self.startRecBtn addTarget:self action:@selector(startRecBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.startRecBtn];
    
    self.stopRecBtn = [self.myModel createButtonWithTitle:@"停止翻译"];
    [self.stopRecBtn addTarget:self action:@selector(stopRecBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.stopRecBtn];
    
    self.cancelRecBtn = [self.myModel createButtonWithTitle:@"取消翻译"];
    [self.cancelRecBtn addTarget:self action:@selector(cancelRecBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelRecBtn];
    
}

#pragma mark -- 事件响应
- (void)pauseGuideAnimation{
    [_textView resignFirstResponder];
}

- (void)setUpBtnClick:(UIButton *)sender{
    
    [self.speechService stopSSTToTranslation];
    [_textView resignFirstResponder];
    
    GASSTConfiger * config = [self.speechService.baseConfig configerCopy];
    [XFMscSetUpView disPlaySetUpView:config WithBlock:^(id configer) {
        self.speechService.baseConfig = configer;
    }];
}

- (void)startRecBtnClick:(UIButton *)sender{
    
    BOOL ret = [self.speechService startSSTToTranslation];
    if (ret) {
        [_textView setText:@""];
        [_textView resignFirstResponder];
    }else{
        [PopupView showPopWithText:@"启动识别服务失败，请稍后重试" toView:self.textView];
    }
}

- (void)stopRecBtnClick:(UIButton *)sender{
    [self.speechService stopSSTToTranslation];
    [_textView resignFirstResponder];
}

- (void)cancelRecBtnClick:(UIButton *)sender{
    [self.speechService cancelSSTToTranslation];
    [PopupView hidePopUpForView:self.textView];
    [_textView resignFirstResponder];
}

#pragma mark - GASpeechSSTServiceDelegate
/**
 音量变化回调函数
 
 @param service 语音翻译服务
 @param volume 0-30
 */
- (void)speechSSTService:(GASpeechSSTService *)service
      soundVolumeChanged:(int)volume{
    
    if (service.isCanceled) {
        [PopupView hidePopUpForView:self.textView];
        return;
    }
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    [PopupView showPopWithText:vol toView:self.textView];
}

/**
 开始录音回调
 
 @param service 语音翻译服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechSSTService:(GASpeechSSTService *)service
         onBeginOfSpeech:(BOOL)success{
    
    [PopupView showPopWithText:@"正在录音" toView:self.textView];
}

/**
 停止录音回调
 
 @param service 语音翻译服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechSSTService:(GASpeechSSTService *)service
           onEndOfSpeech:(BOOL)success{
    [PopupView showPopWithText:@"停止录音" toView:self.textView];

}

/**
 翻译取消回调
 
 @param service 语音翻译服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechSSTService:(GASpeechSSTService *)service
                onCancel:(BOOL)success{
    
    [PopupView showPopWithText:@"取消录音" toView:self.textView];
}

/**
 翻译结束回调（注：无论翻译是否正确都会回调）
 
 @param service 语音翻译服务
 @param error 0:翻译正确 other:翻译出错
 */
- (void)speechSSTService:(GASpeechSSTService *)service
                 onError:(IFlySpeechError *)error{
    
    if (service.baseConfig.haveView == NO) {
        NSString *text ;
        if (service.isCanceled) {
            text = @"识别取消";
        }else if (error.errorCode == 0){
            if (_textView.text.length == 0) {
                text = @"无识别结果";
            }else{
                text = @"识别成功";
            }
            
        }else{
            text = [NSString stringWithFormat:@"发生错误：%d %@", error.errorCode,error.errorDesc];
        }
        [PopupView showPopWithText:text toView:self.textView];
        
    }else{
        [PopupView showPopWithText:@"识别结束" toView:self.textView];
    }
    [_startRecBtn setEnabled:YES];
    
}

/**
 翻译结果回调
 
 @param service 语音翻译服务
 @param resultDataStr 翻译结果
 */
- (void)speechSSTService:(GASpeechSSTService *)service
                onResult:(NSString *)resultDataStr{
    _textView.text = [NSString stringWithFormat:@"%@%@",_textView.text,resultDataStr];;
    [_startRecBtn setEnabled:YES];
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
    
    [self.cancelRecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
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

- (GASpeechSSTService *)speechService{
    if (!_speechService) {
        _speechService = [GASpeechSSTService sharedInstance];
        _speechService.delegate = self;
    }
    return _speechService;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.speechService deallocToSST];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
















