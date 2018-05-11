//
//  XunFeiMscVC.m
//  Demo
//
//  Created by YanSY on 2018/5/11.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XunFeiMscVC.h"
#import "XunFeiMscCC.h"

@interface XunFeiMscVC ()

@property (nonatomic, strong) XunFeiMscCC * xfMscCC;

@end

@implementation XunFeiMscVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.title = @"讯飞语音测试";
}

- (void)configuration{
    [self.xfMscCC setVCGenerator:^UIViewController *(id params) {
        UIViewController * vc;
        return vc;
    }];
}

- (void)addUI{
    self.xfMscCC.backView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.xfMscCC.backView];
}

- (void)addConstraint{
    
    [self.xfMscCC.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.left.right.equalTo(self.view);
    }];
    
}

- (void)fetchData{
    
    [self.xfMscCC fetchData];
    
}

#pragma mark -- 懒加载
- (XunFeiMscCC *)xfMscCC{
    if (!_xfMscCC) {
        XunFeiMscCC * cc = [XunFeiMscCC instanceCC];
        _xfMscCC = cc;
    }
    return _xfMscCC;
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
