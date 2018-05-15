//
//  mainVC.m
//  BmoobTestDemo
//
//  Created by YanSY on 2017/10/20.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "mainVC.h"
#import "SideMenuControl.h"

#import "iBeaconVC.h"
#import "XunFeiMscVC.h"

@interface mainVC ()<SideMenuControlDelegate>

@property (nonatomic , strong) SideMenuControl * sideMenuListView;
@property (nonatomic , strong) NSMutableArray<UIViewController *> * dataSourceArr;

@end

@implementation mainVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.title = self.dataSourceArr[1].title;
    [self.sideMenuListView scrollTabWithType:SideMenu_Tab_Type_Root toRowNumber:1];
}

#pragma mark -- 所有子类都应该实现的方法
- (void)configuration{
    // 001
    iBeaconVC * beaconVC = [[iBeaconVC alloc]init];
    [self addChildViewController:beaconVC];
    [self.dataSourceArr addObject:beaconVC];
    
    // 002
    XunFeiMscVC * mscVC = [[XunFeiMscVC alloc]init];
    [self addChildViewController:mscVC];
    [self.dataSourceArr addObject:mscVC];
    
    CGFloat height = 44+20;
    if (@available(iOS 11.0, *)) {
        height += self.view.safeAreaInsets.bottom;
    }
    self.sideMenuListView = [[SideMenuControl alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-height) withSource:self.navigationController percentageToMenu:0.75];
    self.sideMenuListView.userInteractionEnabled = YES;
    self.sideMenuListView.delegate = self;
    self.sideMenuListView.backgroundColor = self.view.backgroundColor;
}

- (void)addUI{
    [self.view addSubview:self.sideMenuListView];
}

#pragma mark - SideMenuViewController delegate
- (NSInteger)numberOfListForTab:(SideMenu_Tab_Type)tableType{
    return self.dataSourceArr.count;
}

- (UIView *)viewForTabType:(SideMenu_Tab_Type)tableType andTabRow:(NSUInteger)row{
    
    UIView * returnView = [[UIView alloc]init];
    switch (tableType) {
        case SideMenu_Tab_Type_Root:
            returnView = self.dataSourceArr[row].view;
            break;
            
        case SideMenu_Tab_Type_menu:{
            UILabel * titleLabel = [[UILabel alloc]init];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = [NSString stringWithFormat:@"    %@",self.dataSourceArr[row].title];
            titleLabel.textColor = [UIColor blackColor];
            returnView = titleLabel;
        }
            
            break;
            
        default:
            break;
    }
    
    return returnView;
}

- (void)didSelectAtRowNumber:(NSUInteger)row forTabType:(SideMenu_Tab_Type)tableType{
    self.title = self.dataSourceArr[row].title;
}

- (void)didScrollAtRowNumber:(NSUInteger)row forTabType:(SideMenu_Tab_Type)tableType{
    self.title = self.dataSourceArr[row].title;
}


#pragma mark -- 懒加载
- (NSMutableArray<UIViewController *> *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [[NSMutableArray alloc]init];
    }
    return _dataSourceArr;
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
