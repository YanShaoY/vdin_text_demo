//
//  ibeaconPopMenuView.h
//  Demo
//
//  Created by YanSY on 2017/12/20.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "BaseView.h"

typedef void(^menuBtClickedBlock)(NSUInteger index);

@interface ibeaconPopMenuView : BaseView

+ (void)showIBeaconPopMenuViewWithType:(NSUInteger)index WithBlock:(menuBtClickedBlock)block;

@end
