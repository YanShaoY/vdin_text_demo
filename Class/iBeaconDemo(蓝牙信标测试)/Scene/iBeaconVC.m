//
//  iBeaconVC.m
//  Demo
//
//  Created by YanSY on 2017/12/14.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "iBeaconVC.h"
#import "iBeaconCC.h"

@interface iBeaconVC ()

@property (nonatomic , strong) iBeaconCC * MyibeaconCC;

@end

@implementation iBeaconVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.title = @"iBeacon测试";
}


- (void)configuration{
    
    [self.MyibeaconCC setVCGenerator:^UIViewController *(id params) {
        UIViewController * vc;
        return vc;
    }];
}

- (void)addUI{
    
    _MyibeaconCC.backView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_MyibeaconCC.backView];

}

- (void)addConstraint{
    
    [_MyibeaconCC.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.left.right.equalTo(self.view);
    }];
    
}

- (void)fetchData{
    
    [_MyibeaconCC fetchData];
}

#pragma mark -- 懒加载
- (iBeaconCC *)MyibeaconCC{
    if (!_MyibeaconCC) {
        iBeaconCC * cc = [iBeaconCC instanceCC];
        _MyibeaconCC = cc;
    }
    return _MyibeaconCC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

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
