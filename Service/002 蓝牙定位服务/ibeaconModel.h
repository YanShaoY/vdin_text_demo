//
//  ibeaconModel.h
//  Demo
//
//  Created by YanSY on 2017/12/28.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -- 定义返回ibeacon模型

@interface ibeaconModel : NSObject

/// UUID
@property (nonatomic , strong) NSUUID   * _Nonnull proximityUUID;
/// 获取主频
@property (nonatomic , strong) NSNumber * _Nonnull major;
/// 获取副频
@property (nonatomic , strong) NSNumber * _Nonnull minor;
/// 获取感知
@property (nonatomic , strong) NSString * _Nonnull proximity;
/// 获取距离
@property (nonatomic , strong) NSNumber * _Nonnull accuracy;
/// 获取信号强度
@property (nonatomic , strong) NSNumber * _Nonnull rssi;

@end
