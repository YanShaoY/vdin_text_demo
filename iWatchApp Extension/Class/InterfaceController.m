//
//  InterfaceController.m
//  iWatchApp Extension
//
//  Created by YanSY on 2018/6/25.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController ()

/// 分页控制器数组
@property (nonatomic, strong) NSMutableArray  * pageVCArr;
/// 分页控制器context数组
@property (nonatomic, strong) NSMutableArray  * vcContextArr;

@end

@implementation InterfaceController

#pragma mark -- 界面初始化
- (void)awakeWithContext:(id)context{
    [super awakeWithContext:context];
    [self setTitle:@"首页"];
    NSArray * titleArr = [[NSArray alloc]initWithObjects:@"公司门禁",@"讯飞语音",nil];
    NSArray * vcIdArr = [[NSArray alloc]initWithObjects:@"EntranceGuardVC",@"XunFeiMscTextVC",nil];
    
    [self.pageVCArr removeAllObjects];
    [self.vcContextArr removeAllObjects];
    
    for (int i = 0; i < titleArr.count; i++) {
        
        [self.pageVCArr addObject:vcIdArr[i]];

        NSMutableDictionary * contextDict = [[NSMutableDictionary alloc]init];
        [contextDict setValue:titleArr[i] forKey:@"title"];
        [contextDict setValue:[NSString stringWithFormat:@"%d",i] forKey:@"count"];
        [self.vcContextArr addObject:contextDict];
    }
}

#pragma mark -- 界面即将展示
- (void)willActivate {
    [super willActivate];
    if (self.pageVCArr.count >0 && self.vcContextArr.count >0) {
        [WKInterfaceController reloadRootPageControllersWithNames:self.pageVCArr contexts:self.vcContextArr orientation:WKPageOrientationHorizontal pageIndex:0];
    }
}

#pragma mark -- 界面已经消失
- (void)didDeactivate {
    [super didDeactivate];
}

#pragma mark -- 懒加载
- (NSMutableArray<WKInterfaceController *> *)pageVCArr{
    if (!_pageVCArr) {
        _pageVCArr = [[NSMutableArray alloc]init];
    }
    return _pageVCArr;
}

- (NSMutableArray *)vcContextArr{
    if (!_vcContextArr) {
        _vcContextArr = [[NSMutableArray alloc]init];
    }
    return _vcContextArr;
}



@end











