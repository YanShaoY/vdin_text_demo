//
//  GAWorkVC.m
//  Demo
//
//  Created by YanSY on 2018/6/19.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GAWorkVC.h"
#import "WeiSuWorkCC.h"

@interface GAWorkVC ()

@property (nonatomic , strong) WeiSuWorkCC * workCC;

@end

@implementation GAWorkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setNavThemeStyle];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    self.title = @"管理";
    
    [self configuration];
    [self addUI];
    [self addConstraint];
    [self fetchData];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self.workCC fetchData];
}

#pragma mark -- 配置
- (void)configuration{
    
    [self.workCC setVCGenerator:^UIViewController *(id params) {
//        GABaseVC * vc;
//        if ([params isKindOfClass:[UIButton class]]) {
//            vc = [[SZQYInfoRegistVC alloc]init];
//        }
//        return vc;
        return nil;
    }];
}

#pragma mark -- 添加 UI
- (void)addUI{
    [self.view addSubview:self.workCC.workCCbackView];
}

#pragma mark -- 添加约束
- (void)addConstraint{
    
    [self.workCC.workCCbackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
}

#pragma mark -- 获取数据
- (void)fetchData{
    [self.workCC fetchData];
}

#pragma mark -- 懒加载
- (WeiSuWorkCC *)workCC{
    if (!_workCC) {
        _workCC = [WeiSuWorkCC instanceWorkCC];
    }
    return _workCC;
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
