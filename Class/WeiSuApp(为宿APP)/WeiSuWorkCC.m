//
//  WeiSuWorkCC.m
//  Demo
//
//  Created by YanSY on 2018/6/19.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "WeiSuWorkCC.h"

@interface WeiSuWorkCC ()

@property (nonatomic , copy)   UIViewController *(^VCGenerator)(id params);
@property (nonatomic , strong) UIScrollView * workCCbackView;

#pragma mark -- 视图UI
@property (nonatomic , strong) UIImageView * topImageView;

@end

@implementation WeiSuWorkCC

+ (id)instanceWorkCC{
    return [[WeiSuWorkCC alloc]init];
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)fetchData{
    


}

#pragma mark -- 懒加载
- (UIScrollView *)workCCbackView{
    if (!_workCCbackView) {
        _workCCbackView = [[UIScrollView alloc]initWithFrame:(CGRect){0, 64, SCREENWIDTH, SCREENHEIGHT - 49 - 64}];
        _workCCbackView.showsHorizontalScrollIndicator = NO;
        _workCCbackView.showsVerticalScrollIndicator = NO;
        _workCCbackView.backgroundColor = [UIColor whiteColor];
    }
    return _workCCbackView;
}

@end







