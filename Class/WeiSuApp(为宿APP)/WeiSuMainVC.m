//
//  WeiSuMainVC.m
//  Demo
//
//  Created by YanSY on 2018/6/19.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "WeiSuMainVC.h"

#import "GAWorkVC.h"


@interface WeiSuMainVC ()


/**
 跳转按钮
 */
@property (nonatomic , strong) UIButton * jumpButton;

@end

@implementation WeiSuMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.title = @"为宿APP";
}

#pragma mark -- 添加 UI
- (void)addUI{
    
    self.jumpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _jumpButton.backgroundColor = UIColorFromRGBA(0x5C96FF, 1);
    _jumpButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    _jumpButton.layer.masksToBounds = YES;
    _jumpButton.layer.cornerRadius = 6.f;
    [_jumpButton setTitleColor:UIColorFromRGBA(0xFFFFFF, 1.f) forState:UIControlStateNormal];
    [_jumpButton setTitle:@"跳转按钮" forState:UIControlStateNormal];
    [self.jumpButton addTarget:self action:@selector(jumpButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jumpButton];
    
}

#pragma mark -- 添加约束
- (void)addConstraint{
    
    [self.jumpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.left.equalTo(self.view.mas_left).offset(50.f);
        make.right.equalTo(self.view.mas_right).offset(-50.f);
        make.height.mas_equalTo(50.f);
    }];
    
}

- (void)jumpButtonClick:(UIButton *)sender{

    GAWorkVC * jumpVC =[[GAWorkVC alloc]init];
    [self.navigationController pushViewController:jumpVC animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
