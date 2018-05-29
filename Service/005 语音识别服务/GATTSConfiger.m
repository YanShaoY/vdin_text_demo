//
//  GATTSConfiger.m
//  Demo
//
//  Created by YanSY on 2018/5/16.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GATTSConfiger.h"
#import "GAFileService.h"

@implementation GATTSConfiger

#pragma mark -- 初始化
- (id)init{
    self = [super init];
    if (self) {
        [self defaultIATSetting];
        return  self;
    }
    return nil;
}

#pragma mark -- 语音识别设置参数
-(void)defaultIATSetting {
    
    _speed = @"50";
    _volume = @"50";
    _pitch = @"50";
    _sampleRate = @"16000";
    _vcnName = @"xiaoyan";
    _textEnCoding = @"unicode";
    _engineType = [IFlySpeechConstant TYPE_CLOUD];
    _autoPlayURL = YES;
    // 若uri设为nil,则默认的音频保存在library/cache下
    NSString * path = [GAFileService obtainGADir];
    _uriPath = [NSString stringWithFormat:@"%@/%@",path,@"uri.pcm"];
    
/*
 
 云端支持发音人：小燕（xiaoyan）、小宇（xiaoyu）、凯瑟琳（Catherine）、亨利（henry）、
 玛丽（vimary）、小研（vixy）、小琪（vixq）、小峰（vixf）、小梅（vixm）、小莉（vixl）、
 小蓉（四川话）、小芸（vixyun）、小坤（vixk）、小强（vixqa）、小莹（vixying）、 小新（vixx）、
 楠楠（vinn）老孙（vils
 
 对于网络TTS的发音人角色，不同引擎类型支持的发音人不同，使用中请注意选择。
*/
    _vcnNickNameArray = @[@"小燕", @"小宇", @"小研", @"小琪",@"小峰",@"小新",@"小坤",@"越南语",@"印地语",@"西班牙语",@"俄语",@"法语"];
    _vcnIdentiferArray = @[@"xiaoyan",@"xiaoyu",@"vixy",@"vixq",@"vixf",@"vixx",@"vixk",@"XiaoYun",@"Abha",@"Gabriela",@"Allabent",@"Mariane"];
}

- (GATTSConfiger *)configerCopy{
    GATTSConfiger * configer = [[GATTSConfiger alloc]init];
    configer.speed = self.speed;
    configer.volume = self.volume;
    configer.pitch = self.pitch;
    configer.sampleRate = self.sampleRate;
    configer.vcnName = self.vcnName;
    configer.textEnCoding = self.textEnCoding;
    configer.engineType = self.engineType;
    configer.autoPlayURL = self.autoPlayURL;
    configer.uriPath = self.uriPath;
    configer.vcnNickNameArray = self.vcnNickNameArray;
    configer.vcnIdentiferArray = self.vcnIdentiferArray;

    return configer;
}

@end



