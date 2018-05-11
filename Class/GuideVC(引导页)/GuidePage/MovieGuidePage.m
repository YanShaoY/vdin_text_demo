//
//  MovieGuidePage.m
//  Demo
//
//  Created by YanSY on 2017/11/30.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "MovieGuidePage.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface MovieGuidePage ()

@property (nonatomic, strong) UIImageView * guideView;

@property (nonatomic, strong) AVPlayerViewController * moviePlayerVC;

@property (nonatomic, strong) UIButton * returnButton;

@end

@implementation MovieGuidePage

#pragma mark -- 00 初始化
+ (MovieGuidePage *)sharedMovieGuidePage{
    static MovieGuidePage * page = nil;
    page = [[MovieGuidePage alloc]init];
    return page;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = KEYWINDOW.bounds;
        self.backgroundColor = [UIColor clearColor];
        
        self.guideView = [[UIImageView alloc]initWithFrame:KEYWINDOW.bounds];
        [_guideView setImage:[UIImage imageNamed:@"guidePage"]];
        [self addSubview:_guideView];
        _guideView.alpha = 1.0;
        
        [KEYWINDOW addSubview:self];
        [KEYWINDOW bringSubviewToFront:self];

        [self addSubview:self.moviePlayerVC.view];
        [self addSubview:self.returnButton];
        
        [self.moviePlayerVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
        }];
        
        [self.returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.width.mas_equalTo(SCREENWIDTH-100);
            make.height.mas_equalTo(50.0);
            make.bottom.equalTo(self.mas_bottom).offset(-50);
        }];
    }
    return self;
}

#pragma mark -- 播放动画
+ (void)showGuideViewWithURL:(NSURL *)movieURL{
    [[MovieGuidePage sharedMovieGuidePage]showGuideViewWithURL:movieURL];
}

- (void)showGuideViewWithURL:(NSURL *)movieURL{
    
    // 设置媒体源数据
    _moviePlayerVC.player = [AVPlayer playerWithURL:movieURL];
    // 播放视频
    [_moviePlayerVC.player play];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(runLoopTheMovie) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //注册程序进入前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (startGuideAnimation) name: UIApplicationDidBecomeActiveNotification object:nil];
    //注册程序进入后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (pauseGuideAnimation) name: UIApplicationWillResignActiveNotification object:nil];

    [UIView animateWithDuration:3 animations:^{
        _moviePlayerVC.view.alpha = 1;
        _returnButton.alpha = 1;
    } completion:^(BOOL finished) {
        [self.guideView removeFromSuperview];
    }];
}

- (void)runLoopTheMovie{
    [CATransaction begin];
    [_moviePlayerVC.player seekToTime:kCMTimeZero];
    [_moviePlayerVC.player play];
    [CATransaction commit];
 
}

#pragma mark -- 通知处理
- (void)startGuideAnimation{
    [_moviePlayerVC.player play];
}

- (void)pauseGuideAnimation{
//    [_moviePlayerVC.player pause];
}

#pragma mark -- 懒加载
- (AVPlayerViewController *)moviePlayerVC{
    if (!_moviePlayerVC) {
        _moviePlayerVC = [[AVPlayerViewController alloc]init];
        _moviePlayerVC.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _moviePlayerVC.showsPlaybackControls = NO;
//        _moviePlayerVC.delegate = self;
        _moviePlayerVC.view.frame = KEYWINDOW.bounds;
        _moviePlayerVC.view.alpha = 0.0f;
        
//        _moviePlayerVC.videoBounds = CGRectMake(0, 0, 200, 200);
    }
    return _moviePlayerVC;
}

- (UIButton *)returnButton{
    if (!_returnButton) {
        _returnButton = [[UIButton alloc]init];
        _returnButton.layer.masksToBounds = YES;
        _returnButton.layer.borderWidth = 1.0f;
        _returnButton.layer.cornerRadius = 25;
        _returnButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [_returnButton setTitle:@"进入应用" forState:UIControlStateNormal];
        _returnButton.alpha = 0.0f;
        [_returnButton addTarget:self action:@selector(guideRootVCToHomeVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _returnButton;
}

- (void)guideRootVCToHomeVC{
    
    [UIView animateWithDuration:1 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [_moviePlayerVC.player pause];
        _moviePlayerVC.player = nil ;
        [_moviePlayerVC.view removeFromSuperview];
        [self removeFromSuperview];
    }];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)dealloc{
    NSLog(@"界面释放");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
