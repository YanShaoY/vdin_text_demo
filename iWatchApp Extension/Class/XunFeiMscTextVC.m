//
//  XunFeiMscTextVC.m
//  iWatchApp Extension
//
//  Created by YanSY on 2018/6/29.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "XunFeiMscTextVC.h"

@interface XunFeiMscTextVC ()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *mscTableView;

@end

@implementation XunFeiMscTextVC

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



