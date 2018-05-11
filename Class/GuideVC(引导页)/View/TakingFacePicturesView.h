//
//  TakingFacePictures.h
//  Demo
//
//  Created by YanSY on 2017/11/23.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <UIKit/UIKit.h>

// 定义人脸识别视图代理
@protocol TakingFacePicturesViewDelegate <NSObject>

@required // 必须实现的方法


@optional // 可以实现的方法

- (void)BackIdentifyFaceImage:(UIImage *)faceImage;

@end

@interface TakingFacePicturesView : UIView

/// 设置代理
@property (nonatomic, strong)  id<TakingFacePicturesViewDelegate> delegate;

#pragma mark -- 开始和结束拍照
- (void)startRunningSession;

- (void)stopRunningSession;
@end
