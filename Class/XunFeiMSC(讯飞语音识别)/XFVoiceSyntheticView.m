//
//  XFVoiceSyntheticView.m
//  Demo
//
//  Created by YanSY on 2018/5/16.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XFVoiceSyntheticView.h"
#import "XFMscViewModel.h"
#import "XFMscSetUpView.h"

#import "PopupView.h"
#import "AlertView.h"

#import "GASpeechTextMSCService.h"

@interface XFVoiceSyntheticView ()<GASpeechTTSServiceDelegate>

/// 标题
@property (nonatomic , strong) UILabel                    * titleLabel;
/// 设置按钮
@property (nonatomic , strong) UIButton                   * setUpBtn;
/// 语音合成输入视图
@property (nonatomic , strong) UITextView                 * textView;
/// 开始合成按钮
@property (nonatomic , strong) UIButton                   * startSynthesizeBtn;
/// 取消合成按钮
@property (nonatomic , strong) UIButton                   * cancelSynthesizeBtn;
/// URL合成按钮
@property (nonatomic , strong) UIButton                   * uriSynthesizeBtn;
/// 暂停合成按钮
@property (nonatomic , strong) UIButton                   * pauseSynthesizeBtn;
/// 恢复合成按钮
@property (nonatomic , strong) UIButton                   * resumeSynthesizeBtn;
/// 清空文本按钮
@property (nonatomic , strong) UIButton                   * clearTextBtn;

/// 模型
@property (nonatomic , strong) XFMscViewModel             * myModel;
/// 语音合成服务
@property (nonatomic , strong) GASpeechTTSService         * speechService;
/// 提示视图
@property (nonatomic , strong) PopupView                  * popUpView;
@property (nonatomic , strong) AlertView                  * inidicateView;


@end

@implementation XFVoiceSyntheticView

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
    
    self.inidicateView = [[AlertView alloc]initWithFrame:CGRectMake(center.x, 200, 0, 0)];
    self.inidicateView.ParentView = self;
    [[UIApplication sharedApplication].keyWindow addSubview:self.inidicateView];
    [self.inidicateView hide];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (pauseGuideAnimation) name: UIApplicationWillResignActiveNotification object:nil];
    
}

#pragma mark -- 添加 UI
- (void)addUI{
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.setUpBtn];
    [self addSubview:self.textView];
    
    self.startSynthesizeBtn = [self.myModel createButtonWithTitle:@"开始合成"];
    [self.startSynthesizeBtn addTarget:self action:@selector(startSynthesizeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.startSynthesizeBtn];
    
    self.cancelSynthesizeBtn = [self.myModel createButtonWithTitle:@"取消合成"];
    [self.cancelSynthesizeBtn addTarget:self action:@selector(cancelSynthesizeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelSynthesizeBtn];
    
    self.uriSynthesizeBtn = [self.myModel createButtonWithTitle:@"URL合成"];
    [self.uriSynthesizeBtn addTarget:self action:@selector(uriSynthesizeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.uriSynthesizeBtn];
    
    self.pauseSynthesizeBtn = [self.myModel createButtonWithTitle:@"暂停合成"];
    [self.pauseSynthesizeBtn addTarget:self action:@selector(pauseSynthesizeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.pauseSynthesizeBtn];
    
    self.resumeSynthesizeBtn = [self.myModel createButtonWithTitle:@"恢复合成"];
    [self.resumeSynthesizeBtn addTarget:self action:@selector(resumeSynthesizeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.resumeSynthesizeBtn];
    
    self.clearTextBtn = [self.myModel createButtonWithTitle:@"清空文本"];
    [self.clearTextBtn addTarget:self action:@selector(clearTextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.clearTextBtn];
    
}

#pragma mark -- 事件响应
- (void)pauseGuideAnimation{
//    [self.speechService stopASRToListening];
}

- (void)setUpBtnClick:(UIButton *)sender{

    [XFMscSetUpView disPlaySetUpView:self.speechService.baseConfig WithBlock:^(id configer) {

    }];
}

- (void)startSynthesizeBtnClick:(UIButton *)sender{
    
    [_textView resignFirstResponder];
    if ([_textView.text isEqualToString:@""]) {
        [_popUpView showText:@"无效的文本信息"];
        return;
    }
    
    BOOL ret = [self.speechService startTTSToNormalSpeaking:self.textView.text];
    if (ret) {
        
        [_inidicateView setText: @"正在缓冲..."];
        [_inidicateView show];
        [_popUpView removeFromSuperview];
        
    }else{
        [_popUpView showText: @"启动合成服务失败，请稍后重试"];
    }
    
}

- (void)uriSynthesizeBtnClick:(UIButton *)sender{

    [_textView resignFirstResponder];
    if ([_textView.text isEqualToString:@""]) {
        [_popUpView showText:@"无效的文本信息"];
        return;
    }
    
    BOOL ret = [self.speechService startTTSToURLSpeaking:_textView.text];
    if (ret) {
        
        [_inidicateView setText: @"正在缓冲..."];
        [_inidicateView show];
        [_popUpView removeFromSuperview];
        
    }else{
        [_popUpView showText: @"启动合成服务失败，请稍后重试"];
    }
}

- (void)cancelSynthesizeBtnClick:(UIButton *)sender{
    [_inidicateView hide];
    [self.speechService cancelTTSToSpeaking];
}

- (void)pauseSynthesizeBtnClick:(UIButton *)sender{
    [self.speechService pauseTTSToSpeaking];
}

- (void)resumeSynthesizeBtnClick:(UIButton *)sender{
    [self.speechService resumeTTSToSpeaking];
}

- (void)clearTextBtnClick:(UIButton *)sender{
    [_textView setText:@""];
    [self.speechService cancelTTSToSpeaking];
    [_textView becomeFirstResponder];
}

#pragma mark - GASpeechTTSServiceDelegate
/**
 开始播放回调
 注：
 对通用合成方式有效，
 对uri合成无效
 @param service 语音合成服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechTTSService:(GASpeechTTSService *)service onSpeakBegin:(BOOL)success{
    
    [_inidicateView hide];
    if (service.state != Playing) {
        [_popUpView showText:@"开始播放"];
    }
    
}

/**
 取消合成回调
 注：
 对通用合成方式有效，
 对uri合成无效
 @param service 语音合成服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechTTSService:(GASpeechTTSService *)service
           onSpeakCancel:(BOOL)success{
    [_inidicateView hide];
    [_popUpView showText:@"播放取消"];
}
/**
 暂停合成回调
 注：
 对通用合成方式有效，
 对uri合成无效
 @param service 语音合成服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechTTSService:(GASpeechTTSService *)service
           onSpeakPaused:(BOOL)success{
    
    [_inidicateView hide];
    [_popUpView showText:@"播放暂停"];
}

/**
 恢复合成回调
 注：
 对通用合成方式有效，
 对uri合成无效
 @param service 语音合成服务
 @param success 是否成功 默认成功，当出现中断时返回失败
 */
- (void)speechTTSService:(GASpeechTTSService *)service
          onSpeakResumed:(BOOL)success{
    [_inidicateView hide];
    [_popUpView showText:@"继续播放"];
}

/**
 缓冲进度回调
 注：
 对通用合成方式有效，
 对uri合成无效
 
 @param service 语音合成服务
 @param progress 缓冲进度
 @param msg 附加信息
 */
- (void)speechTTSService:(GASpeechTTSService *)service
        onBufferProgress:(int)progress
                 message:(NSString *)msg{
    
    NSLog(@"buffer progress %2d%%. msg: %@.", progress, msg);
}

/**
 播放进度回调
 
 @param service 语音合成服务
 @param progress 缓冲进度
 @param beginPos 开始点
 @param endPos 结束点
 */
- (void)speechTTSService:(GASpeechTTSService *)service
         onSpeakProgress:(int)progress beginPos:(int)beginPos
                  endPos:(int)endPos{
    NSLog(@"speak progress %2d%%.", progress);
}

/**
 合成结束（完成）回调
 注:
 1. 无论合成是否正确都会回调
 2. 若为URL合成，且设置不自动播放，在该方法内获取合成文件
 @param service 语音合成服务
 @param error 错误信息 0:合成结束 other:合成取消或出错
 */
- (void)speechTTSService:(GASpeechTTSService *)service
             onCompleted:(IFlySpeechError *)error{
    
    if (error.errorCode != 0) {
        [_inidicateView hide];
        [_popUpView showText:[NSString stringWithFormat:@"错误码:%d",error.errorCode]];
        return;
    }
    NSString *text ;
    if (service.isCanceled) {
        text = @"合成已取消";
    }else if (error.errorCode == 0){
        text = @"合成结束";
    }else{
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
    }
    
    [_inidicateView hide];
    [_popUpView showText:text];
    
    if (service.baseConfig.autoPlayURL && service.synType == UriType) {
        [_popUpView showText:@"uri合成完毕，即将开始播放"];
    }
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
    
    [self.startSynthesizeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).offset(15.f);
        make.left.equalTo(self.mas_left).offset(15.f);
        make.height.mas_equalTo(50.f);
    }];
    
    [self.cancelSynthesizeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.startSynthesizeBtn.mas_centerY);
        make.width.height.mas_equalTo(self.startSynthesizeBtn);
        make.left.equalTo(self.startSynthesizeBtn.mas_right).offset(20.f);
    }];
    
    [self.uriSynthesizeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.startSynthesizeBtn.mas_centerY);
        make.width.height.mas_equalTo(self.startSynthesizeBtn);
        make.left.equalTo(self.cancelSynthesizeBtn.mas_right).offset(20.f);
        make.right.equalTo(self.mas_right).offset(-15.f);
    }];
    
    [self.pauseSynthesizeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startSynthesizeBtn.mas_bottom).offset(15.f);
        make.left.equalTo(self.mas_left).offset(15.f);
        make.height.mas_equalTo(50.f);
        make.bottom.equalTo(self.mas_bottom).offset(-50);
    }];
    
    [self.resumeSynthesizeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pauseSynthesizeBtn.mas_centerY);
        make.width.height.mas_equalTo(self.pauseSynthesizeBtn);
        make.left.equalTo(self.pauseSynthesizeBtn.mas_right).offset(20.f);
    }];
    
    [self.clearTextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pauseSynthesizeBtn.mas_centerY);
        make.width.height.mas_equalTo(self.pauseSynthesizeBtn);
        make.left.equalTo(self.resumeSynthesizeBtn.mas_right).offset(20.f);
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
        _titleLabel.text = @"语音合成文字:";
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
        _textView.editable = YES;
        _textView.showsVerticalScrollIndicator = NO;
        _textView.text = @"      苏州中德宏泰电子科技股份有限公司（前身为玄烨科技，成立于2003年）2012年1月10日正式在昆山成立，现注册资本6001.6617万元，总部位于苏州昆山，在全国拥有多个分公司及控股公司，是人工智能领域集基础研究、应用研发、智能设备制造、能力输出为一体的高新技术企业，专注于人工智能、云计算、大数据+智慧城市、互联网+城市管理、智慧安防及服务领域的应用研发。截至目前，中德宏泰已获得国家授权专利35项，软件著作权8项，行业领先核心技术10项，是中国最早从事人工智能神经网络研究的企业之一，2015年7月，中德宏泰在新三板挂牌上市，证券简称：中德宏泰，证券代码：833067。\n      中德宏泰坚持科技创新，汇聚了一流的研发技术精英，结合多年的市场经验，构筑了高水平的研发技术平台，推出了深度神经网络人工智能算法、大数据智能分析云服务产品以及一系列安全防范软硬件产品，为大家努力创造更舒适、更便利、更安全的生活环境。中德宏泰以人人轻松享有安全的品质生活为愿景，矢志成为受人尊敬、全球卓越的大数据智能分析服务的领导者。\n      中德宏泰（VDIN）服务网络立足国内，面向全球，希望为全球范围内的用户以及合作伙伴提供性能卓越的大数据智能分析服务产品、互联网+安防服务产品。为普及人工智能在公共安全领域的应用、维护社会公共安全贡献自己的力量。";
    }
    return _textView;
}

- (GASpeechTTSService *)speechService{
    if (!_speechService) {
        _speechService = [GASpeechTextMSCService initSpeechTTSServiceWithConfig:nil];
        _speechService.delegate = self;
    }
    return _speechService;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [_inidicateView hide];

//    [self.speechService deallocToASR];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
