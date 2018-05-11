//
//  UIImage+FaceDetection.h
//  Demo
//
//  Created by YanSY on 2017/11/23.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FaceDetection)

#pragma mark -- 图片预处理

/**
 图片方向的处理 镜像或旋转
 
 @return 翻转后的图片
 */
- (UIImage *)fixImageOrientation;

/**
 图片压缩处理到指定尺寸
 
 @param size 需要压缩的指定尺寸
 @return 压缩处理后的图片
 */
- (UIImage *)imageCompressionProcessingForTargetSize:(CGSize)size;

/**
 截取图片的指定矩形范围
 
 @param rect 需要截取的矩形范围
 @return 截取后的图片
 */
- (UIImage *)cutImageForRect:(CGRect)rect;

#pragma mark -- 人脸识别

/**
 通过人脸识别提取有效人脸图片

 @return 有效人脸图片集合
 */
- (NSArray *)faceImagesByFaceRecognition;

/**
 通过人脸识别得出有效人脸数
 
 @return 有效人脸个数
 */
- (NSUInteger)totalNumberOfFacesByFaceRecognition;

/**
 通过人脸识别获取脸部数据
 
 @return 脸部数据集合
 */
- (NSArray *)dataOfByFaceRecognition;

/**
 根据颜色生成图片
 
 @param color 颜色
 
 @return 图片
 */
- (UIImage *)imageWithColor:(UIColor *)color;

@end











