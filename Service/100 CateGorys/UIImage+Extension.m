//
//  UIImage+Extension.m
//  GAProduct
//
//  Created by sunlang on 2017/3/28.
//  Copyright © 2017年 ZDHT. All rights reserved.
//

#import "UIImage+Extension.h"
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>

@implementation UIImage (Extension)

//压缩图片到指定大小
+ (NSData *)scaleImage:(UIImage *)img maxKb:(int)kb maxPx:(int)px
{
    if (!img) {
        return nil;
    }
    if (kb < 1) {
        return nil;
    }
    
    kb = kb * 1000;
    UIImage *scaleImage = [self scaleFromImage:img maxPx:px];
    
    NSData *imageData = UIImageJPEGRepresentation(scaleImage, 1.0);
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.1f;
    
    while ([imageData length] > kb && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(scaleImage, compression);
    }
    
    return imageData;
}

+ (UIImage *)scaleFromImage:(UIImage *)image maxPx:(int)px
{
    if (!image) {
        return nil;
    }
    
    int threshold = px;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGSize size;
    if ((width <= threshold) && (height <= threshold))
    {
        size = CGSizeMake(width, height);
        return image;
    }
    else if ((width > threshold) || (height > threshold))
    {
        CGFloat ratio1;
        CGFloat ratio2;
        ratio1 = width / height;
        ratio2 = height / width;
        
        if (ratio1 > 1) {
            
            if (ratio1 <= 2) {
                height = height / (width / threshold);
                width = threshold;
            }
            else
            {
                if (height > threshold) {
                    
                    width = width / (height / threshold);
                    height = threshold;
                }
            }
        }
        else if (ratio2 > 1) {
            
            if (ratio2 <= 2) {
                width = width / (height / threshold);
                height = threshold;
            }
            else
            {
                if (width > threshold) {
                    
                    height = height / (width / threshold);
                    width = threshold;
                }
            }
        }
        else
        {
            height = threshold;
            width = threshold;
        }
        size = CGSizeMake(width, height);
    }else{
        size.width = width;
        size.height = height;
    }
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!newImage) {
        return image;
    }
    return newImage;
}

//自动缩放到指定大小
- (UIImage *)thumbnailWithSize:(CGSize)aSize
{
    UIImage *newImage;
    if (self == nil)
    {
        newImage = nil;
    }
    else
    {
        UIGraphicsBeginImageContext(aSize);
        
        [self drawInRect:CGRectMake(0, 0, aSize.width, aSize.height)];
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    return newImage;
}

//计算适合的大小。并保留其原始图片大小

- (CGSize) fitSize: (CGSize)thisSize inSize: (CGSize) aSize
{
    CGFloat scale;
    CGSize newsize = thisSize;
    
    if (newsize.height && (newsize.height > aSize.height))
    {
        scale = aSize.height / newsize.height;
        newsize.width *= scale;
        newsize.height *= scale;
    }
    
    if (newsize.width && (newsize.width >= aSize.width))
    {
        scale = aSize.width / newsize.width;
        newsize.width *= scale;
        newsize.height *= scale;
    }
    
    return newsize;
}

//返回调整的缩略图

- (UIImage *)imageFitInSize: (CGSize) viewsize
{
    // calculate the fitted size
    CGSize size = [self fitSize:self.size inSize:viewsize];
    
    UIGraphicsBeginImageContext(viewsize);
    
    float dwidth = (viewsize.width - size.width) / 2.0f;
    float dheight = (viewsize.height - size.height) / 2.0f;
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
    [self drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

//返回居中的缩略图

- (UIImage *)imageCenterInSize: (CGSize) viewsize
{
    CGSize size = self.size;
    
    UIGraphicsBeginImageContext(viewsize);
    float dwidth = (viewsize.width - size.width) / 2.0f;
    float dheight = (viewsize.height - size.height) / 2.0f;
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
    [self drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

//返回填充的缩略图

- (UIImage *)imageFillSize: (CGSize) viewsize

{
    CGSize size = self.size;
    
    CGFloat scalex = viewsize.width / size.width;
    CGFloat scaley = viewsize.height / size.height;
    CGFloat scale = MAX(scalex, scaley);
    
    UIGraphicsBeginImageContext(viewsize);
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    
    float dwidth = ((viewsize.width - width) / 2.0f);
    float dheight = ((viewsize.height - height) / 2.0f);
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
    [self drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

@end

@implementation UIImage (GAColor)

+ (UIImage *)generateImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.f, 0.f, 1.f, 1.f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

@implementation UIImage (GAQRCode)

#pragma mark - 字符串生成二维码
/**
 *  字符串生成二维码
 *
 *  @param qrString 需要转换的字符串
 *  @param size     图片的大小
 *
 *  @return 二维码图片, 图片背景默认透明, 二维码为黑色
 */
+ (UIImage *)creatQRCodeImageForString:(NSString *)qrString contentSize:(CGSize)size;
{
    NSData *strData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    //创建 filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //设置内容和纠错级别
    [qrFilter setValue:strData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    //设定尺寸, 生成image
    UIImage *image = [self creatNonInterpolatedUIImageFormCIImage:qrFilter.outputImage size:size];
    
    //设置颜色
    image = [self specialColorImage:image WithRed:0 green:0 blue:0];
    
    return image;
}

+ (UIImage *)creatQRCodeImageForString:(NSString *)qrString contentSize:(CGSize)size r:(CGFloat)r g:(CGFloat)g b:(CGFloat)b{
    NSData *strData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    //创建 filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //设置内容和纠错级别
    [qrFilter setValue:strData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    //设定尺寸, 生成image
    UIImage *image = [self creatNonInterpolatedUIImageFormCIImage:qrFilter.outputImage size:size];
    
    //    const CGFloat *components = CGColorGetComponents(color.CGColor);
    //    CGFloat r = components[0];
    //    CGFloat g = components[1];
    //    CGFloat b = components[2];
    //设置颜色
    image = [self specialColorImage:image WithRed:r green:g blue:b];
    
    return image;
}

#pragma mark - 改变图片的尺寸

/**
 *  改变图片的尺寸
 *
 *  @param image 图片
 *  @param size  需要的尺寸
 *
 *  @return 新生成的图片
 */
+ (UIImage *)creatNonInterpolatedUIImageFormCIImage:(CIImage *)image size:(CGSize)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size.width/CGRectGetWidth(extent), size.height/CGRectGetHeight(extent));
    
    //创建位图
    size_t iW = CGRectGetWidth(extent) * scale;
    size_t iH = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, iW, iH, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImg = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImg);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImg);
    
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - 改变二维码颜色

/**
 *  改变二维码的颜色
 *
 *  @param r r
 *  @param g g
 *  @param b b
 *
 *  @return 新生成的图片
 */
+ (UIImage *)specialColorImage:(UIImage *)img WithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b;
{
    const int iW = img.size.width;
    const int iH = img.size.height;
    size_t bytesPerRow = iW * 4;
    uint32_t *rgbImgBuf = (uint32_t *)malloc(bytesPerRow * iH);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImgBuf, iW, iH, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, iW, iH), img.CGImage);
    
    //遍历像素, 改变颜色
    int pixelNum = iW * iH;
    uint32_t * pCurptr = rgbImgBuf;
    for (int i = 0; i < pixelNum; i++, pCurptr++)
    {
        if ((*pCurptr & 0xFFFFFF00) < 0x99999900) {
            
            uint8_t * ptr = (uint8_t *)pCurptr;
            ptr[3] = r;
            ptr[2] = g;
            ptr[1] = b;
        } else {
            
            uint8_t * ptr = (uint8_t *)pCurptr;
            ptr[0] = 0;
        }
    }
    
    //输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImgBuf, bytesPerRow * iH, ProviderReleaseData);
    
    CGImageRef imgRef = CGImageCreate(iW, iH, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage *resultImg = [UIImage imageWithCGImage:imgRef];
    
    //清理
    CGImageRelease(imgRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultImg;
}

//数据释放
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void *)data);
}

#pragma mark - 带圆角效果的图片
/**
 *  带圆角效果的图片
 *
 *  @param image 图片
 *  @param size   大小
 *  @param radius 弧度
 *
 *  @return 新生成的图片
 */
+ (UIImage *)creatRoundeRectImage:(UIImage *)image size:(CGSize)size radius:(NSInteger)radius
{
    int w = size.width;
    int h = size.height;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpaceRef, (CGBitmapInfo)
                                                    kCGImageAlphaPremultipliedFirst);
    
    CGRect rect = CGRectMake(0, 0, w, h);
    
    
    CGContextBeginPath(contextRef);
    addRoundedRectToPath(contextRef, rect, radius, radius);
    CGContextClip(contextRef);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, w, h), image.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(contextRef);
    UIImage *img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageMasked);
    return img;
}

static void addRoundedRectToPath(CGContextRef contextRef, CGRect rect, float widthOfRadius, float heightOfRadius)
{
    float fw, fh;
    if (widthOfRadius == 0 || heightOfRadius == 0)
    {
        CGContextAddRect(contextRef, rect);
        return;
    }
    
    CGContextSaveGState(contextRef);
    CGContextTranslateCTM(contextRef, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(contextRef, widthOfRadius, heightOfRadius);
    fw = CGRectGetWidth(rect) / widthOfRadius;
    fh = CGRectGetHeight(rect)/ heightOfRadius;
    
    CGContextMoveToPoint(contextRef, fw, fh / 2);
    CGContextAddArcToPoint(contextRef, fw, fh, fw / 2, fh, 1);
    CGContextAddArcToPoint(contextRef, 0, fh, 0, fh / 2, 1);
    CGContextAddArcToPoint(contextRef, 0, 0, fw / 2, 0, 1);
    CGContextAddArcToPoint(contextRef, fw, 0, fw, fh / 2, 1);
    
    CGContextClosePath(contextRef);
    CGContextRestoreGState(contextRef);
}

#pragma mark - 二维码图片嵌入标识图片, 两张图片合并

/**
 *  添加一张图片到二维码里面
 *
 *  @param image    二维码图片
 *  @param icon     需要嵌入的图片
 *  @param iconSize 嵌入图片的大小
 *
 *  @return 新生成的图片
 */
+ (UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withIconSize:(CGSize)iconSize
{
    //图片绘制的上下文
    UIGraphicsBeginImageContext(image.size);
    
    CGFloat widthOfImage = image.size.width;
    CGFloat heightOfImage = image.size.height;
    CGFloat widhtOfIcon = iconSize.width;
    CGFloat heightOfIcon = iconSize.height;
    
    //先绘制image
    [image drawInRect:(CGRect){0, 0, widthOfImage, heightOfImage}];
    
    //然后再其基础上绘制icon
    [icon drawInRect:(CGRect){(widthOfImage - widhtOfIcon) / 2, (heightOfImage - heightOfIcon) / 2, widhtOfIcon, heightOfIcon}];
    
    //获取绘制完成的图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束上下文
    UIGraphicsEndImageContext();
    return img;
}

/**
 *  添加一张图片到二维码里面
 *
 *  @param image 二维码图片
 *  @param icon  需要嵌入的图片
 *  @param scale 比例
 *
 *  @return 新生成的图片
 */
+ (UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withScale:(CGFloat)scale
{
    //图片绘制的上下文
    UIGraphicsBeginImageContext(image.size);
    
    CGFloat widthOfImage = image.size.width;
    
    CGFloat heightOfImage = image.size.height;
    
    CGFloat widthOfIcon = widthOfImage / scale;
    
    CGFloat heightOfIcon = heightOfImage / scale;
    
    //先绘制image
    [image drawInRect:CGRectMake(0, 0, widthOfImage, heightOfImage)];
    
    //然后再其基础上绘制icon
    [icon drawInRect:CGRectMake((widthOfImage - widthOfIcon) / 2, (heightOfImage - heightOfIcon) / 2, widthOfIcon, heightOfIcon)];
    
    //获取绘制完成的图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束上下文
    UIGraphicsEndImageContext();
    
    return img;
}
@end

@implementation UIImage (Video)

/**
 获取某一帧图片
 
 @param videoUrl 视频文件路径
 @param time     时间
 
 @return 这一帧的图片
 */
+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoUrl atTime:(NSTimeInterval)time
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    gen.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    gen.requestedTimeToleranceAfter = kCMTimeZero;
    gen.requestedTimeToleranceBefore = kCMTimeZero;
    CMTime inTime = CMTimeMakeWithSeconds(time, 60);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef imageRef = [gen copyCGImageAtTime:inTime actualTime:&actualTime error:&error];
    if (error) {
        NSLog(@"获取图片帧失败 : %@", error);
        return nil;
    }
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    
    return image;
}

@end

@implementation UIImage (Tool)

/// 获取屏幕截图
///
/// @return 屏幕截图图像
+ (UIImage *)GA_screenShot {
    // 1. 获取到窗口
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 2. 开始上下文
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, 0);
    
    // 3. 将 window 中的内容绘制输出到当前上下文
    [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
    
    // 4. 获取图片
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5. 关闭上下文
    UIGraphicsEndImageContext();
    
    return screenShot;
}

+ (UIImage *)GA_blurImage:(UIImage *)image blur:(CGFloat)blur {
    // 模糊度越界
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    CGImageRef img = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    //从CGImage中获取数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //设置从CGImage获取对象的属性
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL){
        NSLog(@"No pixelbuffer");
    }
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}


@end


