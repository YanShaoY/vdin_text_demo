//
//  ManyScanViewOne.m
//  Demo
//
//  Created by YanSY on 2018/1/2.
//  Copyright © 2018年 YanSY. All rights reserved.
//


#import "ManyScanViewOne.h"

#define BeaconUUID  @"4CDBC040-657A-4847-B266-7E31D9E2C3D9"

@interface ManyScanViewOne(){
    
    UITextField * _UUIDTextField;

}

@end

@implementation ManyScanViewOne

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

//  配置
- (void)configuration{
    
}

// 添加UI
- (void)addUI{
    // 输入UUID的提示框
    UILabel * ibeaconUUID = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 150, 40)];
    ibeaconUUID.text = @"请输入搜索UUID:";
    ibeaconUUID.textColor = [UIColor blackColor];
    ibeaconUUID.backgroundColor = [UIColor lightTextColor];
    ibeaconUUID.numberOfLines = 0;
    ibeaconUUID.textAlignment = NSTextAlignmentLeft;
    ibeaconUUID.font = [UIFont systemFontOfSize:18];
    [self addSubview:ibeaconUUID];
    
    // UUID输入框
    _UUIDTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 120,SCREENWIDTH-20, 40)];
    _UUIDTextField.borderStyle = UITextBorderStyleRoundedRect;
    _UUIDTextField.placeholder = @"请输入要扫描ibeacon的UUID";
    _UUIDTextField.font = [UIFont systemFontOfSize:18];
    _UUIDTextField.textColor = [UIColor blueColor];
    _UUIDTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _UUIDTextField.adjustsFontSizeToFitWidth = YES;
    _UUIDTextField.keyboardType = UIKeyboardTypeASCIICapable;
    [self addSubview:_UUIDTextField];
    
    // major和minor和坐标提示框
    UILabel * majorLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 160, SCREENWIDTH-20, 40)];
    majorLabel.text = @"请分别输入major和minor参数及对应坐标：";
    majorLabel.textColor = [UIColor blackColor];
    majorLabel.backgroundColor = [UIColor lightTextColor];
    majorLabel.numberOfLines = 0;
    majorLabel.textAlignment = NSTextAlignmentLeft;
    majorLabel.font = [UIFont systemFontOfSize:18];
    [self addSubview:majorLabel];
    
    // major
    for (int i = 0; i < 4; i ++) {
        UITextField * majorText = [[UITextField alloc]initWithFrame:CGRectMake(10, 200+i*(40+10), (SCREENWIDTH-30)/4, 40)];
        majorText.borderStyle = UITextBorderStyleRoundedRect;
        majorText.placeholder = [NSString stringWithFormat:@"%d-major",i+1];
        majorText.font = [UIFont systemFontOfSize:15];
        majorText.textColor = [UIColor blueColor];
        majorText.clearButtonMode = UITextFieldViewModeWhileEditing;
        majorText.adjustsFontSizeToFitWidth = YES;
        majorText.keyboardType = UIKeyboardTypeNumberPad;
        majorText.tag = 100+i+1;
        [self addSubview:majorText];
        UITextField * minorText = [[UITextField alloc]initWithFrame:CGRectMake((SCREENWIDTH-30)/4+15,200+i*(40+10), (SCREENWIDTH-30)/4, 40)];
        minorText.borderStyle = UITextBorderStyleRoundedRect;
        minorText.placeholder = [NSString stringWithFormat:@"%d-minor",i+1];
        minorText.font = [UIFont systemFontOfSize:15];
        minorText.textColor = [UIColor blueColor];
        minorText.clearButtonMode = UITextFieldViewModeWhileEditing;
        minorText.adjustsFontSizeToFitWidth = YES;
        minorText.keyboardType = UIKeyboardTypeNumberPad;
        minorText.tag = 200+i+1;
        [self addSubview:minorText];
        
        UITextField * XText = [[UITextField alloc]initWithFrame:CGRectMake((SCREENWIDTH-30)/4*2+20,200+i*(40+10), (SCREENWIDTH-30)/4, 40)];
        XText.borderStyle = UITextBorderStyleRoundedRect;
        XText.placeholder = [NSString stringWithFormat:@"%d-X坐标",i+1];
        XText.font = [UIFont systemFontOfSize:15];
        XText.textColor = [UIColor blueColor];
        XText.clearButtonMode = UITextFieldViewModeWhileEditing;
        XText.adjustsFontSizeToFitWidth = YES;
        XText.keyboardType = UIKeyboardTypeNumberPad;
        XText.tag = 300+i+1;
        [self addSubview:XText];
        
        UITextField * YText = [[UITextField alloc]initWithFrame:CGRectMake((SCREENWIDTH-30)/4*3+25,200+i*(40+10), (SCREENWIDTH-30)/4, 40)];
        YText.borderStyle = UITextBorderStyleRoundedRect;
        YText.placeholder = [NSString stringWithFormat:@"%d-Y坐标",i+1];
        YText.font = [UIFont systemFontOfSize:15];
        YText.textColor = [UIColor blueColor];
        YText.clearButtonMode = UITextFieldViewModeWhileEditing;
        YText.adjustsFontSizeToFitWidth = YES;
        YText.keyboardType = UIKeyboardTypeNumberPad;
        YText.tag = 400+i+1;
        [self addSubview:YText];
        
    }
    
    // scaleLabel 比例尺
    UILabel * scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 400,130, 40)];
    scaleLabel.text = @"请输入比例尺：";
    scaleLabel.textColor = [UIColor blackColor];
    scaleLabel.backgroundColor = [UIColor lightTextColor];
    scaleLabel.numberOfLines = 0;
    scaleLabel.textAlignment = NSTextAlignmentLeft;
    scaleLabel.font = [UIFont systemFontOfSize:18];
    [self addSubview:scaleLabel];
    
    
    // scale
    UITextField * scaleTextField = [[UITextField alloc]initWithFrame:CGRectMake(140, 400,SCREENWIDTH-160, 40)];
    scaleTextField.borderStyle = UITextBorderStyleRoundedRect;
    scaleTextField.placeholder = @"请输入比例尺（米/坐标）";
    scaleTextField.font = [UIFont systemFontOfSize:18];
    scaleTextField.textColor = [UIColor blueColor];
    scaleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    scaleTextField.adjustsFontSizeToFitWidth = YES;
    scaleTextField.keyboardType = UIKeyboardTypeASCIICapable;
    scaleTextField.tag = 100;
    [self addSubview:scaleTextField];
    
    
    // 开始扫描按钮
    UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    scanButton.frame = CGRectMake(0.0f, 0.0f, 300.0f, 50);
    scanButton.center = CGPointMake(SCREENWIDTH/2, 480);
    [scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    scanButton.backgroundColor = [UIColor colorWithRed:0.3098 green:0.7333 blue:0.7608 alpha:1.0];
    scanButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [scanButton addTarget:self action:@selector(ScanButtonAction:) forControlEvents: UIControlEventTouchUpInside];
    [scanButton.layer setMasksToBounds:YES];
    [scanButton.layer  setCornerRadius:8];
    [scanButton setTitle:@"开始扫描" forState:UIControlStateNormal];
    [scanButton setTitle:@"开始扫描" forState:UIControlStateHighlighted];
    [self addSubview:scanButton];
    
}

// 添加约束
- (void)addConstraint{
    _UUIDTextField.text = BeaconUUID;
    for (int i = 1; i < 5; i ++) {
        NSString * key =[NSString stringWithFormat:@"beaconInformation-%d",i];
        NSDictionary * beaconInformation = [[NSUserDefaults standardUserDefaults]objectForKey:key];
        UITextField * majorText = (UITextField *)[self viewWithTag:100+i];
        UITextField * minorText = (UITextField *)[self viewWithTag:200+i];
        UITextField * XText = (UITextField *)[self viewWithTag:300+i];
        UITextField * YText = (UITextField *)[self viewWithTag:400+i];
        if (beaconInformation) {
            majorText.text = [NSString stringWithFormat:@"%@",[beaconInformation objectForKey:@"major"]];
            minorText.text =[NSString stringWithFormat:@"%@", [beaconInformation objectForKey:@"minor"]];
            XText.text = [NSString stringWithFormat:@"%@",[beaconInformation objectForKey:@"beaconX"]];
            YText.text = [NSString stringWithFormat:@"%@",[beaconInformation objectForKey:@"beaconY"]];
        }
    }
}

#pragma mark -- action


// 
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end












