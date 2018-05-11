//
//  ibeaconNetWorkManager.m
//  Demo
//
//  Created by YanSY on 2017/12/26.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "ibeaconNetWorkManager.h"

@implementation ibeaconNetWorkManager

#pragma mark -- 公有方法
/// 自动开门
+ (void)autoOpenTheDoorRequestComplete:(COMPLETEBLOCK)block{
    
    NSDictionary *dicInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *strAppName = [dicInfo objectForKey:@"CFBundleDisplayName"];
    if ([strAppName isEqualToString:@"VdinDemo"]) {
        block(strAppName, NO);
        return;
    }
    __block NSMutableDictionary * parameter = [[NSMutableDictionary alloc]init];
    __block NSString * requestURL = @"http://zdht-cd.imwork.net:8000/accctrl";

    // 001
    [parameter setValue:@"18628977220" forKey:@"phone"];
    [parameter setValue:@"1001" forKey:@"cmd"];
    @weakify(self);
    [self postWithUrl:requestURL params:parameter complete:^(id responseObject, BOOL isSuccess) {
        @strongify(self);
        if (isSuccess) {
            NSDictionary *resDict = (NSDictionary *)responseObject;
            NSNumber * resultcode = resDict[@"resultcode"];
            NSNumber * cmd = resDict[@"cmd"];
            if (resultcode && cmd && resultcode.integerValue == 0 && cmd.integerValue == 1001) {
                [parameter setValue:@"18628977220" forKey:@"phone"];
                [parameter setValue:@"1002" forKey:@"cmd"];
                [parameter setValue:@"1" forKey:@"type"];
                [parameter setValue:resDict[@"stamp"] forKey:@"stamp"];
                [parameter setObject:@"0" forKey:@"distanceType"];
                [parameter setValue:@"88888888" forKey:@"UUID"];
                [parameter setValue:@"88888888" forKey:@"major"];
                [parameter setValue:@"88888888" forKey:@"minor"];
                [self postWithUrl:requestURL params:parameter complete:^(id responseObject, BOOL isSuccess) {
                    if (!block) {
                        return ;
                    }else{
                        block(responseObject, isSuccess);
                    }
                } loading:nil successText:nil failText:nil];
            }
            
        }else{
            if (!block) {
                return ;
            }else{
                block(responseObject, NO);
            }
        }
    } loading:nil successText:nil failText:nil];
}

#pragma mark -- 数据请求接口
+ (void)getWithUrl:(NSString *)url params:(id)params complete:(COMPLETEBLOCK)block loading:(NSString *)loading successText:(NSString *)successText failText:(NSString *)failText {
    
    if (loading.length > 0)
        [MBProgressHUD showMessage:loading toView:nil];
    
    [GANetworkService get:url params:params success:^(id responseObject) {
        [MBProgressHUD hideHUD];
        if (successText.length > 0)
            [MBProgressHUD hudWithText:successText toView:nil];
        
        block(responseObject, YES);
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        
        if (failText.length > 0) {
            NSString *text = [self analysisError:error defaultMessage:failText];
            [MBProgressHUD hudWithText:text toView:nil];
        }
        
        block(error, NO);
    } timeoutInterval:0];
}

+ (void)postWithUrl:(NSString *)url params:(id)params complete:(COMPLETEBLOCK)block loading:(NSString *)loading successText:(NSString *)successText failText:(NSString *)failText {
    
    if (loading.length > 0)
        [MBProgressHUD showMessage:loading toView:nil];
    
    [GANetworkService post:url params:params success:^(id responseObject) {
        [MBProgressHUD hideHUD];
        if (successText.length > 0)
            [MBProgressHUD hudWithText:successText toView:nil];
        
        block(responseObject, YES);
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        
        if (failText.length > 0) {
            NSString *text = [self analysisError:error defaultMessage:failText];
            [MBProgressHUD hudWithText:text toView:nil];
        }
        
        block(error, NO);
    } timeoutInterval:0];
}

/**
 解析 Error
 
 @param error   error
 @param message 解析不出, 默认返回的字符串.
 
 @return 解析出的错误信息
 */
+ (NSString *)analysisError:(NSError *)error defaultMessage:(NSString *)message
{
    id responseBody = error.userInfo[JSONResponseSerializerWithDataKey];
    NSString *msg;
    if (responseBody){
        if ([responseBody isKindOfClass:[NSDictionary class]]) {
            msg = responseBody[@"message"];
        } else if ([responseBody isKindOfClass:[NSString class]]) {
            msg = responseBody;
        } else {
            msg = [message mutableCopy];
        }
    } else {
        msg = [message mutableCopy];
    }
    
    return msg;
}


@end






