//
//  InterfaceController.m
//  VdinMengjin Extension
//
//  Created by YanSY on 2018/6/22.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "InterfaceController.h"
// 导入通讯框架
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController ()<WCSessionDelegate>

/// 消息会话
@property (strong , nonatomic) WCSession * mySession;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *openDoorBt;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    [super willActivate];
    
    //激活会话
    if ([WCSession isSupported]) {
        [self.mySession activateSession];
    }

}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)openDoorBtAction{
    
    NSDictionary * mesageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"OpenTheDoor",@"result", nil];
    WCSession *session = [WCSession defaultSession];
    [session sendMessage:@{@"watch":@"i come from watch"} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        NSLog(@"replay: %@", replyMessage);
        
    } errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];
    
}

#pragma mark -- WCSessionDelegate
//收到消息代理方法
-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString     *,id> *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //向iPhone发送回复消息，代码块参数不能为nil
        [session sendMessage:@{@"result":@"OK!"}    replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
            
        } errorHandler:^(NSError * _Nonnull error) {
            
        }];
    });
}


- (void)session:(nonnull WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    
}


#pragma mark -- 懒加载
- (WCSession *)mySession{
    if (!_mySession) {
        _mySession = [WCSession defaultSession];
        _mySession.delegate = self;
    }
    return _mySession;
}

@end














