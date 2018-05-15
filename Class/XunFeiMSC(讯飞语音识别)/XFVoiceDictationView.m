//
//  XFVoiceDictationView.m
//  Demo
//
//  Created by YanSY on 2018/5/13.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XFVoiceDictationView.h"
#import "XFVoiceDictationModel.h"

#import "GASpeechTextMSCService.h"

#define USERWORDS   @"{\"userword\":[{\"name\":\"我的常用词\",\"words\":[\"中德宏泰\",\"天祥广场\",\"高新区\",\"成都市\"]},{\"name\":\"我的好友\",\"words\":[\"孙二浪\",\"污妖汪\",\"哈哈全\",\"大润发\",\"二姐\",\"YanSY\"]}]}"

@interface XFVoiceDictationView ()<GASpeechTextMSCServiceDelegate>{
    
}

/// 标题
@property (nonatomic , strong) UILabel                    * titleLabel;
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
@property (nonatomic , strong) XFVoiceDictationModel      * myModel;
/// 语音听写服务
@property (nonatomic , strong) GASpeechTextMSCService     * mscService;


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
    
    self.myModel = [[XFVoiceDictationModel alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (pauseGuideAnimation) name: UIApplicationWillResignActiveNotification object:nil];

}

#pragma mark -- 添加 UI
- (void)addUI{
    
    [self addSubview:self.titleLabel];
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
    //    [self dismissAnimationOnButton];
    
}

- (void)startRecBtnClick:(UIButton *)sender{

    BOOL ret = [self.mscService startToASR];
    if (ret) {
        [_textView setText:@""];
        [_textView resignFirstResponder];
    }else{
        [_textView setText:@"语音识别开启失败"];
    }
    
}

- (void)stopRecBtnClick:(UIButton *)sender{
    [self.mscService stopToASR];
}

- (void)cancelRecBtnClick:(UIButton *)sender{
    [self.mscService cancelToASR];
}

- (void)audioStreamBtnClick:(UIButton *)sender{
    BOOL ret = [self.mscService audioStreamStart];
    if (ret) {
        [_textView setText:@""];
        [_textView resignFirstResponder];
    }else{
        [_textView setText:@"语音识别开启失败"];
    }
}

- (void)upContactBtnClick:(UIButton *)sender{
    
    @weakify(self);
    [self.mscService upContactDataWithBlock:^(NSString *result, IFlySpeechError *error) {
        @strongify(self);
        if (error.errorCode == 0) {
            self.textView.text = result;
        }
        [self onUploadFinished:error];
    }];
}

- (void)upWordListBtnClick:(UIButton *)sender{
    
    @weakify(self);
    [self.mscService upUserWordDataWithJson:USERWORDS Block:^(NSString *result, IFlySpeechError *error) {
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
//        [_popUpView showText: @"上传成功"];
    }
    else {
//        [_popUpView showText: [NSString stringWithFormat:@"上传失败，错误码:%d",error.errorCode]];
        
    }
    
    [_startRecBtn setEnabled:YES];
    [_audioStreamBtn setEnabled:YES];
    _upWordListBtn.enabled = YES;
    _upContactBtn.enabled = YES;
}

#pragma mark - GASpeechTextMSCServiceDelegate
/**
 音量回调函数
 
 @param volume 0-30
 */
- (void)onVolumeChanged:(int)volume{

}

/**
 开始识别回调
 */
- (void)onBeginOfSpeech{

}

/**
 停止录音回调
 */
- (void)onEndOfSpeech{

}

/**
 听写取消回调
 */
- (void)onCancel{

}

/**
 听写结束回调（注：无论听写是否正确都会回调）
 
 @param error 0:听写正确 other:听写出错
 */
- (void)onError:(IFlySpeechError *)error{
    NSLog(@"%s",__func__);
}

- (void)onResult:(NSString *)resultStr{
    
    _textView.text = resultStr;
}

#pragma mark -- 添加约束
- (void)addConstraint{
  
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(20.f);
        make.left.equalTo(self.mas_left).offset(15.f);
        make.right.equalTo(self.mas_right).offset(-15.f);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12.f);
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
        make.top.equalTo(self.audioStreamBtn.mas_bottom).offset(40.f);
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

- (GASpeechTextMSCService *)mscService{
    if (!_mscService) {
        _mscService = [[GASpeechTextMSCService alloc]init];
        _mscService.delegate = self;
        [_mscService initRecognizerWithConfig:nil];
    }
    return _mscService;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.mscService deallocToASR];
}


@end












