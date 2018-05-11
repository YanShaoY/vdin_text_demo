//
//  BaseCC.m
//  Demo
//
//  Created by YanSY on 2017/12/20.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "BaseCC.h"

@implementation BaseCC

+ (id)instanceCC{
    BaseLog(@"这个方法应该子类实现");
    return [[BaseCC alloc]init];
}

#pragma mark - property
- (UIView *)backView{
    BaseLog(@"这个方法应该子类实现");
    return [[UIView alloc]init];
}

- (void)fetchData{
    BaseLog(@"这个方法应该子类实现");
}

@end
