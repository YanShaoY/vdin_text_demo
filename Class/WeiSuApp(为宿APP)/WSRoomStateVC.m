//
//  WSRoomStateVC.m
//  Demo
//
//  Created by YanSY on 2018/6/21.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "WSRoomStateVC.h"

@interface WSRoomStateVC ()

@end

@implementation WSRoomStateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    self.title = @"房态";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    for (int i = 0; i < 5; i++) {
        
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, i * (100 +20), SCREENWIDTH, 100)];
        int R = (arc4random() % 256) ;
        int G = (arc4random() % 256) ;
        int B = (arc4random() % 256) ;
        
        view.backgroundColor = [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
        [self.view addSubview:view];
    }

    

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
