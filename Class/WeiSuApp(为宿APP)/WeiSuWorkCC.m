//
//  WeiSuWorkCC.m
//  Demo
//
//  Created by YanSY on 2018/6/19.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "WeiSuWorkCC.h"
#import "WSTopSlidMenuView.h"

@interface WeiSuWorkCC ()

@property (nonatomic , copy)   UIViewController  * (^VCGenerator)(id params);

#pragma mark -- 视图UI
@property (nonatomic , strong) UIView            * workCCbackView;
@property (nonatomic , strong) WSTopSlidMenuView * topMenuView;
@property (nonatomic , strong) UIScrollView      * bottomScrollView;

@end

@implementation WeiSuWorkCC

+ (id)instanceWorkCC{
    return [[WeiSuWorkCC alloc]init];
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        [self configuration];
        [self addUI];
        [self addConstraint];
    }
    return self;
}

- (void)fetchData{

    CGFloat height = 44+20;
    if (@available(iOS 11.0, *)) {
        height += self.workCCbackView.viewController.view.safeAreaInsets.bottom;
    }
    
    NSLog(@"%s----height = %lf",__FUNCTION__,height);
}

/// 配置
- (void)configuration{

}

/// 添加 UI
- (void)addUI{
    
    [self.workCCbackView addSubview:self.topMenuView];
    [self.workCCbackView addSubview:self.bottomScrollView];
}

/// 添加约束
- (void)addConstraint{

    [self.topMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.workCCbackView);
    }];
    
    [self.bottomScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topMenuView.mas_bottom).offset(-200.f);
        make.left.right.bottom.equalTo(self.workCCbackView);
    }];

}


#pragma mark -- 懒加载

- (UIView *)workCCbackView{
    if (!_workCCbackView) {
        _workCCbackView = [[UIView alloc]initWithFrame:(CGRect){0, 64, SCREENWIDTH, SCREENHEIGHT - 49 - 64}];
        _workCCbackView.backgroundColor = [UIColor whiteColor];
    }
    return _workCCbackView;
}

- (WSTopSlidMenuView *)topMenuView{
    if (!_topMenuView) {
        _topMenuView = [[WSTopSlidMenuView alloc]init];
        
    }
    return _topMenuView;
}

- (UIScrollView *)bottomScrollView{
    if (!_bottomScrollView) {
        _bottomScrollView = [[UIScrollView alloc]init];
        _bottomScrollView.showsHorizontalScrollIndicator = NO;
        _bottomScrollView.showsVerticalScrollIndicator = NO;
        _bottomScrollView.backgroundColor = [UIColor whiteColor];
        _bottomScrollView.layer.masksToBounds= YES;
        _bottomScrollView.layer.cornerRadius = 10.f;
    }
    return _bottomScrollView;
}



@end







