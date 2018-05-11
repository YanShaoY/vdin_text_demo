//
//  UIImage+FaceDetection.m
//  Demo
//
//  Created by YanSY on 2017/11/23.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "UIImage+FaceDetection.h"

@implementation UIImage (FaceDetection)

#pragma mark -- 图片预处理
/**
 图片方向的处理 镜像或旋转
 
 @return 翻转后的图片
 */
- (UIImage *)fixImageOrientation{
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

/**
 图片压缩处理到指定尺寸
 
 @param size 需要压缩的指定尺寸
 @return 压缩处理后的图片
 */
- (UIImage *)imageCompressionProcessingForTargetSize:(CGSize)size{
    if (size.width == 0 || size.height == 0) {
        size = CGSizeMake(450, 800);
    }
    
    UIImage *   newImage     = nil;
    CGSize      imageSize    = self.size;
    
    CGFloat     width        = imageSize.width;
    CGFloat     height       = imageSize.height;
    
    CGFloat     targetWidth  = size.width;
    CGFloat     targetHeight = size.height;
    
    CGFloat     scaleFactor  = 0.0;
    CGFloat     scaledWidth  = targetWidth;
    CGFloat     scaledHeight = targetHeight;
    
    CGPoint   thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor  = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            
            scaleFactor = widthFactor;
        }
        else{
            
            scaleFactor = heightFactor;
        }
        
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [self drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
        return newImage;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    if (imageData.length>100*1024) {
        if (imageData.length>1024*1024) {     //1M以及以上
            imageData=UIImageJPEGRepresentation(newImage, 0.1);
        }else if (imageData.length>512*1024) {//0.5M-1M
            imageData=UIImageJPEGRepresentation(newImage, 0.3);
        }else if (imageData.length>200*1024) {//0.25M-0.5M
            imageData=UIImageJPEGRepresentation(newImage, 0.7);
        }
    }
    UIImage * returnImg = [UIImage imageWithData:imageData];
    
    return returnImg;
}

/**
 截取图片的指定矩形范围
 
 @param rect 需要截取的矩形范围
 @return 截取后的图片
 */
- (UIImage *)cutImageForRect:(CGRect)rect{
    
//    //把像素rect 转化为 点rect（如无转化则按原图像素取部分图片）
//    CGFloat scale = [UIScreen mainScreen].scale;
//    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
//    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [self CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:UIImageOrientationUp];
    return newImage;
}

#pragma mark -- 人脸识别

/**
 通过人脸识别得出有效人脸数
 
 @return 有效人脸个数
 */
- (NSUInteger)totalNumberOfFacesByFaceRecognition{
    
    CIContext * context = [CIContext contextWithOptions:nil];
    
    CIImage * cImage = [CIImage imageWithCGImage:self.CGImage];
    
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    
    NSArray * detectResult = [faceDetector featuresInImage:cImage];
    
    return detectResult.count;
}

/**
 通过人脸识别提取有效人脸图片
 
 @return 有效人脸图片集合
 */
- (NSArray *)faceImagesByFaceRecognition{
    
    CIContext * context = [CIContext contextWithOptions:nil];
    
    CIImage * cImage = [CIImage imageWithCGImage:self.CGImage];
    
    
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    
    
    NSArray * detectResult = [faceDetector featuresInImage:cImage];
    
    NSMutableArray * imagesArr = [[NSMutableArray alloc] init];
    
    for (int i = 0; i< detectResult.count; i++) {
        
        CIImage * faceImage = [cImage imageByCroppingToRect:[[detectResult objectAtIndex:i] bounds]];
        UIImage * faceImg   = [UIImage imageWithCIImage:faceImage];
        [imagesArr addObject:faceImg];
        // PS 这里的图片加入进去是反的 所以在加载imageView时需要翻转视图
    }
    
    return [NSArray arrayWithArray:imagesArr];
    
}

/**
 通过人脸识别获取脸部数据

 @return 脸部数据集合
 */
- (NSArray *)dataOfByFaceRecognition{
    
    CIImage       * imageInput   = [CIImage imageWithCGImage:self.CGImage];
    NSDictionary  * param        = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIContext     * context      = [CIContext contextWithOptions:nil];
    
    CIDetector    * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    NSArray       * detectResult = [faceDetector featuresInImage:imageInput];
    
    // 定义搭载所有人脸数据集合的数组
    NSMutableArray * faceDataArr = [[NSMutableArray alloc]init];
    
    // 遍历人脸数据
    for (CIFaceFeature * faceFeature in detectResult)
    {
        // 定义搭载单独人脸数据的字典
        NSMutableDictionary * faceDataDict = [[NSMutableDictionary alloc]init];
        
        //注意坐标的换算，CIFaceFeature计算出来的坐标的坐标系的Y轴与iOS的Y轴是相反的,需要自行处理

        //获取人脸的frame
//        CGRect  faceViewFrame  = CGRectMake(faceFeature.bounds.origin.x, self.size.height- faceFeature.bounds.origin.y - faceFeature.bounds.size.height, faceFeature.bounds.size.width, faceFeature.bounds.size.height);
        
//        UIView* faceView = [[UIView alloc] initWithFrame:faceFeature.bounds];
//        faceView.frame = CGRectMake(faceView.frame.origin.x, self.size.height-faceView.frame.origin.y - faceView.bounds.size.height, faceView.frame.size.width, faceView.frame.size.height);
        // 人脸区域
        [faceDataDict setValue:NSStringFromCGRect(faceFeature.bounds) forKey:@"faceViewFrame"];
        
        if (faceFeature.hasLeftEyePosition) {
            // 左眼位置
            [faceDataDict setValue:NSStringFromCGPoint(faceFeature.leftEyePosition) forKey:@"leftEyePosition"];
        }
        
        if (faceFeature.hasRightEyePosition) {
            // 右眼位置
            [faceDataDict setValue:NSStringFromCGPoint(faceFeature.rightEyePosition) forKey:@"rightEyePosition"];
        }
        
        if (faceFeature.hasMouthPosition) {
            // 嘴巴位置
            [faceDataDict setValue:NSStringFromCGPoint(faceFeature.mouthPosition) forKey:@"mouthPosition"];
        }

        
        // 将单个人脸识别数据加入数组
        [faceDataArr addObject:faceDataDict];
    }
    
    if (faceDataArr.count == 0) {
        return nil;
    }else{
        
        return faceDataArr;
    }
}

/**
 根据颜色生成图片
 
 @param color 颜色
 
 @return 图片
 */
- (UIImage *)imageWithColor:(UIColor *)color {
    //创建1像素区域并开始图片绘图
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    
    //创建画板并填充颜色和区域
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    //从画板上获取图片并关闭图片绘图
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end





















