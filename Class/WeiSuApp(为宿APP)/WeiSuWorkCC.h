//
//  WeiSuWorkCC.h
//  Demo
//
//  Created by YanSY on 2018/6/19.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiSuWorkCC : NSObject

+ (id)instanceWorkCC;

- (UIView *)workCCbackView;

- (void)fetchData;

- (void)setVCGenerator:(UIViewController * (^)(id params))VCGenerator;

@end
