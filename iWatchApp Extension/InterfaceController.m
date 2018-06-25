//
//  InterfaceController.m
//  iWatchApp Extension
//
//  Created by YanSY on 2018/6/25.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "InterfaceController.h"
// 导入通讯框架
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController ()<WCSessionDelegate>

/// 请求会话
@property (strong , nonatomic) WCSession * requestSession;
/// 消息提示标签
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *showMessageLabel;
/// 开门按钮
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *openDoorBt;

@end


@implementation InterfaceController

#pragma mark -- 界面初始化
- (void)awakeWithContext:(id)context{
    
    [super awakeWithContext:context];
    [self setTitle:@"公司门禁"];
    [self.showMessageLabel setHidden:YES];
    
}

#pragma mark -- 界面即将展示
- (void)willActivate {
    [super willActivate];
    //激活会话
    if([WCSession isSupported]){
        [self.requestSession activateSession];
    }
    
}

#pragma mark -- 界面已经消失
- (void)didDeactivate {
    [super didDeactivate];
    [self.showMessageLabel setHidden:YES];
}


- (IBAction)openDoorBtAction{
    
    [self.showMessageLabel setHidden:NO];
    
    if (self.requestSession.activationState != WCSessionActivationStateActivated) {
        [self.showMessageLabel setText:@"请求会话未激活···"];
        [self.requestSession activateSession];
        //        [self openDoorBtAction];
        return;
    }
    
    if (!self.requestSession.reachable) {
        
        [self.showMessageLabel setText:@"无法连接到手机···"];
        //        [self.requestSession activateSession];
        //        [self openDoorBtAction];
        return;
    }
    
    [self.showMessageLabel setText:@"发送开门请求···"];
    
    NSDictionary * mesageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"OpenTheDoor",@"request", nil];
    [self.requestSession sendMessage:mesageDict replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        
        NSString * showMsgStr;
        if (replyMessage[@"result"] && [replyMessage [@"result"] isEqualToString:@"OK"]) {
            showMsgStr = replyMessage[@"message"];
        }else{
            showMsgStr = @"开门请求被拒绝,请重试~";
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.showMessageLabel setText:showMsgStr];
        });
        NSLog(@"iWatch发送请求后，手机端回复: %@", replyMessage);
        
    } errorHandler:^(NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.showMessageLabel setText:error.localizedFailureReason];
        });
        NSLog(@"iWatch请求发生错误，错误信息: %@", error);
        
    }];
    
}

#pragma mark -- WCSessionDelegate
/// 会话完成激活后调用
// 当会话完成活动时调用该方法，如果会话是断开的状态，error将展示更细致的信息。
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error{
    
    NSString * stateMsg;
    switch (activationState) {
        case WCSessionActivationStateNotActivated:
            stateMsg = @"未激活通信会话";
            break;
            
        case WCSessionActivationStateInactive:
            stateMsg = @"通信会话处于非活跃状态";
            break;
            
        case WCSessionActivationStateActivated:
            stateMsg = @"通信会话激活成功";
            break;
            
        default:
            stateMsg = @"通信会话激活状态未知";
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.showMessageLabel setHidden:NO];
        [self.showMessageLabel setText:stateMsg];
        
    });
    
    if (error) {
        NSLog(@"%s----error:%@",__func__,error);
    }
    
}

/// 对应app可达状态改变时调用
- (void)sessionReachabilityDidChange:(WCSession *)session{
    NSLog(@"%s---能否发送消息的可达状态改变是调用",__func__);
}

/// 调用接收者的委托。如果传入消息导致接收方启动，将在启动时调用
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message{
    
    NSString * showMsgStr;
    if (message[@"message"]) {
        showMsgStr = message[@"message"];
    }else{
        showMsgStr = @"不知道手机发过来的是什么~";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.showMessageLabel setHidden:NO];
        [self.showMessageLabel setText:showMsgStr];
    });
    
    NSLog(@"%s---iWatch收到手机发送过来的消息: %@",__func__, message);
}

//收到消息代理方法
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler{
    
    NSString * showMsgStr;
    if (message[@"message"]) {
        showMsgStr = message[@"message"];
    }else{
        showMsgStr = @"不知道手机发过来的是什么~";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.showMessageLabel setHidden:NO];
        [self.showMessageLabel setText:showMsgStr];
    });
    
    NSLog(@"%s---iWatch收到手机发送过来的消息: %@",__func__, message);
    replyHandler(message);
    
}

/** 当接收到NSData时，就会调用 方法*/
- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData{
    NSLog(@"WCSession代理调用了这个方法==%s",__func__);
}

/* 当接收到NSData并回复发送者信息时，会调用此方法. */
- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData replyHandler:(void(^)(NSData *replyMessageData))replyHandler{
    NSLog(@"WCSession代理调用了这个方法==%s",__func__);
}

/** -------------------------- 后台传送数据------------------------- */

/** 当授受到ApplicationContext时，代理会被调用 */
- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext{
    NSLog(@"WCSession代理调用了这个方法==%s",__func__);
}

/**
 当授受到对应传递过来的用户信息成功或者失败会调用此方法，
 如果当用户信息已经完成而发送用户信息端没有运行，在发送用户信息端下次登陆时，该方法会被再次调用 。
 */
- (void)session:(WCSession * __nonnull)session didFinishUserInfoTransfer:(WCSessionUserInfoTransfer *)userInfoTransfer error:(nullable NSError *)error{
    NSLog(@"WCSession代理调用了这个方法==%s",__func__);
}

//接受端调用此方法，当收到对应应用的用户信息，如果接收方没有运行，系统将重新启动该应用
- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *, id> *)userInfo{
    NSLog(@"WCSession代理调用了这个方法==%s",__func__);
}

//当文件发送完成时，发送端会调用此方法，当文件已经发送完成但是发送端没有运行，该方法将在下次登陆时被调用
- (void)session:(WCSession *)session didFinishFileTransfer:(WCSessionFileTransfer *)fileTransfer error:(nullable NSError *)error{
    NSLog(@"WCSession代理调用了这个方法==%s",__func__);
}

/** 接收数据端，调用此代理方法，如果接收端没有运行，如果收到数据时会被启动，当文件被传送时，文件将被放在Documents/Inbox/ folder中，接收才一定要将文件移到其他的位置，当该方法完成时，系统将会移除所有内容
 */
- (void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file{
    NSLog(@"WCSession代理调用了这个方法==%s",__func__);
}

#pragma mark -- 懒加载
- (WCSession *)requestSession{
    if (!_requestSession) {
        _requestSession = [WCSession defaultSession];
        _requestSession.delegate = self;
    }
    return _requestSession;
}

@end



