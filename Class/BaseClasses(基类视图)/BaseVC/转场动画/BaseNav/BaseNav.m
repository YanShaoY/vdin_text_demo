//
//  BaseNav.m
//  Demo
//
//  Created by YanSY on 2017/11/30.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "BaseNav.h"
@interface BaseNav ()

@end

@implementation BaseNav

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
}

#pragma mark -- 设置导航栏
- (void)setNavigationBar{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationBar.barTintColor = [UIColor colorWithRed:0.02 green:0.05 blue:0.05 alpha:1.00];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"Back"] forBarMetrics:UIBarMetricsDefault];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
