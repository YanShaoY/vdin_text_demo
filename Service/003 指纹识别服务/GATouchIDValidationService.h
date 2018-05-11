//
//  GATouchIDValidationService.h
//  GAProduct
//
//  Created by YanSY on 2017/8/16.
//  Copyright © 2017年 ZDHT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>

typedef void(^GATouchIDBlock)(BOOL success,LAError code);

@interface GATouchIDValidationService : NSObject

+ (void)showTouchIDWithBlock:(GATouchIDBlock)block;

@end
