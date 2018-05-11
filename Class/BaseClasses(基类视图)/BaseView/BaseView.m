
//
//  BaseView.m
//  Demo
//
//  Created by YanSY on 2017/12/20.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self configuration];
//        [self addUI];
//        [self addConstraint];
    }
    return self;
}

/// 配置
- (void)configuration{
    BaseLog(@"这个方法应该子类实现");
}
/// 添加 UI
- (void)addUI{
    BaseLog(@"这个方法应该子类实现");
}
/// 添加约束
- (void)addConstraint{
    BaseLog(@"这个方法应该子类实现");
}
/// 显示视图
- (void)showSelf{
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    [window addSubview:self];
    
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    self.center = CGPointMake(window.bounds.size.width/2.0f, window.bounds.size.height/2.0f);
    [UIView animateWithDuration:0.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}
/// 隐藏视图
- (void)dismissSelf{
    [UIView animateWithDuration:0.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
