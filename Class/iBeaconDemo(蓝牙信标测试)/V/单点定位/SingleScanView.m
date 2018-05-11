//
//  SingleScanView.m
//  Demo
//
//  Created by YanSY on 2018/1/2.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "SingleScanView.h"
#import "GAibeaconLocationService.h"

#define BeaconUUID  @"001FC33F-8AB5-499B-A0D5-92AA3A0CC7E7"
#define BeaconMajor @"1000"
#define BeaconMinor @"1"

@interface SingleScanView ()<GAibeaconLocationServiceDelegate>{
    
}

@property (nonatomic , strong) UITextField              * UUIDTF;
@property (nonatomic , strong) UITextField              * majorTF;
@property (nonatomic , strong) UITextField              * minorTF;
@property (nonatomic , strong) GAibeaconLocationService   * ibeaconScanS;

@end

@implementation SingleScanView
#pragma mark -- 懒加载
- (UITextField *)UUIDTF{
    if (!_UUIDTF) {
        _UUIDTF = [[UITextField alloc]initWithFrame:CGRectZero];
        _UUIDTF.borderStyle = UITextBorderStyleRoundedRect;
        _UUIDTF.placeholder = @"请输入要扫描ibeacon的UUID";
        _UUIDTF.font = [UIFont systemFontOfSize:20];
        _UUIDTF.textColor = [UIColor blueColor];
        _UUIDTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _UUIDTF.adjustsFontSizeToFitWidth = YES;
    }
    return _UUIDTF;
}

- (UITextField *)majorTF{
    if (!_majorTF) {
        _majorTF = [[UITextField alloc]init];
        _majorTF.borderStyle = UITextBorderStyleRoundedRect;
        _majorTF.placeholder = @"请输入major";
        _majorTF.font = [UIFont systemFontOfSize:20];
        _majorTF.textColor = [UIColor blueColor];
        _majorTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _majorTF.adjustsFontSizeToFitWidth = YES;
    }
    return _majorTF;
}

- (UITextField *)minorTF{
    if (!_minorTF) {
        _minorTF = [[UITextField alloc]init];
        _minorTF.borderStyle = UITextBorderStyleRoundedRect;
        _minorTF.placeholder = @"请输入minor";
        _minorTF.font = [UIFont systemFontOfSize:20];
        _minorTF.textColor = [UIColor blueColor];
        _minorTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _minorTF.adjustsFontSizeToFitWidth = YES;
    }
    return _minorTF;
}

- (GAibeaconLocationService *)ibeaconScanS{
    if (!_ibeaconScanS) {
        _ibeaconScanS = [GAibeaconLocationService sharedInstance];
//        [_ibeaconScanS setServiceWithUUID:BeaconUUID
//                                 andMajor:BeaconMajor
//                                 andMinor:BeaconMinor];
        [_ibeaconScanS setServiceWithUUID:BeaconUUID
                                 andMajor:nil
                                 andMinor:nil];
        _ibeaconScanS.delegate = self;
    }
    return _ibeaconScanS;
}

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
    
}

// 添加UI
- (void)addUI{
    
    UILabel * ibeaconUUID = [[UILabel alloc]initWithFrame:CGRectZero];
    ibeaconUUID.tag = 101;
    ibeaconUUID.text = @"请输入搜索UUID:";
    ibeaconUUID.textColor = [UIColor blackColor];
    ibeaconUUID.backgroundColor = [UIColor clearColor];
    ibeaconUUID.numberOfLines = 0;
    ibeaconUUID.textAlignment = NSTextAlignmentLeft;
    ibeaconUUID.font = [UIFont systemFontOfSize:20];
    [self addSubview:ibeaconUUID];
    
    self.UUIDTF.text = BeaconUUID;
    [self addSubview:self.UUIDTF];

    // major和minor提示框
    UILabel * majorLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    majorLabel.tag = 102;
    majorLabel.text = @"请输入搜索的major和minor参数";
    majorLabel.textColor = [UIColor blackColor];
    majorLabel.backgroundColor = [UIColor clearColor];
    majorLabel.numberOfLines = 0;
    majorLabel.textAlignment = NSTextAlignmentLeft;
    majorLabel.font = [UIFont systemFontOfSize:20];
    [self addSubview:majorLabel];

    self.majorTF.text = BeaconMajor;
    [self addSubview:self.majorTF];
    
    self.minorTF.text = BeaconMinor;
    [self addSubview:self.minorTF];

    // 开始扫描按钮
    UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    scanButton.tag = 103;
    [scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    scanButton.backgroundColor = UIColorFromRGBA(0x3399CC, 1);
    scanButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [scanButton addTarget:self action:@selector(scanButtonAction:) forControlEvents: UIControlEventTouchUpInside];
    [scanButton.layer setMasksToBounds:YES];
    [scanButton.layer  setCornerRadius:8];
    [scanButton setTitle:@"开始扫描" forState:UIControlStateNormal];
    [scanButton setTitle:@"开始扫描" forState:UIControlStateHighlighted];
    [self addSubview:scanButton];
    
}

// 添加约束
- (void)addConstraint{
    UILabel * ibeaconUUID = [self viewWithTag:101];
    [ibeaconUUID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(10);
        make.right.equalTo(self.mas_right).offset(-10);
        make.top.equalTo(self.mas_top).offset(30);
    }];
    
    [self.UUIDTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(10);
        make.right.equalTo(self.mas_right).offset(-10);
        make.top.equalTo(ibeaconUUID.mas_bottom).offset(20);
        make.height.mas_equalTo(50.0f);
    }];
    
    UILabel * majorLabel = [self viewWithTag:102];
    [majorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(10);
        make.right.equalTo(self.mas_right).offset(-10);
        make.top.equalTo(self.UUIDTF.mas_bottom).offset(20);
    }];
    
    [self.majorTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(10);
        make.top.equalTo(majorLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(50.0f);
        make.right.equalTo(self.minorTF.mas_left).offset(-10);
    }];
    
    [self.minorTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-10);
        make.top.equalTo(majorLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(50.0f);
        make.left.equalTo(self.majorTF.mas_right).offset(10);
        make.width.equalTo(self.majorTF.mas_width);
    }];
    
    UIButton * scanButton = [self viewWithTag:103];
    [scanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(50);
        make.right.equalTo(self.mas_right).offset(-50);
        make.height.mas_equalTo(50.0f);
        make.top.equalTo(self.minorTF.mas_bottom).offset(30);
    }];
    
}

#pragma mark - 扫描按钮点击响应事件
- (void)scanButtonAction:(UIButton *)sender{
    [self endEditing:YES];
    NSString * btTitle = [[NSString alloc]initWithString:sender.titleLabel.text];
    if ([btTitle isEqualToString:@"停止扫描"]) {
        [sender setTitle:@"开始扫描" forState:UIControlStateNormal];
        [sender setTitle:@"开始扫描" forState:UIControlStateHighlighted];
        sender.backgroundColor = UIColorFromRGBA(0x3399CC, 1);
        [self.ibeaconScanS stopServiceToScanBeacon];
        
        for (UIView * view in self.subviews) {
            if ([view isKindOfClass:[UITextView class]]) {
                [view removeFromSuperview];
            }
        }
        
    }else{
        
//        UITextView * textView = (UITextView*)[self viewWithTag:self.minorTF.text.integerValue];
//        if (textView) {
//            textView.userInteractionEnabled = YES;
//            textView.text = @"暂无数据";
//        }
        
        [sender setTitle:@"停止扫描" forState:UIControlStateNormal];
        [sender setTitle:@"停止扫描" forState:UIControlStateHighlighted];
        sender.backgroundColor = [UIColor colorWithRed:1.0 green:0.349 blue:0.5216 alpha:1.0];
        
        [self.ibeaconScanS setServiceWithUUID:self.UUIDTF.text andMajor:self.majorTF.text andMinor:self.minorTF.text];
        [self.ibeaconScanS startServiceToScanBeaconWithType:Scan_Type_Default];
        
    }
    
}

#pragma mark -- 关于ibeacon
- (void)ibeaconLocationService:(GAibeaconLocationService *)service didScanToRangeBeacons:(NSArray<GAibeaconModel *> *)beacons inRegion:(NSDictionary * _Nullable)region{
    
    for (GAibeaconModel * model in beacons) {
//        NSLog(@"%@",model);
        // 获取数据
        NSString * uuid = [NSString stringWithFormat:@"%@",model.proximityUUID];
        NSString * major = [NSString stringWithFormat:@"%@",model.major];
        NSString * minor = [NSString stringWithFormat:@"%@",model.minor];
        
        NSString * acc = [NSString stringWithFormat:@"%@",model.accuracy];
        NSString * rssi = [NSString stringWithFormat:@"%@",model.rssi];
        
        
        NSString * message = [NSString stringWithFormat:@"UUID==%@\n\n主频(major)==%@\n\n副频(minor)==%@\n\n实测距离（acc）==%@\n\n信号强度(rssi)==%@\n\n",uuid,major,minor,acc,rssi];
        
//        UITextView*textView=(UITextView*)[self viewWithTag:model.minor.integerValue];
//        textView.userInteractionEnabled = NO;
//
//        if (textView) {
//            textView.text=message;
//        }
//        else{
//            textView=[[UITextView alloc]initWithFrame:CGRectZero];
//            textView.backgroundColor=[UIColor clearColor];
//            textView.textColor=[UIColor blueColor];
//            textView.tag= model.minor.integerValue;
//            [self addSubview:textView];
//            textView.text=message;
//
//            UIButton * scanButton = [self viewWithTag:103];
//            [textView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self.mas_left).offset(30);
//                make.right.equalTo(self.mas_right).offset(-30);
//                make.top.equalTo(scanButton.mas_bottom).offset(30);
//                make.bottom.equalTo(self.mas_bottom).offset(-30);
//            }];
//        }
 
    }
}

- (void)ibeaconLocationService:(GAibeaconLocationService *)service scanToBeaconError:(NSError *)error{
    BaseLog(@"%@",error);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end






















