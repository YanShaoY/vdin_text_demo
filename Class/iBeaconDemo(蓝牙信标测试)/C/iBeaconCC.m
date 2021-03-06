//
//  iBeaconCC.m
//  Demo
//
//  Created by YanSY on 2017/12/21.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "iBeaconCC.h"
#import "ibeaconPopMenuView.h"
#import "EntranceGuardView.h"
#import "SingleScanView.h"
@interface iBeaconCC (){

}
/// 显示的视图状态
@property (nonatomic , assign) NSUInteger showViewType;
/// 边缘手势
@property (nonatomic , strong) UIScreenEdgePanGestureRecognizer * screenEdgePan;
/// 背景视图
@property (nonatomic , strong) UIView            * backView;


@end

@implementation iBeaconCC

#pragma mark -- 懒加载
- (UIScreenEdgePanGestureRecognizer *)screenEdgePan{
    if (!_screenEdgePan) {
        _screenEdgePan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanAction:)];
        _screenEdgePan.edges = UIRectEdgeRight;
    }
    return _screenEdgePan;
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]init];
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}
#pragma mark -- 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showViewType = 0;
        [self.backView addGestureRecognizer:self.screenEdgePan];
    }
    return self;
}

+(id)instanceCC{
    return [[iBeaconCC alloc]init];
}

- (void)fetchData{
    
    [self.backView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    switch (self.showViewType) {
        case 0:
        {
            EntranceGuardView* entranceView = [[EntranceGuardView alloc]init];
            entranceView.backgroundColor = [UIColor clearColor];
            [_backView addSubview:entranceView];
        }
            break;

        case 1:
        {
            SingleScanView* singleView = [[SingleScanView alloc]init];
            singleView.backgroundColor = [UIColor clearColor];
            [_backView addSubview:singleView];
        }
            break;

        default:
            break;
    }

    [self addConstraint];

    [UIView animateWithDuration:1 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.backView.viewController.view cache:YES];
    }];

}

- (void)addConstraint{
    
    for (UIView * view in _backView.subviews) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.backView);
        }];
    }
}

#pragma mark -- private methods
/// 手势点击响应
- (void)handlePanAction:(UIScreenEdgePanGestureRecognizer *)sender{
        
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGFloat navTx = _backView.viewController.navigationController.view.tx;
        if (navTx < SCREENWIDTH/4) {
            [_backView removeGestureRecognizer:_screenEdgePan];
            @weakify(self);
            [ibeaconPopMenuView showIBeaconPopMenuViewWithType:self.showViewType WithBlock:^(NSUInteger index) {
                @strongify(self);
                [self.backView addGestureRecognizer:self.screenEdgePan];
                if (self.showViewType != index) {
                    self.showViewType = index;
                    [self fetchData];
                }
                
            }];
        }
    }
}

@end















