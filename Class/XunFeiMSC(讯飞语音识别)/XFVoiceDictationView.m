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

#define USERWORDS   @"{\"userword\":[{\"name\":\"我的常用词\",\"words\":[\"中德宏泰\",\"天祥广场\",\"高新区\",\"成都市\"]},{\"name\":\"我的好友\",\"words\":[\"孙二浪\",\"污妖汪\",\"哈哈全\",\"大润发\",\"二姐\",\"YanSY\"]}]}"

@interface XFVoiceDictationView ()<GASpeechIATServiceDelegate>

/// 标题
@property (nonatomic , strong) UILabel                    * titleLabel;
/// 设置按钮
@property (nonatomic , strong) UIButton                   * setUpBtn;
/// 语音识别展示视图
@property (nonatomic , strong) UITextView                 * textView;
/// 开始识别按钮
@property (nonatomic , strong) UIButton                   * startRecBtn;
/// 停止识别按钮
@property (nonatomic , strong) UIButton                   * stopRecBtn;
/// 取消识别按钮
@property (nonatomic , strong) UIButton                   * cancelRecBtn;
/// 音频流识别按钮
@property (nonatomic , strong) UIButton                   * audioStreamBtn;
/// 提示信息
@property (nonatomic , strong) UILabel                    * messageLabel;
/// 上传联系人按钮
@property (nonatomic , strong) UIButton                   * upContactBtn;
/// 上传词表按钮
@property (nonatomic , strong) UIButton                   * upWordListBtn;

/// 模型
@property (nonatomic , strong) XFMscViewModel             * myModel;
/// 语音听写服务
@property (nonatomic , strong) GASpeechIATService         * speechService;
/// 提示视图
@property (nonatomic , strong) PopupView                  * popUpView;

@end

@implementation XFVoiceDictationView

#pragma mark -- 初始化
- (instancetype)init
{
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
    CGPoint center = [UIApplication sharedApplication].keyWindow.center;
    self.popUpView = [[PopupView alloc]initWithFrame:CGRectMake(center.x, 200, 0, 0) withParentView:self] ;
    
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
    [self.speechService stopASRToListening];
}

- (void)setUpBtnClick:(UIButton *)sender{
    
    [XFMscSetUpView disPlaySetUpView:self.speechService.baseConfig WithBlock:^(id configer) {
        
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
        [_popUpView showText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束，暂不支持多路并发
    }
    
}

- (void)stopRecBtnClick:(UIButton *)sender{
    [self.speechService stopASRToListening];
    [_textView resignFirstResponder];
}

- (void)cancelRecBtnClick:(UIButton *)sender{
    [self.speechService cancelASRToListening];
    [_popUpView removeFromSuperview];
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
        [_popUpView showText: @"正在录音"];
    }else{
        [_startRecBtn setEnabled:YES];
        [_audioStreamBtn setEnabled:YES];
        [_upWordListBtn setEnabled:YES];
        [_upContactBtn setEnabled:YES];
        if (self.speechService.baseConfig.haveView) {
            [_popUpView showText:@"请设置为无界面识别模式"];
        }else{
            [_popUpView showText: @"启动失败"];
        }
    }
}

- (void)upContactBtnClick:(UIButton *)sender{
    
    [_startRecBtn setEnabled:NO];
    [_audioStreamBtn setEnabled:NO];
    _upContactBtn.enabled = NO;
    _upWordListBtn.enabled = NO;
    [_popUpView showText: @"正在上传..."];
    
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
    [_popUpView showText: @"正在上传..."];
    
    @weakify(self);
    [self.speechService upUserWordDataWithJson:USERWORDS Block:^(NSString *result, IFlySpeechError *error) {
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
        [_popUpView showText: @"上传成功"];
    }
    else {
        [_popUpView showText: [NSString stringWithFormat:@"上传失败，错误码:%d",error.errorCode]];
        
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
        [_popUpView removeFromSuperview];
        return;
    }
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    [_popUpView showText: vol];
}

/**
 开始录音回调
 
 @param service 语音识别服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechIATService:(GASpeechIATService *)service onBeginOfSpeech:(BOOL)success{
    if (service.isStreamRec == NO) {
        [_popUpView showText: @"正在录音"];
    }
}

/**
 停止录音回调
 
 @param service 语音识别服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechIATService:(GASpeechIATService *)service onEndOfSpeech:(BOOL)success{
    [_popUpView showText: @"停止录音"];
}

/**
 听写取消回调
 
 @param service 语音识别服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechIATService:(GASpeechIATService *)service onCancel:(BOOL)success{
    
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
        [_popUpView showText: text];
    }else{
        [_popUpView showText:@"识别结束"];
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
        _speechService = [GASpeechTextMSCService initSpeechIATServiceWithConfig:nil];
        _speechService.delegate = self;
    }
    return _speechService;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.speechService deallocToASR];
}


@end












