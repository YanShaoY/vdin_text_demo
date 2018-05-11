//
//  UIView+FindViewController.m
//  Demo
//
//  Created by YanSY on 2017/12/18.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "UIView+FindViewController.h"

@implementation UIView (FindViewController)

- (CGFloat)tx {
    return self.transform.tx;
}

- (void)setTx:(CGFloat)tx {
    CGAffineTransform transform = self.transform;
    transform.tx = tx;
    self.transform = transform;
}

- (CGFloat)ty {
    return self.transform.ty;
}

- (void)setTy:(CGFloat)ty {
    CGAffineTransform transform = self.transform;
    transform.ty = ty;
    self.transform = transform;
}


- (nullable UIViewController *)viewController{
    
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: [UIViewController class]]) {
            return (UIViewController *)responder;
        }
    return nil;
}

@end
