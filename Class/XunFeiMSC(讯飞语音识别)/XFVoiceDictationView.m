//
//  XFVoiceDictationView.m
//  Demo
//
//  Created by YanSY on 2018/5/13.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XFVoiceDictationView.h"

#import "XFMscViewModel.h"
#import "PopupView.h"
#import "XFMscSetUpView.h"

#import "GASpeechTextMSCService.h"

@interface XFVoiceDictationView ()<GASpeechIATServiceDelegate>

@property (nonatomic , strong) XFMscViewModel             * myModel;
@property (nonatomic , strong) GASpeechIATService         * speechService;

@end

@implementation XFVoiceDictationView

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
    [self addSubview:self.textView];
    
    self.startRecBtn = [self.myModel createButtonWithTitle:@"开始识别"];
    [self.startRecBtn addTarget:self action:@selector(startRecBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.startRecBtn];
    
    self.stopRecBtn = [self.myModel createButtonWithTitle:@"停止识别"];
    [self.stopRecBtn addTarget:self action:@selector(stopRecBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.stopRecBtn];
    
    self.cancelRecBtn = [self.myModel createButtonWithTitle:@"取消识别"];
    [self.cancelRecBtn addTarget:self action:@selector(cancelRecBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelRecBtn];
    
    self.audioStreamBtn = [self.myModel createButtonWithTitle:@"音频流识别"];
    [self.audioStreamBtn addTarget:self action:@selector(audioStreamBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.audioStreamBtn];
    
    [self addSubview:self.messageLabel];

    self.upContactBtn = [self.myModel createButtonWithTitle:@"上传联系人"];
    [self.upContactBtn addTarget:self action:@selector(upContactBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.upContactBtn];
    
    self.upWordListBtn = [self.myModel createButtonWithTitle:@"上传词表"];
    [self.upWordListBtn addTarget:self action:@selector(upWordListBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.upWordListBtn];

}

#pragma mark -- 事件响应
- (void)pauseGuideAnimation{
    [_textView resignFirstResponder];
}

- (void)setUpBtnClick:(UIButton *)sender{
    
    [self.speechService stopASRToListening];
    [_textView resignFirstResponder];
    
    GAIATConfiger * config = [self.speechService.baseConfig configerCopy];
    [XFMscSetUpView disPlaySetUpView:config WithBlock:^(id configer) {
        self.speechService.baseConfig = configer;
    }];
    
}

- (void)startRecBtnClick:(UIButton *)sender{

    BOOL ret = [self.speechService startASRToListening];
    if (ret) {
        [_textView setText:@""];
        [_textView resignFirstResponder];
        [_audioStreamBtn setEnabled:NO];
        [_upWordListBtn setEnabled:NO];
        [_upContactBtn setEnabled:NO];
    }else{
        [PopupView showPopWithText:@"启动识别服务失败，请稍后重试" toView:self.textView];
    }
}

- (void)stopRecBtnClick:(UIButton *)sender{
    [self.speechService stopASRToListening];
    [_textView resignFirstResponder];
}

- (void)cancelRecBtnClick:(UIButton *)sender{
    [self.speechService cancelASRToListening];
    [PopupView hidePopUpForView:self.textView];
    [_textView resignFirstResponder];
}

- (void)audioStreamBtnClick:(UIButton *)sender{
    
    [_startRecBtn setEnabled:NO];
    [_audioStreamBtn setEnabled:NO];
    [_upWordListBtn setEnabled:NO];
    [_upContactBtn setEnabled:NO];

    BOOL ret = [self.speechService startAudioStream];
    if (ret) {
        [_textView setText:@""];
        [_textView resignFirstResponder];
        [PopupView showPopWithText:@"正在录音" toView:self.textView];
    }else{
        [_startRecBtn setEnabled:YES];
        [_audioStreamBtn setEnabled:YES];
        [_upWordListBtn setEnabled:YES];
        [_upContactBtn setEnabled:YES];

        if (self.speechService.baseConfig.haveView) {
            [PopupView showPopWithText:@"请设置为无界面识别模式" toView:self.textView];
        }else{
            [PopupView showPopWithText:@"启动失败" toView:self.textView];
        }
    }
}

- (void)upContactBtnClick:(UIButton *)sender{
    
    [_startRecBtn setEnabled:NO];
    _upContactBtn.enabled = NO;
    _upWordListBtn.enabled = NO;

    [PopupView showPopWithText:@"正在上传..." toView:self.textView];
    
    @weakify(self);
    [self.speechService upContactDataWithBlock:^(NSString *result, IFlySpeechError *error) {
        @strongify(self);
        if (error.errorCode == 0) {
            self.textView.text = result;
        }
        [self onUploadFinished:error];
    }];
}

- (void)upWordListBtnClick:(UIButton *)sender{
    
    [_startRecBtn setEnabled:NO];
    [_audioStreamBtn setEnabled:NO];
    _upContactBtn.enabled = NO;
    _upWordListBtn.enabled = NO;
    [PopupView showPopWithText:@"正在上传..." toView:self.textView];

    @weakify(self);
    NSString * userWords = [self.myModel dictionaryToJsonString:self.myModel.userWordsDict];
    [self.speechService upUserWordDataWithJson:userWords Block:^(NSString *result, IFlySpeechError *error) {
        @strongify(self);
        if (error.errorCode == 0) {
            self.textView.text = result;
        }
        [self onUploadFinished:error];
    }];
}

/**
 上传联系人和词表的结果回调
 error ，错误码
 ****/
- (void)onUploadFinished:(IFlySpeechError *)error
{
    if ([error errorCode] == 0) {
        [PopupView showPopWithText:@"上传成功" toView:self.textView];
    }
    else {
        [PopupView showPopWithText:[NSString stringWithFormat:@"上传失败，错误码:%d",error.errorCode] toView:self.textView];
    }
    
    [_startRecBtn setEnabled:YES];
    [_audioStreamBtn setEnabled:YES];
    _upWordListBtn.enabled = YES;
    _upContactBtn.enabled = YES;
    
}

#pragma mark - GASpeechIATServiceDelegate
/**
 音量变化回调函数
 
 @param service 语音识别服务
 @param volume 0-30
 */
- (void)speechIATService:(GASpeechIATService *)service soundVolumeChanged:(int)volume{
    if (service.isCanceled) {
        [PopupView hidePopUpForView:self.textView];
        return;
    }
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    [PopupView showPopWithText:vol toView:self.textView];
}

/**
 开始录音回调
 
 @param service 语音识别服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechIATService:(GASpeechIATService *)service onBeginOfSpeech:(BOOL)success{
    if (service.isStreamRec == NO) {
        [PopupView showPopWithText:@"正在录音" toView:self.textView];
    }
}

/**
 停止录音回调
 
 @param service 语音识别服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechIATService:(GASpeechIATService *)service onEndOfSpeech:(BOOL)success{
    [PopupView showPopWithText:@"停止录音" toView:self.textView];
}

/**
 听写取消回调
 
 @param service 语音识别服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechIATService:(GASpeechIATService *)service onCancel:(BOOL)success{
    [PopupView showPopWithText:@"取消录音" toView:self.textView];
}

/**
 听写结束回调（注：无论听写是否正确都会回调
 
 @param service 语音识别服务
 @param error 0:听写正确 other:听写出错
 */
- (void)speechIATService:(GASpeechIATService *)service onError:(IFlySpeechError *)error{
    
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
    [_audioStreamBtn setEnabled:YES];
    [_upWordListBtn setEnabled:YES];
    [_upContactBtn setEnabled:YES];
}

/**
 听写结果回调
 
 @param service 语音识别服务
 @param resultDataStr 听写结果
 */
- (void)speechIATService:(GASpeechIATService *)service onResult:(NSString *)resultDataStr{
    _textView.text = [NSString stringWithFormat:@"%@%@",_textView.text,resultDataStr];;
    [_startRecBtn setEnabled:YES];
    [_audioStreamBtn setEnabled:YES];
    [_upWordListBtn setEnabled:YES];
    [_upContactBtn setEnabled:YES];
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
        make.height.mas_equalTo(50.f);
    }];
    
    [self.stopRecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.startRecBtn.mas_centerY);
        make.width.height.mas_equalTo(self.startRecBtn);
        make.left.equalTo(self.startRecBtn.mas_right).offset(20.f);
    }];

    [self.cancelRecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.startRecBtn.mas_centerY);
        make.width.height.mas_equalTo(self.startRecBtn);
        make.left.equalTo(self.stopRecBtn.mas_right).offset(20.f);
        make.right.equalTo(self.mas_right).offset(-15.f);
    }];
    
    [self.audioStreamBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startRecBtn.mas_bottom).offset(15.f);
        make.left.equalTo(self.mas_left).offset(15.f);
        make.right.equalTo(self.mas_right).offset(-15.f);
        make.height.mas_equalTo(50.f);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.audioStreamBtn.mas_bottom).offset(20.f);
        make.left.equalTo(self.mas_left).offset(15.f);
        make.right.equalTo(self.mas_right).offset(-15.f);
    }];
    
    [self.upContactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageLabel.mas_bottom).offset(15.f);
        make.left.equalTo(self.mas_left).offset(15.f);
        make.height.mas_equalTo(50.f);
        make.bottom.equalTo(self.mas_bottom).offset(-50);
    }];
    
    [self.upWordListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.upContactBtn.mas_centerY);
        make.width.height.mas_equalTo(self.upContactBtn);
        make.left.equalTo(self.upContactBtn.mas_right).offset(20.f);
        make.right.equalTo(self.mas_right).offset(-15.f);
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

- (UILabel *)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        _messageLabel.textColor = UIColorFromRGBA(0x000000, 1);
        _messageLabel.numberOfLines = 0;
        _messageLabel.text = @"点击以下个性化按钮可以体验更准确的“联系人”、“词表”识别效果，而且对语义理解同样生效，立刻尝试一下吧。";
    }
    return _messageLabel;
}

- (GASpeechIATService *)speechService{
    if (!_speechService) {
        _speechService = [GASpeechIATService sharedInstance];
        _speechService.delegate = self;
    }
    return _speechService;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.speechService deallocToASR];
}


@end












