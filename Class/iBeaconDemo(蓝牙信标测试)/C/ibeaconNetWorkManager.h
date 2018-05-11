//
//  ibeaconNetWorkManager.h
//  Demo
//
//  Created by YanSY on 2017/12/26.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 网络请求回调
 
 @param responseObject  返回值
 @param isSuccess 成功 or 失败
 */
typedef void (^COMPLETEBLOCK)(id responseObject, BOOL isSuccess);

@interface ibeaconNetWorkManager : NSObject

/**
 自动开门请求

 @param block 请求回调
 */
+ (void)autoOpenTheDoorRequestComplete:(COMPLETEBLOCK)block;


@end
