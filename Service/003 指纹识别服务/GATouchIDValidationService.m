//
//  GATouchIDValidationService.m
//  GAProduct
//
//  Created by YanSY on 2017/8/16.
//  Copyright © 2017年 ZDHT. All rights reserved.
//

#import "GATouchIDValidationService.h"

@interface GATouchIDValidationService ()

@property (nonatomic , strong) GATouchIDBlock myBlock;

@end

@implementation GATouchIDValidationService

#pragma mark -- 初始化

+ (GATouchIDValidationService *)sharedGATouchIDValidationService{
    static GATouchIDValidationService * service = nil;
    service = [[GATouchIDValidationService alloc]init];
    return service;
}

+ (void)showTouchIDWithBlock:(GATouchIDBlock)block{
    [[GATouchIDValidationService sharedGATouchIDValidationService]showTouchIDWithBlock:block];
}

#pragma mark -- 类方法
- (void)showTouchIDWithBlock:(GATouchIDBlock)block{
    self.myBlock = block;
    [self touchIDAction];
}

#pragma mark -- 指纹识别
- (void)touchIDAction{

    LAContext* context = [[LAContext alloc]init];
    
    if (@available(iOS 10.0, *)) {
        context.localizedCancelTitle = @"取消";
    }
    context.localizedFallbackTitle = @"输入密码";
    
    NSError * error;
    NSString* result = @"通过Home键验证已有手机指纹";
    
    if (@available(iOS 8.0, *)) {
        if (@available(iOS 11.0, *)) {
            
            if (context.biometryType == LABiometryTypeTouchID) {
                
                result = @"通过Home键验证已有手机指纹";
                
            }else if (context.biometryType == LABiometryTypeFaceID){
                
                result = @"通过FaceID验证已有手机指纹";
            }
            
        }
        
    }else{
        
        [self TouchIDResult:error.code];
        return;
        
    }
    
    [self authenticationWithType:result withContent:context andError:error];
}

- (void)authenticationWithType:(NSString *)result withContent:(LAContext *)context andError:(NSError *)error{
    /*
     密码验证:
     LAPolicyDeviceOwnerAuthentication  手机数字密码
     LAPolicyDeviceOwnerAuthenticationWithBiometrics  手机指纹密码
     */
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]){
        
        @weakify(self);
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error){
            @strongify(self);
            if (success)
            {
                [self backGATouchIDBlockWith:success andCode:error.code];
                return;
            }
            else
            {
                [self TouchIDResult:error.code];
                return;
            }
        }];
    }
    
    else
    {
        [self TouchIDResult:error.code];
        return;
    }

}
#pragma mark -- 错误分析
- (void)TouchIDResult:(LAError)code{
    switch (code)
    {
         case LAErrorTouchIDLockout:
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                LAContext* context = [LAContext new];
                NSString* str = @"请输入手机密码";
                @weakify(self);
                [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:str reply:^(BOOL success, NSError *error){
                    @strongify(self);
                    if (success)
                    {
                        [self touchIDAction];
                    }
                    else
                    {
                        [self TouchIDResult:error.code];
                    }
                }];
            });

        }
            
        default:
            [self backGATouchIDBlockWith:NO andCode:code];
            break;

            
     }
}

#pragma mark -- 回调
- (void)backGATouchIDBlockWith:(BOOL)success andCode:(LAError)code{
    
    if (self.myBlock) {
        self.myBlock(success , code);
    }
}

@end





