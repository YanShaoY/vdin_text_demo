//
//  XunFeiMscCC.m
//  Demo
//
//  Created by YanSY on 2018/5/11.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XunFeiMscCC.h"

#import "xunFeiMscPopMenuView.h"
#import "XFVoiceDictationView.h"
#import "XFVoiceSyntheticView.h"

@interface XunFeiMscCC (){
    
}

/// 显示的视图状态
@property (nonatomic , assign) NSUInteger showViewType;
/// 边缘手势
@property (nonatomic , strong) UIScreenEdgePanGestureRecognizer * screenEdgePan;
/// 背景视图
@property (nonatomic , strong) UIView            * backView;

@end

@implementation XunFeiMscCC

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
    return [[XunFeiMscCC alloc]init];
}

- (void)fetchData{
    
    [self.backView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    switch (self.showViewType) {
        case 0:
        {
            XFVoiceDictationView * voiceDictationView = [[XFVoiceDictationView alloc]init];
            voiceDictationView.backgroundColor = [UIColor clearColor];
            [_backView addSubview:voiceDictationView];
        }
            break;
            
        case 1:
        {
            XFVoiceSyntheticView * voiceSyntheticView = [[XFVoiceSyntheticView alloc]init];
            voiceSyntheticView.backgroundColor = [UIColor clearColor];
            [_backView addSubview:voiceSyntheticView];
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
            [xunFeiMscPopMenuView showXFMscPopMenuViewWithType:self.showViewType WithBlock:^(NSUInteger index) {
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

















