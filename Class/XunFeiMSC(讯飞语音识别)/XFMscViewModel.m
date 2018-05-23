//
//  XFMscViewModel.m
//  Demo
//
//  Created by YanSY on 2018/5/16.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XFMscViewModel.h"

@implementation XFMscViewModel

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark -- 用户词组初始化
- (NSMutableDictionary *)userWordsDict{
    if (!_userWordsDict) {
        
        _userWordsDict = [[NSMutableDictionary alloc]init];
        
        NSArray * words01 = [NSArray arrayWithObjects:@"中德宏泰",@"天祥广场",@"高新区",@"成都市", nil];
        NSArray * words02 = [NSArray arrayWithObjects:@"孙二浪",@"污妖汪",@"哈哈全",@"大润发",@"二姐",@"YanSY",@"超级无敌飞天霹雳荒野大嫖虫",nil];
        
        NSDictionary * dict01 = [self jointName:@"我的常用词" andWords:words01];
        NSDictionary * dict02 = [self jointName:@"我的好友" andWords:words02];
        
        [_userWordsDict setValue:@[dict01,dict02] forKey:@"userword"];
    }
    return _userWordsDict;
}

#pragma mark -- 拼接词组名称和数据数组
- (NSDictionary *)jointName:(NSString *)name andWords:(NSArray *)words{

    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:name forKey:@"name"];
    [dict setValue:words forKey:@"words"];
    return dict;
}


#pragma mark -- 按钮初始化
- (UIButton *)createButtonWithTitle:(NSString *)title{
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = UIColorFromRGBA(0x5C96FF, 1);
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 6.f;
    [button setTitleColor:UIColorFromRGBA(0xFFFFFF, 1.f) forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
    
}

#pragma mark -- 字典转json字符串
-(NSString *)dictionaryToJsonString:(NSDictionary *)dict{
    
    NSError  * error;
    NSData   * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}






@end








