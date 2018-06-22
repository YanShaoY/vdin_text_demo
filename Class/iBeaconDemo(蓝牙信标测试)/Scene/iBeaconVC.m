//
//  iBeaconVC.m
//  Demo
//
//  Created by YanSY on 2017/12/14.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "iBeaconVC.h"
#import "iBeaconCC.h"

//------第一步：通讯框架------
#import <WatchConnectivity/WatchConnectivity.h>
#import "ibeaconNetWorkManager.h"

@interface iBeaconVC ()<WCSessionDelegate>

/// 消息会话
@property (strong , nonatomic) WCSession * mySession;

@property (nonatomic , strong) iBeaconCC * MyibeaconCC;

@end

@implementation iBeaconVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.title = @"iBeacon测试";
    //激活会话
    if([WCSession isSupported]){
        [self.mySession activateSession];
    }
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

#pragma mark -- WCSessionDelegate
//收到消息代理方法
-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString     *,id> *)message{
    
    NSLog(@"收到iWatch数据");
    [MBProgressHUD showMessage:@"收到消息" toView:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        @weakify(self);
        [ibeaconNetWorkManager autoOpenTheDoorRequestComplete:^(id responseObject, BOOL isSuccess) {
            @strongify(self);
            
            //向iPhone发送回复消息，代码块参数不能为nil
            [self.mySession sendMessage:@{@"result":@"OK!"}    replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                
            } errorHandler:^(NSError * _Nonnull error) {
                
            }];
            
        }];
        

    });
}


- (void)session:(nonnull WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    
}

- (void)sessionDidBecomeInactive:(nonnull WCSession *)session {
    
}


- (void)sessionDidDeactivate:(nonnull WCSession *)session {
    
}


#pragma mark -- 懒加载
- (iBeaconCC *)MyibeaconCC{
    if (!_MyibeaconCC) {
        iBeaconCC * cc = [iBeaconCC instanceCC];
        _MyibeaconCC = cc;
    }
    return _MyibeaconCC;
}

- (WCSession *)mySession{
    if (!_mySession) {
        _mySession = [WCSession defaultSession];
        _mySession.delegate = self;
    }
    return _mySession;
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
