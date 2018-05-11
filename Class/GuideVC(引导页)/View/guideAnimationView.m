
//
//  guideAnnimationView.m
//  Demo
//
//  Created by YanSY on 2017/11/23.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "guideAnimationView.h"

@implementation guideAnimationView

- (instancetype)initAnimationViewWithNamed:(NSString *)name andLoop:(BOOL)loop{
    
    guideAnimationView * animationView = [guideAnimationView animationNamed:name];
    animationView.frame = KEYWINDOW.bounds;
    animationView.loopAnimation = loop;
    animationView.contentMode = UIViewContentModeScaleAspectFill;
    animationView.animationProgress = 0;
    [KEYWINDOW addSubview:animationView];
    [KEYWINDOW bringSubviewToFront:animationView];
    return animationView;
}
- (void)dealloc
{
    NSLog(@"guideAnimationView--dealloc");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
