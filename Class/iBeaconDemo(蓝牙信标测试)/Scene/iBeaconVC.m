//
//  iBeaconVC.m
//  Demo
//
//  Created by YanSY on 2017/12/14.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "iBeaconVC.h"
#import "iBeaconCC.h"

// 导入通讯框架
#import <WatchConnectivity/WatchConnectivity.h>
// 开门网络请求
#import "ibeaconNetWorkManager.h"

@interface iBeaconVC ()<WCSessionDelegate>

/// 请求会话
@property (strong , nonatomic) WCSession * requestSession;
@property (nonatomic , strong) iBeaconCC * MyibeaconCC;

@end

@implementation iBeaconVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.title = @"iBeacon测试";
    //激活会话
    if([WCSession isSupported]){
        [self.requestSession activateSession];
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
/// 会话完成激活后调用
//当会话完成活动时调用该方法，如果会话是断开的状态，error将展示更细致的信息。
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
        
        
        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        if (state != UIApplicationStateActive && error) {
            
            NSString * title     = @"iWatch通信会话激活状态通知";
            NSString * subTitle  = error.localizedRecoverySuggestion;
            NSString * identifer = error.localizedDescription   ? : @"default_Error";
            NSString * body      = error.localizedFailureReason ? : stateMsg;
            NSDictionary * info  = error.userInfo;
            [[GALocalNoticeService sharedInstance]sendNoticeWithId:identifer Title:title soundNamed:@"支付宝_100万.m4r" subTitle:subTitle Body:body Info:info];

        }else{
            [MBProgressHUD hudWithText:stateMsg toView:nil];
        }
        
    });
    
    if (error) {
        NSLog(@"%s----error:%@",__func__,error);
    }
    
}

/// 手表切换或者断开连接是调用
/**当会话不再用于修改或者增加新的传输文件，所有的交互信息将被取消，该方法被调用，但是代理回调还是可以在后台传输文件。当手表会话状态被改变 */
- (void)sessionDidBecomeInactive:(WCSession *)session{
    NSLog(@"%s---iWatch发生了改变，检查是否断开连接%@",__func__,session);
}

/// 完成所有委托后调用
/** 当手表的会话已经没有活动时，会回调此方法，当手表应用使用activateSession可以让会话再次活动。*/
- (void)sessionDidDeactivate:(WCSession *)session{
    NSLog(@"%s---与iWatch之间的通信全部调用完成，可使用activateSession方法重启,%@",__func__,session);
}

/// 手表状态发生改变时调用
//当手表的会话状态进行改变，会走此方法
- (void)sessionWatchStateDidChange:(WCSession *)session{
    NSLog(@"%s---iWatch状态发生了改变:%@",__func__,session);
}

/// 对应app可达状态改变时调用
/**当手机和手表应用的连接状态改变时，将调用此方法，接受方应该检查连接属性去检查代理回调*/
- (void)sessionReachabilityDidChange:(WCSession *)session{
    NSLog(@"%s---能否发送消息的可达状态改变时调用%@",__func__,session);
}

/// 调用接收者的委托。如果传入消息导致接收方启动，将在启动时调用
/**在接收信息端调用此方法，如果收到信息时，马上调用此方法*/
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message{
    
    NSLog(@"%s---手机收到iWatch发送过来的消息: %@",__func__, message);
    [self dealWithiWatchRequestFor:message];
}

//收到消息代理方法
//当接收到信息时，并在回调中回复发送方信息，如果收到信息时，马上调用此方法
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler{

    NSLog(@"%s---手机收到iWatch发送过来的消息: %@",__func__, message);
    
    NSMutableDictionary * messageDict = [[NSMutableDictionary alloc] init];
    [messageDict setValue:@"OK" forKey:@"result"];
    [messageDict setValue:@"手机正在响应请求~" forKey:@"message"];
    replyHandler(messageDict);
    
    [self dealWithiWatchRequestFor:message];
}

#pragma mark -- iWatch请求处理
- (void)dealWithiWatchRequestFor:(NSDictionary * )message{
    
    NSString * showMsgStr;
    if (message[@"request"]) {
        showMsgStr = message[@"request"];
    }else{
        showMsgStr = @"不知道手表发过来的是什么~";
    }

    dispatch_async(dispatch_get_main_queue(), ^{

        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        if (state != UIApplicationStateActive) {
            NSString * title     = @"iWatch通信会话通知";
            NSString * identifer = nil;
            NSString * body      = showMsgStr;
            NSDictionary * info  = message;
            [[GALocalNoticeService sharedInstance]sendNoticeWithId:identifer Title:title soundNamed:@"支付宝_1万.m4r" subTitle:nil Body:body Info:info];
            
        }else{
            
            [MBProgressHUD hideHUD];
            [MBProgressHUD hudWithText:showMsgStr toView:nil];
            
        }
        
        if ([showMsgStr isEqualToString:@"OpenTheDoor"]) {
            UIApplicationState state = [UIApplication sharedApplication].applicationState;
            if (state == UIApplicationStateActive) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showMessage:@"iWatch请求开门" toView:nil];
            }
            [self requestOpenTheDoor];
        }
        
    });
        
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

#pragma mark -- 请求开门
- (void)requestOpenTheDoor{
    
    @weakify(self);
    [ibeaconNetWorkManager autoOpenTheDoorRequestComplete:^(id responseObject, BOOL isSuccess) {
        @strongify(self);

        NSMutableDictionary * messageDict = [[NSMutableDictionary alloc] init];
        if (isSuccess) {
            [messageDict setValue:@"OK" forKey:@"result"];
            [messageDict setValue:@"开门成功~请进~" forKey:@"message"];
        }else{
            [messageDict setValue:@"NO" forKey:@"result"];
            [messageDict setValue:@"开门失败，请重试~" forKey:@"message"];
        }
        
        NSString * title     = @"iWatch通信会话通知";
        NSString * identifer = nil;
        NSString * body      = messageDict[@"message"];
        NSDictionary * info  = messageDict;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIApplicationState state = [UIApplication sharedApplication].applicationState;
            if (state != UIApplicationStateActive) {
                [[GALocalNoticeService sharedInstance]sendNoticeWithId:identifer Title:title soundNamed:@"支付宝_10万.m4r" subTitle:nil Body:body Info:info];
            }else{
                [MBProgressHUD hudWithText:messageDict[@"message"] toView:nil];
            }
        });
        
        
        if (self.requestSession.paired && self.requestSession.watchAppInstalled && self.requestSession.reachable) {
            
            [self.requestSession sendMessage:messageDict replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                NSLog(@"手机发送信息后，iWatch端回复: %@", replyMessage);
                
            } errorHandler:^(NSError * _Nonnull error) {
                NSLog(@"手机发送信息发生错误，错误信息: %@", error);
            }];
            
        }
        
        ///
        
        
    }];
    
}

#pragma mark -- TODO
- (NSDictionary *)getCitysMessage {
    //获取系统当前的时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    //发送的消息与上次一样则不会发送，因此加上时间戳
    NSDictionary *dict = @{@"watchSessionSycnCitys":[NSString stringWithFormat:@"%@%@", @"watchSessionSycnCitys", timeString]};
    return dict;
}

#pragma mark -- 懒加载
- (iBeaconCC *)MyibeaconCC{
    if (!_MyibeaconCC) {
        iBeaconCC * cc = [iBeaconCC instanceCC];
        _MyibeaconCC = cc;
    }
    return _MyibeaconCC;
}

- (WCSession *)requestSession{
    if (!_requestSession) {
        _requestSession = [WCSession defaultSession];
        _requestSession.delegate = self;
    }
    return _requestSession;
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
