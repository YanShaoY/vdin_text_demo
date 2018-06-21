//
//  WeiSuWorkCC.m
//  Demo
//
//  Created by YanSY on 2018/6/19.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "WeiSuWorkCC.h"
#import "WSTopSlidMenuView.h"



@interface WeiSuWorkCC ()<UIScrollViewDelegate>

@property (nonatomic , copy)   UIViewController  * (^VCGenerator)(id params);

#pragma mark -- 视图UI
@property (nonatomic , strong) UIView            * workCCbackView;
@property (nonatomic , strong) WSTopSlidMenuView * topMenuView;
@property (nonatomic , strong) UIScrollView      * bottomScrollView;

@property (nonatomic) CGPoint scrollViewStartPosPoint;
@property (nonatomic) int     scrollDirection;



@end



@implementation WeiSuWorkCC

//@synthesize scrollViewStartPosPoint = _scrollViewStartPosPoint;
//@synthesize scrollDirection = _scrollDirection;

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

- (void)fetchDataWithViews:(NSArray *)views{

    CGFloat height = 44+20;
    if (@available(iOS 11.0, *)) {
        height += self.workCCbackView.viewController.view.safeAreaInsets.bottom;
    }
    
    NSLog(@"%s----height = %lf",__FUNCTION__,height);
    
    for (int i = 0; i < views.count; i ++) {
        UIView * viewVC = views[i];
        [viewVC setFrame:CGRectMake(i*viewVC.frame.size.width, 0, viewVC.frame.size.width, viewVC.frame.size.height)];
        [self.bottomScrollView addSubview:viewVC];
    }

    
    [self.bottomScrollView setContentSize:CGSizeMake(SCREENWIDTH * views.count, SCREENHEIGHT+400)];
    self.bottomScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(400, 0, 0, 0);

}

/// 配置
- (void)configuration{
    _scrollDirection = 0;

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
        make.top.equalTo(self.workCCbackView.mas_top).offset(300.f);
        make.left.right.bottom.equalTo(self.workCCbackView);
    }];

}

#pragma mark -- 实现滚动UIScrollViewDelegate 协议
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    NSLog(@"%lf",offsetY);
    
    [self.bottomScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.workCCbackView.mas_top).offset(300.f-offsetY);
    }];
    
    if (self.scrollDirection == 0){
        
        if (fabs(self.scrollViewStartPosPoint.x-scrollView.contentOffset.x)<
            fabs(self.scrollViewStartPosPoint.y-scrollView.contentOffset.y)){
            self.scrollDirection = 1;
        } else {
            self.scrollDirection = 2;
        }
    }
    
    if (self.scrollDirection == 1) {
        scrollView.contentOffset = CGPointMake(self.scrollViewStartPosPoint.x,scrollView.contentOffset.y);
    } else if (self.scrollDirection == 2){
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x,self.scrollViewStartPosPoint.y);
    }
    
    
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.scrollViewStartPosPoint = scrollView.contentOffset;
    self.scrollDirection = 0;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        self.scrollDirection =0;
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.scrollDirection = 0;
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
//        _topMenuView.delegate = self;
    }
    return _topMenuView;
}

- (UIScrollView *)bottomScrollView{
    if (!_bottomScrollView) {
        _bottomScrollView = [[UIScrollView alloc]init];
        _bottomScrollView.showsHorizontalScrollIndicator = YES;
        _bottomScrollView.showsVerticalScrollIndicator = YES;
        _bottomScrollView.backgroundColor = [UIColor clearColor];
        _bottomScrollView.bounces = NO;
//        _bottomScrollView.layer.masksToBounds= YES;
//        _bottomScrollView.layer.cornerRadius = 10.f;
        if (@available(iOS 11.0, *)) {
            _bottomScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _bottomScrollView.delegate = self;
        [_bottomScrollView setPagingEnabled:YES];
        [_bottomScrollView setScrollEnabled:YES];
        _bottomScrollView.directionalLockEnabled = YES;

    }
    return _bottomScrollView;
}



@end







