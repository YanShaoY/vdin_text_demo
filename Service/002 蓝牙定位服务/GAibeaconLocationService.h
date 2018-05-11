//
//  GAIbeaconLocationService.h
//  Demo
//
//  Created by YanSY on 2018/1/9.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAibeaconModel.h"

typedef NS_ENUM(NSUInteger , iBeacon_Scan_Type) {
    /// 默认扫描状态，扫描参数标定区域详细及概要信息，可能打印未知log（不推荐）
    Scan_Type_Default           = 0,
    /// 详细参数扫描，扫描参数标定区域所有ibeacon详细信息（推荐）
    Scan_Type_Ranging           = 1,
    /// 概要参数扫描，扫描参数标定区域ibeacon进入或退出状态（后台可用）
    Scan_Type_Monitoring        = 2,
};

typedef NS_ENUM(NSUInteger , Scan_Error_Code) {
    /// ibeacon扫描参数错误
    Error_Code_Parameter        = -10001,
    /// GPS权限或者定位错误
    Error_Code_GPS              = -10002,
    /// ibeacon扫描发生错误
    Error_Code_Beacon           = -10003,
    /// 其他类型错误
    Error_Code_Other            = -10004,
};

@protocol GAibeaconLocationServiceDelegate;

/**
 ibeacon扫描服务
 */
@interface GAibeaconLocationService : NSObject

#pragma mark -- 参数定义
/// 扫描服务代理
@property (nonatomic ,weak ,nullable) id <GAibeaconLocationServiceDelegate> delegate;

#pragma mark -- 公共方法
/**
 初始化扫描服务

 @return 返回服务对象
 */
+ (GAibeaconLocationService * _Nonnull )sharedInstance;

/**
 设置标定区域扫描参数

 @param beaconUUID  扫描ibeacon的标识 （必传）
 @param beaconMajor 扫描ibeacon的主频 （可为空）
 @param beaconMinor 扫描ibeacon的副频 （可为空，当主频为空，副频无作用）
 */
- (void)setServiceWithUUID:(NSString *_Nonnull )beaconUUID
                  andMajor:(NSString *_Nullable)beaconMajor
                  andMinor:(NSString *_Nullable)beaconMinor;

/**
 开始扫描标定区域内的ibeacon

 @param scanType 扫描的类型
 */
- (void)startServiceToScanBeaconWithType:(iBeacon_Scan_Type)scanType;

/**
 停止扫描标定区域内的ibeacon
 */
- (void)stopServiceToScanBeacon;

@end

/**
 ibeacon扫描服务代理
 */
@protocol GAibeaconLocationServiceDelegate <NSObject>

@optional
/**
 扫描参数标定区域详细参数回调
 
 @param service 扫描服务
 @param beacons 包含参数标定区域内ibeacon详细信息的数组
 @param region  参数标定区域
*/
- (void)ibeaconLocationService:(GAibeaconLocationService *_Nonnull)service
         didScanToRangeBeacons:(NSArray<GAibeaconModel *> *_Nullable)beacons
                      inRegion:(NSDictionary * _Nullable)region;

/**
 开始扫描标定区域概要回调

 @param service 扫描服务
 @param region 参数标定区域
 */
- (void)ibeaconLocationService:(GAibeaconLocationService *_Nonnull)service
   didStartMonitoringForRegion:(NSDictionary *_Nullable)region;

/**
 进入参数标定区域回调
 
 @param service 扫描服务
 @param region 参数标定区域
 */
- (void)ibeaconLocationService:(GAibeaconLocationService *_Nonnull)service
                didEnterRegion:(NSDictionary *_Nullable)region;

/**
 离开参数标定区域回调
 
 @param service 扫描服务
 @param region 参数标定区域
 */
- (void)ibeaconLocationService:(GAibeaconLocationService *_Nonnull)service
                 didExitRegion:(NSDictionary *_Nullable)region;

/**
 扫描参数标定区域状态变化回调

 @param service 扫描服务
 @param state 距离区域状态 0：未知； 1：进入，在区域内； 2：离开，在区域外
 @param region 参数标定区域
 */
- (void)ibeaconLocationService:(GAibeaconLocationService *_Nonnull)service
             didDetermineState:(NSInteger)state
                     forRegion:(NSDictionary *_Nullable)region;

/**
 扫描参数标定区域发生错误回调
 
 @param service 扫描服务
 @param error 错误信息
 */
- (void)ibeaconLocationService:(GAibeaconLocationService *_Nonnull)service
             scanToBeaconError:(NSError *_Nullable)error;

@end








