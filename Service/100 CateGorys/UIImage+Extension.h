//
//  UIImage+Extension.h
//  GAProduct
//
//  Created by sunlang on 2017/3/28.
//  Copyright © 2017年 ZDHT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

/**
 压缩图片到指定大小
 
 @param img   需要改变的图片对象
 @param kb    需要压缩到大小, 单位 kb
 @param px    最大边长
 
 @return 经过压缩处理后的图片对象
 */
+ (NSData *)scaleImage:(UIImage *)img maxKb:(int)kb maxPx:(int)px;

//自动缩放到指定大小
- (UIImage *)thumbnailWithSize:(CGSize)aSize;

//返回调整的缩略图(和上面一样)
- (UIImage *)imageFitInSize: (CGSize) viewsize;

//返回居中的缩略图(原比例居中)
- (UIImage *)imageCenterInSize: (CGSize) viewsize;

//返回填充的缩略图(这个用于在所有图片列表显示的时候, 用这种去掉一部分多余的边, 缩放比例)
- (UIImage *)imageFillSize: (CGSize) viewsize;

@end

@interface UIImage (GAColor)

/**
 根据颜色生成图片

 @param color 颜色

 @return 图片
 */
+ (UIImage *)generateImageWithColor:(UIColor *)color;

@end

@interface UIImage (GAQRCode)

/**
 *  字符串生成二维码
 *
 *  @param qrString 需要转换的字符串
 *  @param size     图片的大小
 *
 *  @return 二维码图片, 图片背景默认透明, 二维码为黑色
 */
+ (UIImage *)creatQRCodeImageForString:(NSString *)qrString contentSize:(CGSize)size;

/**
 *  字符串生成二维码
 *
 *  @param qrString 需要转换的字符串
 *  @param size     图片的大小
 *
 *  @return 二维码图片, 图片背景默认透明, 二维码为黑色
 */
+ (UIImage *)creatQRCodeImageForString:(NSString *)qrString contentSize:(CGSize)size r:(CGFloat)r g:(CGFloat)g b:(CGFloat)b;

/**
 *  改变图片的尺寸
 *
 *  @param image 图片
 *  @param size  需要的尺寸
 *
 *  @return 新生成的图片
 */
+ (UIImage *)creatNonInterpolatedUIImageFormCIImage:(CIImage *)image size:(CGSize)size;

/**
 *  改变二维码的颜色,背景透明
 *
 *  @param r r  0 ~ 255
 *  @param g g  0 ~ 255
 *  @param b b  0 ~ 255
 *
 *  @return 新生成的图片
 */
+ (UIImage *)specialColorImage:(UIImage *)img WithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b;

/**
 *  带圆角效果的图片
 *
 *  @param image    图片
 *  @param size   大小
 *  @param radius 弧度
 *
 *  @return 新生成的图片
 */
+ (UIImage *)creatRoundeRectImage:(UIImage *)image size:(CGSize)size radius:(NSInteger)radius;

/**
 *  添加一张图片到二维码里面
 *
 *  @param image    二维码图片
 *  @param icon     需要嵌入的图片
 *  @param iconSize 嵌入图片的大小
 *
 *  @return 新生成的图片
 */
+ (UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withIconSize:(CGSize)iconSize;

/**
 *  添加一张图片到二维码里面
 *
 *  @param image 二维码图片
 *  @param icon  需要嵌入的图片
 *  @param scale 比例
 *
 *  @return 新生成的图片
 */
+ (UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withScale:(CGFloat)scale;

@end

@interface UIImage (Video)

/**
 获取某一帧图片

 @param videoUrl 视频文件路径
 @param time     时间

 @return 这一帧的图片
 */
+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoUrl atTime:(NSTimeInterval)time;

@end

@interface UIImage (Tool)

/// 获取屏幕截图
///
/// @return 屏幕截图图像
+ (UIImage *)GA_screenShot;


/**
 *  生成一张高斯模糊的图片
 *
 *  @param image 原图
 *  @param blur  模糊程度 (0~1)
 *
 *  @return 高斯模糊图片
 */
+ (UIImage *)GA_blurImage:(UIImage *)image blur:(CGFloat)blur;

@end
