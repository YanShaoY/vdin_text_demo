//
//  EntranceGuardView.m
//  Demo
//
//  Created by YanSY on 2017/12/22.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "EntranceGuardView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ibeaconNetWorkManager.h"
#import "GAibeaconLocationService.h"

#define UserDefaultsKEY @"ibeaconOpenDoorSingnal"
#define BeaconUUID  @"4CDBC040-657A-4847-B266-7E31D9E2C3D9"
#define BeaconMajor @"1000"
#define BeaconMinor @"1"


@interface EntranceGuardView ()<GAibeaconLocationServiceDelegate>{
    
    
}

/// 是否正在请求
@property (nonatomic , assign) BOOL                     isOnRequest;
/// 顶部设置视图
@property (nonatomic , strong) UIView                 * setUpBackView;
/// 扫描开门按钮
@property (nonatomic , strong) UIButton               * scanButton;
/// 雷达波动动画
@property (nonatomic , strong) CALayer                * animationLayer;
/// 自动开门扫描服务
@property (nonatomic , strong) GAibeaconLocationService * autoOpenDoor;

@end

@implementation EntranceGuardView


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

/// 配置
- (void)configuration{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (pauseGuideAnimation) name: UIApplicationWillResignActiveNotification object:nil];
}

/// 添加 UI
- (void)addUI{
    self.animationLayer = [CALayer layer];

    self.setUpBackView = [[UIView alloc]init];
    _setUpBackView.backgroundColor = UIColorFromRGBA(0xCCFFFF, 1);
    _setUpBackView.layer.cornerRadius = 10;
    _setUpBackView.layer.shadowColor = [UIColor blackColor].CGColor;
    _setUpBackView.layer.shadowOpacity = 0.9f;
    _setUpBackView.layer.shadowRadius = 10.0f;
    _setUpBackView.layer.shadowOffset = CGSizeMake(5, 5);
    [self addSubview:_setUpBackView];

    UILabel * currentSignalTitle = [self createLabelWithTextColor:UIColorFromRGBA(0x9999FF, 1.0f) andText:@"当前蓝牙信号强度为:"];
    currentSignalTitle.tag = 101;
    [_setUpBackView addSubview:currentSignalTitle];
    
    UILabel * currentSignalMsg =[self createLabelWithTextColor:UIColorFromRGBA(0xFF9999, 1.0f) andText:@"   "];
    currentSignalMsg.tag = 102;
    [_setUpBackView addSubview:currentSignalMsg];
    
    UILabel * autoOpenTitle = [self createLabelWithTextColor:UIColorFromRGBA(0x9999FF, 1.0f) andText:@"自动开门信号临界值:"];
    autoOpenTitle.tag = 103;
    [_setUpBackView addSubview:autoOpenTitle];
    
    NSString * singleText = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_%@",UserDefaultsKEY,@"single"]];
    singleText = singleText ? singleText : @"-80";
    UILabel * autoOpenlMsg = [self createLabelWithTextColor:UIColorFromRGBA(0x3399CC, 1.0f) andText:singleText];
    autoOpenlMsg.tag = 104;
    [_setUpBackView addSubview:autoOpenlMsg];
    
    UISlider * slider = [[UISlider alloc]init];
    slider.tag = 105;
    slider.minimumValue = 50;
    slider.maximumValue = 90;
    slider.value = -autoOpenlMsg.text.integerValue;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_setUpBackView addSubview:slider];
    
    self.scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_scanButton.layer setMasksToBounds:YES];
    _scanButton.layer.cornerRadius = SCREENHEIGHT / 12;
    _scanButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _scanButton.layer.shadowOpacity = 0.9f;
    _scanButton.layer.shadowRadius = 3.0f;
    _scanButton.layer.shadowOffset = CGSizeMake(1, 1);
    [_scanButton setBackgroundImage:[UIImage imageNamed:@"lockTheDoor"] forState:UIControlStateNormal];
    [_scanButton setBackgroundImage:[UIImage imageNamed:@"openTheDoor"] forState:UIControlStateSelected];
    [_scanButton setBackgroundImage:[UIImage imageNamed:@"openTheDoor"] forState:UIControlStateHighlighted];
    [_scanButton addTarget:self action:@selector(scanButtonActionTouchUp:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview:_scanButton];
    
    UILabel * ibeaconSetTitle = [self createLabelWithTextColor:UIColorFromRGBA(0x9999FF, 1.0f) andText:@"是否开启自动开门:"];
    ibeaconSetTitle.tag = 106;
    [self addSubview:ibeaconSetTitle];
    
    NSString * autoText = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_%@",UserDefaultsKEY,@"auto"]];
    BOOL setOn = [autoText isEqualToString:@"1"] ? YES : NO;
    
    UISwitch * setSwitch = [[UISwitch alloc]init];
    setSwitch.tag = 107;
    [setSwitch setOn:setOn animated:YES];
    [setSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:setSwitch];
}

/// 添加约束
- (void)addConstraint{
    
    [_setUpBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(SCREENHEIGHT / 10);
        make.left.equalTo(self.mas_left).offset(SCREENWIDTH / 20);
        make.right.equalTo(self.mas_right).offset(- SCREENWIDTH / 20);
        make.height.mas_equalTo(SCREENHEIGHT / 4);
    }];
    
    UILabel * label_101 = [_setUpBackView viewWithTag:101];
    [label_101 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.setUpBackView);
        make.width.mas_equalTo(SCREENWIDTH / 20 * 12);
        make.height.mas_equalTo(SCREENHEIGHT / 4 / 3);
    }];
    
    UILabel * label_102 = [_setUpBackView viewWithTag:102];
    [label_102 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.setUpBackView);
        make.width.mas_equalTo(SCREENWIDTH / 20 * 5);
        make.height.mas_equalTo(SCREENHEIGHT / 4 / 3);
    }];
    

    UILabel * label_103 = [_setUpBackView viewWithTag:103];
    [label_103 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label_101.mas_bottom);
        make.left.equalTo(self.setUpBackView.mas_left);
        make.width.mas_equalTo(SCREENWIDTH / 20 * 12);
        make.height.mas_equalTo(SCREENHEIGHT / 4 / 3);
    }];
    
    UILabel * label_104 = [_setUpBackView viewWithTag:104];
    [label_104 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label_102.mas_bottom);
        make.right.equalTo(self.setUpBackView.mas_right);
        make.width.mas_equalTo(SCREENWIDTH / 20 * 5);
        make.height.mas_equalTo(SCREENHEIGHT / 4 / 3);
    }];
    
    UISlider * slider = [_setUpBackView viewWithTag:105];
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label_104.mas_bottom);
        make.left.equalTo(self.setUpBackView.mas_left).offset(SCREENWIDTH / 15);
        make.right.equalTo(self.setUpBackView.mas_right).offset(-SCREENWIDTH / 15);
        make.height.mas_equalTo(SCREENHEIGHT / 4 / 3);
    }];

    [_scanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.setUpBackView.mas_bottom).offset(SCREENHEIGHT / 8);
        make.height.mas_equalTo(SCREENHEIGHT / 6);
        make.width.mas_equalTo(SCREENHEIGHT / 6);
    }];
    
    UILabel * label_106 = [self viewWithTag:106];
    [label_106 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scanButton.mas_bottom).offset(SCREENHEIGHT / 12);
        make.left.equalTo(self.setUpBackView.mas_left);
        make.width.mas_equalTo(SCREENWIDTH / 20 * 12);
        make.height.mas_equalTo(SCREENHEIGHT / 4 / 3);
    }];
    
    UISwitch * setSwitch = [self viewWithTag:107];
    [setSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(label_106.mas_centerY);
        make.left.equalTo(label_106.mas_right).offset(5);
    }];
    if (setSwitch.on) {
        [self starScanIbeacon];
    }
}

#pragma mark -- 事件响应
- (void)pauseGuideAnimation{
    [self dismissAnimationOnButton];
}

-(void)sliderValueChanged:(UISlider *)slider
{
    UILabel * label_104 = [_setUpBackView viewWithTag:104];
    label_104.text = [NSString stringWithFormat:@"-%.2f",roundf(slider.value)];
    [[NSUserDefaults standardUserDefaults]setValue:label_104.text forKey:[NSString stringWithFormat:@"%@_%@",UserDefaultsKEY,@"single"]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)switchAction:(UISwitch *)sender{
    
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",sender.on] forKey:[NSString stringWithFormat:@"%@_%@",UserDefaultsKEY,@"auto"]];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if (sender.on) {
        [self starScanIbeacon];
    }else{
        [self stopScanIbeacon];
    }
}

- (void)scanButtonActionTouchUp:(UIButton *)sender{
    
    if (sender.selected) {
        [self dismissAnimationOnButton];
    }else{
        SystemSoundID soundID = 1001;
        AudioServicesPlaySystemSound(soundID);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        [self requestToOpenTheDoor];
    }
}

#pragma mark -- 关于ibeacon
- (void)starScanIbeacon{
    self.autoOpenDoor = [GAibeaconLocationService sharedInstance];
    [_autoOpenDoor setServiceWithUUID:BeaconUUID
                             andMajor:BeaconMajor
                             andMinor:BeaconMinor];
    _autoOpenDoor.delegate = self;
    [_autoOpenDoor startServiceToScanBeaconWithType:Scan_Type_Default];
}

- (void)stopScanIbeacon{

    [_autoOpenDoor stopServiceToScanBeacon];
}

- (void)ibeaconLocationService:(GAibeaconLocationService *)service didScanToRangeBeacons:(NSArray<GAibeaconModel *> *)beacons inRegion:(NSDictionary * _Nullable)region{

    for (GAibeaconModel * model in beacons) {
        NSString * UpUuidStr  = [NSString stringWithFormat:@"%@",model.proximityUUID];
        NSString * UpMajorStr = [NSString stringWithFormat:@"%@",model.major];
        NSString * UpMinorStr = [NSString stringWithFormat:@"%@",model.minor];
        NSString * UpRssiStr  = [NSString stringWithFormat:@"%@",model.rssi];

        if ([UpUuidStr  isEqualToString:BeaconUUID] &&
            [UpMajorStr isEqualToString:BeaconMajor] &&
            [UpMinorStr isEqualToString:BeaconMinor]) {
            
            [self resetSingnalLabelWithStr:UpRssiStr];
            UILabel * label_104 = [_setUpBackView viewWithTag:104];
            if (label_104.text.floatValue <= UpRssiStr.floatValue) {
                [self requestToOpenTheDoor];
            }
        }
    }
}

- (void)ibeaconLocationService:(GAibeaconLocationService *)service scanToBeaconError:(NSError *)error{
    BaseLog(@"%@",error);
    [self resetSingnalLabelWithStr:@" "];
    NSString * subTitle;
    switch (error.code) {
        case -10001:
            subTitle = @"ibeacon扫描服务参数错误";
            break;
            
        case -10002:
            subTitle = @"GPS定位权限错误";
            break;
            
        case -10003:
            subTitle = @"ibeacon扫描错误";
            break;
            
        default:
            subTitle = @"系统错误警告";
            break;
    }
    NSString * title     = @"ibeacon扫描服务通知";
    NSString * identifer = error.userInfo[@"NSLocalizedDescription"]   ? : @"default_Error";
    if ([identifer isEqualToString:@"GPS_Request_Error"]) {
        return;
    }
    NSString * body      = error.userInfo[@"NSLocalizedFailureReason"] ? : @"扫描发生意外，请检查设置或重启应用";
    NSDictionary * info  = error.userInfo;
    [[GALocalNoticeService sharedInstance]sendNoticeWithId:identifer Title:title subTitle:subTitle Body:body Info:info];
}

- (void)ibeaconLocationService:(GAibeaconLocationService *)service didStartMonitoringForRegion:(NSDictionary *)region{
//    BaseLog(@"开始检测区域范围：\n%@",region);
}

- (void)ibeaconLocationService:(GAibeaconLocationService *)service didEnterRegion:(NSDictionary *)region{
    NSString * title     = @"ibeacon扫描服务通知";
    NSString * body      = @"您已进入中德宏泰成都研发部，欢迎光临！";
    NSString * identifer = @"EnterState";
    [[GALocalNoticeService sharedInstance]sendNoticeWithId:identifer Title:title subTitle:nil Body:body Info:nil];
}

- (void)ibeaconLocationService:(GAibeaconLocationService *)service didExitRegion:(NSDictionary *)region{
    [self resetSingnalLabelWithStr:@" "];
    NSString * title     = @"ibeacon扫描服务通知";
    NSString * body      = @"您已离开中德宏泰成都研发部，欢迎再次光临！";
    NSString * identifer = @"ExitState";
    [[GALocalNoticeService sharedInstance]sendNoticeWithId:identifer Title:title subTitle:nil Body:body Info:nil];
}

- (void)ibeaconLocationService:(GAibeaconLocationService *)service didDetermineState:(NSInteger)state forRegion:(NSDictionary *)region{
    [self resetSingnalLabelWithStr:@" "];
//    NSString * title     = @"ibeacon扫描服务通知";
//    NSString * body;
//    NSString * identifer;
//    if (state == 1) {
//        body = @"您已进入中德宏泰成都研发部，欢迎光临！";
//        identifer = @"EnterState";
//    }else if (state == 2){
////        body = @"您现在正处于中的宏泰成都研发部势力范围边缘，请注意！";
////        identifer = @"ExitState";
//        return;
//    }else{
//        [self resetSingnalLabelWithStr:@" "];
//        return;
//    }
//    [[GALocalNoticeService sharedInstance]sendNoticeWithId:identifer Title:title subTitle:nil Body:body Info:nil];
}

#pragma mark -- 创建方法
- (UILabel *)createLabelWithTextColor:(UIColor *)textColor andText:(NSString *)text{
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.text = text;
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20.0f];
    label.numberOfLines = 0 ;
    return label;
}

#pragma mark -- 请求开门
- (void)requestToOpenTheDoor{
    
    if (_isOnRequest) return;
    
    _isOnRequest = YES;
    
    [self showAnimationOnButton];
    
    @weakify(self);
    [ibeaconNetWorkManager autoOpenTheDoorRequestComplete:^(id responseObject, BOOL isSuccess) {
        @strongify(self);
        [self dismissAnimationOnButton];
        self.isOnRequest = NO;

//        [self performSelector:@selector(changeisOnRequestStatus) withObject:nil afterDelay:2];
    }];
}

- (void)changeisOnRequestStatus{
    _isOnRequest = NO;
}

#pragma mark -- 按钮动画
- (void)showAnimationOnButton{
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if (state != UIApplicationStateActive) return;
    
    _scanButton.selected = YES;
    
    [_animationLayer removeFromSuperlayer];
    _animationLayer = nil;
    self.animationLayer = [CALayer layer];

    CGRect rect  = self.scanButton.frame;
    NSInteger pulsingCount = 6;
    double animationDuration = 3;
    
    for (int i = 0; i < pulsingCount; i++) {
        CALayer * pulsingLayer = [CALayer layer];
        pulsingLayer.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        pulsingLayer.borderColor = [UIColor whiteColor].CGColor;
        pulsingLayer.borderWidth = 1;
        pulsingLayer.cornerRadius = rect.size.height / 2;
        
        CAMediaTimingFunction * defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
        animationGroup.fillMode = kCAFillModeBackwards;
        animationGroup.beginTime = CACurrentMediaTime() + (double)i * animationDuration / (double)pulsingCount;
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = HUGE;
        animationGroup.timingFunction = defaultCurve;
        
        CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @0.84;
        scaleAnimation.toValue = @2.4;
        
        CAKeyframeAnimation * opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values = @[@1, @0.9, @0.8, @0.7, @0.6, @0.5, @0.4, @0.3, @0.2, @0.1, @0];
        opacityAnimation.keyTimes = @[@0, @0.1, @0.2, @0.3, @0.4, @0.5, @0.6, @0.7, @0.8, @0.9, @1];
        
        animationGroup.animations = @[scaleAnimation, opacityAnimation];
        [pulsingLayer addAnimation:animationGroup forKey:@"plulsing"];
        [_animationLayer addSublayer:pulsingLayer];
    }
    [self.layer insertSublayer:_animationLayer below:_scanButton.layer];
}

- (void)dismissAnimationOnButton{
    _scanButton.selected = NO;
    [_animationLayer removeFromSuperlayer];
    _animationLayer = nil;
}

#pragma mark -- 重置信号显示标签
- (void)resetSingnalLabelWithStr:(NSString *)text{

    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if (state != UIApplicationStateActive) return;
    
    UILabel * label_102 = [self.setUpBackView viewWithTag:102];
    if (label_102) {
        dispatch_async(dispatch_get_main_queue(), ^{
            label_102.text = text ? : @" ";
        });
    }
}

- (void)dealloc{
    [self dismissAnimationOnButton];
    [self stopScanIbeacon];
    [self resetSingnalLabelWithStr:@" "];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end


















