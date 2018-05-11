//
//  guidePage.m
//  Demo
//
//  Created by YanSY on 2017/11/21.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "guidePage.h"

#import "guideAnimationView.h"
#import "TakingFacePicturesView.h"
#import "CycleProgressView.h"

#import "GATouchIDValidationService.h"

@interface guidePage()<TakingFacePicturesViewDelegate>{
    
    TakingFacePicturesView * facePicturesView;
    UILabel * messageLabel;
}

@end

@implementation guidePage

#pragma mark -- 00 初始化
+ (guidePage *)sharedGuidePage{
    static guidePage * page = nil;
    page = [[guidePage alloc]init];
    return page;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //注册程序进入前台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (startGuideAnimation) name: UIApplicationDidBecomeActiveNotification object:nil];
        //注册程序进入后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (pauseGuideAnimation) name: UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

#pragma mark -- 01 显示指纹识别动画
+ (void)showGuideViewForWindow:(UIWindow *)window{
    [[guidePage sharedGuidePage]showGuideViewForWindow:window];
}

- (void)showGuideViewForWindow:(UIWindow *)window{
    
    UIImageView * guideView = [[UIImageView alloc]initWithFrame:window.bounds];
    [guideView setImage:[UIImage imageNamed:@"guidePage"]];
    [window addSubview:guideView];
    [window bringSubviewToFront:guideView];
    guideView.alpha = 1.0;
    
    guideAnimationView * touchIdTodoView = [[guideAnimationView alloc]initAnimationViewWithNamed:@"1指纹识别中" andLoop:YES];
    touchIdTodoView.userInteractionEnabled = YES;
    touchIdTodoView.alpha = 0;
    [touchIdTodoView play];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchIdBegin)];
    tap.numberOfTapsRequired = 1;
    [touchIdTodoView addGestureRecognizer:tap];

    [UIView animateWithDuration:1.0f delay:1.0f options:UIViewAnimationOptionTransitionNone animations:^{
        touchIdTodoView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [guideView removeFromSuperview];
    }];
}

#pragma mark -- 02 调用touchId
- (void)touchIdBegin{
    @weakify(self);
    [GATouchIDValidationService showTouchIDWithBlock:^(BOOL success, LAError code) {
        @strongify(self);
        // 判断是否应该跳转
        if (success || code == LAErrorTouchIDNotEnrolled) {
            // 回主线程切换UI
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                guideAnimationView * touchIdDoYesView = [[guideAnimationView alloc] initAnimationViewWithNamed:@"2指纹识别成功" andLoop:NO];
                CATransition * transition = [CATransition animation];
                transition.duration = 1;
                transition.type = @"rippleEffect";
                transition.subtype = @"fromBottom";
                [touchIdDoYesView.superview.layer addAnimation:transition forKey:nil];

                [touchIdDoYesView playWithCompletion:^(BOOL animationFinished) {
                    

                    facePicturesView = [[TakingFacePicturesView alloc]init];
                    facePicturesView.alpha = 0.0f;
                    facePicturesView.delegate = self;
                    [KEYWINDOW addSubview:facePicturesView];
                    [KEYWINDOW bringSubviewToFront:facePicturesView];
                    
                    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                        facePicturesView.alpha = 1.0;
                    } completion:^(BOOL finished) {
                        facePicturesView.alpha = 1.0;
                    }];
                    
                }];
                
                [self showFaceRecognitionReadyView];

            });

        }

    }];
    
}

#pragma mark -- 03 准备人脸识别
- (void)showFaceRecognitionReadyView{

    guideAnimationView * rotatingReadyView = [[guideAnimationView alloc] initAnimationViewWithNamed:@"3圈圈放大" andLoop:NO];
    @weakify(self);
    [rotatingReadyView playWithCompletion:^(BOOL animationFinished) {
        @strongify(self);
        [self showFaceRecognitionBeginView];
    }];
    
}

#pragma mark -- 04 开始人脸识别
- (void)showFaceRecognitionBeginView{

    for (UIView * view in KEYWINDOW.subviews) {
        if ([view isKindOfClass:[LOTAnimationView class]]) {
            LOTAnimationView * v = (LOTAnimationView *)view;
            [view removeFromSuperview];
            v = nil;
        }
    }
    
    guideAnimationView * faceRecognitionView = [[guideAnimationView alloc] initAnimationViewWithNamed:@"4圈圈旋转" andLoop:YES];
    [faceRecognitionView play];
    
    messageLabel = [[UILabel alloc]init];
    messageLabel.text = @"请对准识别框，进行脸部识别";
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.tag = 111;
    
    [faceRecognitionView addSubview:messageLabel];
    
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(faceRecognitionView.mas_centerX);
        make.bottom.equalTo(faceRecognitionView.mas_bottom).offset(-200);
    }];
    
    [self startMessageLabelAnimation];
}

#pragma label 动画
- (void)startMessageLabelAnimation{
    messageLabel.hidden = NO;
    [UIView animateKeyframesWithDuration:1.5 delay:0 options:UIViewKeyframeAnimationOptionRepeat animations:^{
        messageLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {
        messageLabel.alpha = 1.0f;
    }];
}

- (void)stopMessageLabelAnimation{
    messageLabel.hidden = YES;
    
}

#pragma mark -- 05 人脸识别回调
- (void)BackIdentifyFaceImage:(UIImage *)faceImage{
    
    // 获取人脸数据
    NSArray * faceArr = [faceImage dataOfByFaceRecognition];
    
    NSDictionary * faceDataDict =(NSDictionary *)faceArr[0];
    CGRect faceFrame = CGRectFromString(faceDataDict[@"faceViewFrame"]);
    CGPoint leftEyePosition = CGPointFromString(faceDataDict[@"leftEyePosition"]);
    CGPoint rightEyePosition = CGPointFromString(faceDataDict[@"rightEyePosition"]);
    CGPoint mouthPosition = CGPointFromString(faceDataDict[@"mouthPosition"]);
    
    // 判断条件
    if (faceFrame.size.width < 70 || faceFrame.size.height < 70) return;
    if (leftEyePosition.x == 0 || leftEyePosition.y == 0) return;
    if (rightEyePosition.x == 0 || rightEyePosition.y == 0) return;
    if (mouthPosition.x == 0 || mouthPosition.y == 0) return;
    
    [self stopMessageLabelAnimation];

    
    guideAnimationView * faceWireframeView = [[guideAnimationView alloc] initAnimationViewWithNamed:@"5人脸线框动画" andLoop:YES];
    faceWireframeView.alpha = 0.0f;
    [faceWireframeView play];
    
    [UIView animateWithDuration:1 animations:^{
        faceWireframeView.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
    
    [facePicturesView stopRunningSession];

    guideAnimationView * rectangularView = [[guideAnimationView alloc] initAnimationViewWithNamed:@"6矩形波浪" andLoop:YES];
    [rectangularView play];

    guideAnimationView * wavesView = [[guideAnimationView alloc] initAnimationViewWithNamed:@"7线条波浪" andLoop:YES];
    [wavesView play];

    CycleProgressView * progress = [[CycleProgressView alloc]init];
    [wavesView addSubview:progress];
    [progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wavesView.mas_bottom).offset(-90);
        make.right.equalTo(wavesView.mas_right).offset(-50);
    }];
    [progress startAnimationWithProgess:0.7f andAnimation:1];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(guideRootVCToHomeVC) userInfo:nil repeats:NO];
    
    
    //            UIView * resultView = [[UIView alloc]init];
    //            [self.imageView addSubview:resultView];
    
    //            [resultView mas_makeConstraints:^(MASConstraintMaker *make) {
    //                make.top.bottom.left.right.equalTo(self.imageView);
    //            }];
    
    
    
    //            UIView * leftEyeView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, 20, 20)];
    //            leftEyeView.center = leftEyePosition;
    //            leftEyeView.backgroundColor = [UIColor redColor];
    //            [resultView addSubview:leftEyeView];
    //
    //            UIView * rightEyeView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, 20, 20)];
    //            rightEyeView.center = rightEyePosition;
    //            rightEyeView.backgroundColor = [UIColor redColor];
    //            [resultView addSubview:rightEyeView];
    //
    //            UIView * mouthEyeView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, 20, 20)];
    //            mouthEyeView.center = mouthPosition;
    //            mouthEyeView.backgroundColor = [UIColor redColor];
    //            [resultView addSubview:mouthEyeView];
    //
    //
    //            UIView * faceView = [[UIView alloc]initWithFrame: faceViewFrame];
    //            faceView.layer.borderWidth = 2.0f;
    //            faceView.layer.borderColor = [UIColor redColor].CGColor;
    //            [resultView addSubview:faceView];
    //
    //            [resultView setTransform:CGAffineTransformMakeScale(1, -1)];
    
}


#pragma mark -- 通知处理
- (void)startGuideAnimation{
    
    for (UIView * view in KEYWINDOW.subviews) {
        if ([view isKindOfClass:[LOTAnimationView class]]) {
            
            LOTAnimationView * animationView = (LOTAnimationView *)view;
            [animationView play];
        }
    }
}

- (void)pauseGuideAnimation{
    for (UIView * view in KEYWINDOW.subviews) {
        if ([view isKindOfClass:[LOTAnimationView class]]) {
            
            LOTAnimationView * animationView = (LOTAnimationView *)view;
            [animationView pause];
        }
    }
}

#pragma mark -- end 注销所有通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark -- 回到主界面
+ (void)guideRootVCToHomeVC{
    [[guidePage sharedGuidePage]guideRootVCToHomeVC];

//    //应该是注销的时候返回这个Home界面
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"GuidePage" bundle:nil];
//    GAHomeVC *GA = [sb instantiateViewControllerWithIdentifier:@"GAHomeVC"];
//    GABaseNavVC *nav = [[GABaseNavVC alloc] initWithRootViewController:GA];
//    [UIApplication sharedApplication].keyWindow.rootViewController = nav;
}

- (void)guideRootVCToHomeVC{
    
    for (UIView * view in KEYWINDOW.subviews) {
        if ([view isKindOfClass:[LOTAnimationView class]] || [view isKindOfClass:[TakingFacePicturesView class]]) {

            [UIView animateWithDuration:1 animations:^{
                view.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
        }

    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

@end
