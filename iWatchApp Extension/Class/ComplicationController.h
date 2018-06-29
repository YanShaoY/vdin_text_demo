//
//  ComplicationController.h
//  iWatchApp Extension
//
//  Created by YanSY on 2018/6/25.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <ClockKit/ClockKit.h>

@interface ComplicationController : NSObject <CLKComplicationDataSource>

#pragma mark -- 刷新表盘的显示组件数据
/**
 刷新表盘组件数据
 */
- (void)updateComplication;

@end
