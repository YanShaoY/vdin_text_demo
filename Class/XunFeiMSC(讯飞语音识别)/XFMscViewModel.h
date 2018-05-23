//
//  XFMscViewModel.h
//  Demo
//
//  Created by YanSY on 2018/5/16.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "BaseModel.h"

@interface XFMscViewModel : BaseModel

#pragma mark -- 数据定义
/**
 默认用户词表字典
 */
@property (nonatomic,strong) NSMutableDictionary * userWordsDict;

#pragma mark -- 公共方法
/**
 创建一个按钮
 
 @param title 按钮文字
 @return 初始化后的按钮
 */
- (UIButton *)createButtonWithTitle:(NSString *)title;

/**
 字典转json字符串

 @param dict 需要转换的字典
 @return json字符串
 */
-(NSString *)dictionaryToJsonString:(NSDictionary *)dict;

@end








