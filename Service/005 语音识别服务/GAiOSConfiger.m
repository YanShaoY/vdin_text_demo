//
//  GAiOSConfiger.m
//  Demo
//
//  Created by YanSY on 2018/6/6.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GAiOSConfiger.h"

@implementation GAiOSConfiger

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
    
    _language = @"简体中文";
}

- (NSDictionary *)languageDictKey{
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:@"zh-CN" forKey:@"简体中文"];
    [dict setValue:@"zh-HK" forKey:@"繁体中文"];
    [dict setValue:@"en-US" forKey:@"英语(美国)"];
    [dict setValue:@"ko-KR" forKey:@"韩文(韩国)"];
    [dict setValue:@"fr-FR" forKey:@"法语(法国)"];

    return dict;
}

/**
 复制拷贝当前配置
 
 @return 返回拷贝后的配置
 */
- (GAiOSConfiger *)configerCopy{
    GAiOSConfiger * configer = [[GAiOSConfiger alloc]init];
    configer.language = self.language;
    
    return configer;
}

/**
 根据语言名称找到对应的key
 
 @param name 语言名字 如:简体中文
 @return 对应的key
 */
- (NSString *)foundLanguageKeyForName:(NSString *)name{
    NSDictionary * languagedict = [self languageDictKey];
    if ([languagedict valueForKey:name]) {
        return [languagedict valueForKey:name];
    }
    return [languagedict valueForKey:@"简体中文"];
}

@end
















