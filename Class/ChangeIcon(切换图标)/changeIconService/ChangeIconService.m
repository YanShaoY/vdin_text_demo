//
//  ChangeIconService.m
//  Demo
//
//  Created by YanSY on 2017/11/22.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "ChangeIconService.h"
#import <objc/runtime.h>

@implementation ChangeIconService

+(void)automaticChangeIcon{
    
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(changeIcon) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode: UITrackingRunLoopMode];
}


+(void)changeIcon{
    if (@available(iOS 10.3,*)){
        
        if ([UIApplication sharedApplication].supportsAlternateIcons) {
            //        NSLog(@"you can change this app's icon");
        }else{
            //        NSLog(@"you can not change this app's icon");
            return;
        }
        
        NSUInteger timer = [[NSDate date] timeIntervalSince1970];
        
        NSString *iconName = [[UIApplication sharedApplication] alternateIconName];
        switch (timer%3) {
            case 0:
                iconName = @"newIcon01";
                break;
                
            case 1:
                iconName = @"newIcon02";
                break;
                
            case 2:
                iconName = @"newIcon03";
                break;
                
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // change to alterante icon
            [[UIApplication sharedApplication] setAlternateIconName:iconName completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"set icon error: %@",error);
                }
                NSLog(@"The alternate icon's name is %@",iconName);
            }];
            
        });

    }
    
}

@end







