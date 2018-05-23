//
//  GAIbeaconLocationService.m
//  Demo
//
//  Created by YanSY on 2018/1/9.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GAibeaconLocationService.h"
#import <CoreLocation/CoreLocation.h>

#define DeaflutUUID  @"4CDBC040-657A-4847-B266-7E31D9E2C3D9"
#define DeaflutIdentifier [[NSBundle mainBundle] bundleIdentifier]

@interface GAibeaconLocationService ()<CLLocationManagerDelegate>{
    
    BOOL       isLocation;
    NSUUID   * scanUUID;
    NSString * scanMajor;
    NSString * scanMinor;

}
@property (nonatomic, strong)   CLLocationManager * locationManager;
@property (nonatomic, strong)   CLBeaconRegion    * beaconRegion;

@end

@implementation GAibeaconLocationService

#pragma mark -- 初始化
/**
 初始化扫描服务
 
 @return 返回服务对象
 */
+ (GAibeaconLocationService * _Nonnull )sharedInstance{
    GAibeaconLocationService * service = [[GAibeaconLocationService alloc]init];
    return service;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configuration];
    }
    return self;
}

- (void)configuration{
    self.locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    _locationManager.distanceFilter=kCLDistanceFilterNone;
    _locationManager.allowsBackgroundLocationUpdates = YES;
    _locationManager.pausesLocationUpdatesAutomatically=NO;
}

#pragma mark -- 公共方法
/**
 设置标定区域扫描参数
 
 @param beaconUUID  扫描ibeacon的标识 （必传）
 @param beaconMajor 扫描ibeacon的主频 （可为空）
 @param beaconMinor 扫描ibeacon的副频 （可为空，当主频为空，副频无作用）
 */
- (void)setServiceWithUUID:(NSString *_Nonnull )beaconUUID
                  andMajor:(NSString *_Nullable)beaconMajor
                  andMinor:(NSString *_Nullable)beaconMinor{
    if (!beaconUUID) {
        [self delegateToErrorWithCode:Error_Code_Parameter
                       andDescription:@"Parameter_SetUp_Error"
                     andFailureReason:@"扫描UUID不能为空"];
        return;
    }
    
    scanUUID  = [[NSUUID alloc]initWithUUIDString:beaconUUID];
    if (!scanUUID) {
        [self delegateToErrorWithCode:Error_Code_Parameter
                       andDescription:@"Parameter_SetUp_Error"
                     andFailureReason:@"UUID非法"];
        return;
    }

    if (beaconMajor.length > 0 && ![self isPureInt:beaconMajor]) {
        [self delegateToErrorWithCode:Error_Code_Parameter
                       andDescription:@"Parameter_SetUp_Error"
                     andFailureReason:@"Major非法"];
        return;
    }
    
    if (beaconMinor.length > 0 && ![self isPureInt:beaconMinor]) {
        [self delegateToErrorWithCode:Error_Code_Parameter
                       andDescription:@"Parameter_SetUp_Error"
                     andFailureReason:@"Minor非法"];
        return;
    }
    scanMajor = beaconMajor ? : nil;
    scanMinor = beaconMinor ? : nil;

    if (scanMajor.length > 0 && scanMinor.length > 0) {
        self.beaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:scanUUID
                                                                   major:scanMajor.integerValue
                                                                   minor:scanMinor.integerValue
                                                              identifier:DeaflutIdentifier];
    }else if (scanMajor.length > 0){
        self.beaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:scanUUID
                                                                   major:scanMajor.integerValue
                                                              identifier:DeaflutIdentifier];
    }else{
        self.beaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:scanUUID
                                                              identifier:DeaflutIdentifier];
    }
    
    
    _beaconRegion.notifyEntryStateOnDisplay = YES;
    _beaconRegion.notifyOnEntry = YES;
    _beaconRegion.notifyOnExit = YES;
    
}

- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

/**
 开始扫描标定区域内的ibeacon
 
 @param scanType 扫描的类型
 */
- (void)startServiceToScanBeaconWithType:(iBeacon_Scan_Type)scanType{
    
    if (!scanUUID) {
        [self delegateToErrorWithCode:Error_Code_Parameter
                       andDescription:@"Parameter_SetUp_Error"
                     andFailureReason:@"UUID非法"];
        return;
    }
    
    NSString * reasonLog;
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            reasonLog = @"用户尚未对APP的GPS定位权限进行授权";
            break;
            
        case kCLAuthorizationStatusRestricted:
            reasonLog = @"定位服务授权信息受到限制，请查看设置";
            break;
            
        case kCLAuthorizationStatusDenied:
        {
            if ([CLLocationManager locationServicesEnabled]) {
                reasonLog = @"用户在隐私设置中关闭GPS定位服务";
            }else{
                reasonLog = @"APP定位服务被用户禁止";
            }
        }
            break;
        default:
            break;
    }
    if (!isLocation && reasonLog.length > 0) {
        [self delegateToErrorWithCode:Error_Code_GPS
                       andDescription:@"GPS_Permissions_Error"
                     andFailureReason:reasonLog];
        return;
    }

    isLocation = YES;
    [_locationManager startUpdatingLocation];
    switch (scanType) {
        case Scan_Type_Ranging:
            [_locationManager startRangingBeaconsInRegion:_beaconRegion];
            break;
            
        case Scan_Type_Monitoring:
        {
            [_locationManager startMonitoringForRegion:_beaconRegion];
        }

            break;
            
        default:
        {
            [_locationManager startRangingBeaconsInRegion:_beaconRegion];
            [_locationManager startMonitoringForRegion:_beaconRegion];
        }
            break;
    }
    [_locationManager requestStateForRegion:_beaconRegion];
}

/**
 停止扫描标定区域内的ibeacon
 */
- (void)stopServiceToScanBeacon{
    if (isLocation) {
        isLocation = NO;
        [_locationManager stopUpdatingLocation];
        [_locationManager stopMonitoringForRegion:_beaconRegion];
        [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
    }
}

#pragma mark -- LocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSString * reasonLog;
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            reasonLog = @"用户尚未对APP的GPS定位权限进行授权";
            break;
            
        case kCLAuthorizationStatusRestricted:
            reasonLog = @"定位服务授权信息受到限制，请查看设置";
            break;
            
        case kCLAuthorizationStatusDenied:
        {
            if (![CLLocationManager locationServicesEnabled]) {
                reasonLog = @"用户在隐私设置中关闭GPS定位服务";
            }else{
                reasonLog = @"APP定位服务被用户禁止";
            }
        }
            break;
        default:
            break;
    }
    if (isLocation && reasonLog.length > 0) {
        [self delegateToErrorWithCode:Error_Code_GPS
                       andDescription:@"GPS_Permissions_Error"
                     andFailureReason:reasonLog];
    }

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self delegateToErrorWithCode:Error_Code_GPS
                   andDescription:@"GPS_Request_Error"
                 andFailureReason:@"定位发生错误"];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region{
    NSMutableArray * beaconArr = [[NSMutableArray alloc]init];
    for (CLBeacon * beacon in beacons) {
        GAibeaconModel * model = [self changeBeaconValue:beacon];
        [beaconArr addObject:model];
    }
    NSDictionary * regionDict = [self changeRegionValue:region];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ibeaconLocationService:didScanToRangeBeacons:inRegion:)]) {
        [self.delegate ibeaconLocationService:self didScanToRangeBeacons:beaconArr inRegion:regionDict];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
    [self delegateToErrorWithCode:Error_Code_Beacon
                   andDescription:@"Ranging_Scan_Error"
                 andFailureReason:@"扫描参数标定区域详细信息错误"];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    NSDictionary * regionDict = [self changeRegionValue:region];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ibeaconLocationService:didStartMonitoringForRegion:)]) {
        [self.delegate ibeaconLocationService:self didStartMonitoringForRegion:regionDict];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSDictionary * regionDict = [self changeRegionValue:region];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ibeaconLocationService:didEnterRegion:)]) {
        [self.delegate ibeaconLocationService:self didEnterRegion:regionDict];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    NSDictionary * regionDict = [self changeRegionValue:region];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ibeaconLocationService:didExitRegion:)]) {
        [self.delegate ibeaconLocationService:self didExitRegion:regionDict];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    NSDictionary * regionDict = [self changeRegionValue:region];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ibeaconLocationService:didDetermineState:forRegion:)]) {
        [self.delegate ibeaconLocationService:self didDetermineState:state forRegion:regionDict];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    [self delegateToErrorWithCode:Error_Code_Beacon
                   andDescription:@"Monitoring_Scan_Error"
                 andFailureReason:@"扫描参数标定区域概要信息错误"];
}
#pragma mark -- 私有方法
- (GAibeaconModel *)changeBeaconValue:(CLBeacon *)beacon{
    NSString * pro = [[NSString alloc]init];
    switch (beacon.proximity) {
        case CLProximityUnknown:
            pro = @"Unknown";
            break;
            
        case CLProximityImmediate:
            pro = @"Immediate";
            break;
            
        case CLProximityNear:
            pro = @"Near";
            break;
            
        case CLProximityFar:
            pro = @"Far";
            break;
            
        default:
            pro = @"error";
            break;
    }
    NSString * accStr    = [NSString stringWithFormat:@"%.3f",beacon.accuracy];
    GAibeaconModel * model = [[GAibeaconModel alloc]init];
    model.proximityUUID  = beacon.proximityUUID;
    model.major          = beacon.major;
    model.minor          = beacon.minor;
    model.proximity      = pro;
    model.accuracy       = [NSNumber numberWithFloat:accStr.floatValue];
    model.rssi           = [NSNumber numberWithInteger:beacon.rssi];
    return model;
}

- (NSDictionary *)changeRegionValue:(CLRegion *)region{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion * beaconRegion = (CLBeaconRegion *)region;
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:beaconRegion.proximityUUID forKey:@"proximityUUID"];
        [dict setValue:beaconRegion.major forKey:@"major"];
        [dict setValue:beaconRegion.minor forKey:@"minor"];
        return dict;
    }else{
        return nil;
    }
}

- (void)delegateToErrorWithCode:(Scan_Error_Code)errorCode
                 andDescription:(NSString *)description
               andFailureReason:(NSString *)reason{
    NSString *const ibeaconErrorDomain = [NSString stringWithFormat:@"%@ErrorDomain",NSStringFromClass(self.class)];
    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:description forKey:NSLocalizedDescriptionKey];
    [userInfo setValue:reason forKey:NSLocalizedFailureReasonErrorKey];
    NSError * error = [NSError errorWithDomain:ibeaconErrorDomain code:errorCode userInfo:userInfo];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ibeaconLocationService:scanToBeaconError:)]) {
        [self.delegate ibeaconLocationService:self scanToBeaconError:error];
    }
}

@end















