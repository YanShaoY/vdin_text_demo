//
//  TakingFacePictures.m
//  Demo
//
//  Created by YanSY on 2017/11/23.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "TakingFacePicturesView.h"
#import <AVFoundation/AVFoundation.h>

@interface TakingFacePicturesView() <AVCaptureVideoDataOutputSampleBufferDelegate>{
    
    NSTimer * faceIntervalTimer;
    UIImage * largeImage;
}

#pragma mark -- 定义变量
/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/**
 *  硬件设备
 */
@property (nonatomic, strong) AVCaptureDevice *device;
/**
 *  预览层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
/**
 *  输出流
 */
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@end

@implementation TakingFacePicturesView
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.frame = KEYWINDOW.bounds;
        [self configuration];
        self.clipsToBounds = YES;
        [self.layer addSublayer:self.previewLayer];
        [self.session startRunning];
        // 每隔两秒执行一次回调
        faceIntervalTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(timerIntervalMethod) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:faceIntervalTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop mainRunLoop] addTimer:faceIntervalTimer forMode: UITrackingRunLoopMode];
        
    }
    return self;
}

#pragma mark -- 开始和结束拍照
- (void)startRunningSession{
    
    if (self.session != nil && !self.session.isRunning) {
        [self.session startRunning];
    }
    
    if (![faceIntervalTimer isValid]) {
        [faceIntervalTimer setFireDate:[NSDate distantPast]];
    }
}

- (void)stopRunningSession{
    
    if (self.session != nil && self.session.isRunning) {
        [self.session stopRunning];
    }
    
    if ([faceIntervalTimer isValid]) {
        //关闭定时器
        [faceIntervalTimer setFireDate:[NSDate distantFuture]];
    }
}

#pragma mark -- 掌握时间就掌握了一切
- (void)timerIntervalMethod{
    
    UIImage * countImg = largeImage;
    UIImage * directionImage = [countImg fixImageOrientation];

    UIImage * readyImage = [directionImage imageCompressionProcessingForTargetSize:KEYWINDOW.bounds.size];
//    CGFloat X = 30;
//    CGFloat Y = 40;
//    CGFloat Width = SCREENWIDTH - X*2;
//    CGFloat Height= Width+40;

//    UIImage * faceImage =  [readyImage cutImageForRect:CGRectMake(X, Y, Width, Height)];
//    NSLog(@"faceImage====%f****%f",faceImage.size.width,faceImage.size.height);

    NSUInteger faceCount =[readyImage totalNumberOfFacesByFaceRecognition];
    if (faceCount) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(BackIdentifyFaceImage:)]) {
            [self.delegate BackIdentifyFaceImage:readyImage];
        }
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    // 001 设置图像方向，否则largeImage取出来是反的
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    largeImage  = [self imageFromSampleBuffer:sampleBuffer];
}

#pragma mark -- CMSampleBufferRef转NSImage
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    CGContextRelease(context); CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    CGImageRelease(quartzImage);
    return (image);
}

#pragma mark -- 初始化配置
- (void)configuration{
    
    // 闪光灯
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        if ([self.device hasTorch] && [self.device hasFlash]){
            [self.device lockForConfiguration:nil];
            [self.device setTorchMode:AVCaptureTorchModeAuto];
            [self.device unlockForConfiguration];
        }
    }
    
    // 前置摄像头
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices ){
        if ( device.position == AVCaptureDevicePositionFront ) {
            newCamera = device;
        }
    }
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    if (newInput != nil) {
        [self.session beginConfiguration];
        [self.session removeInput:self.input];
        
        if ([self.session canAddInput:newInput]) {
            [self.session addInput:newInput];
            self.input = newInput;
        }else {
            [self.session addInput:self.input];
        }
        [self.session commitConfiguration];
    }
    
}

#pragma mark -- 懒加载 设备
- (AVCaptureDevice *)device{
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([_device lockForConfiguration:nil]) {
            //自动闪光灯
            if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [_device setFlashMode:AVCaptureFlashModeAuto];
            }
            //自动白平衡
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            }
            //自动对焦
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            //自动曝光
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [_device unlockForConfiguration];
        }
    }
    return _device;
}

#pragma mark -- 懒加载 输入
- (AVCaptureDeviceInput *)input{
    if (_input == nil) {
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    }
    return _input;
}

#pragma mark -- 懒加载 视频输出
- (AVCaptureVideoDataOutput *)videoDataOutput{
    if (_videoDataOutput == nil) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        [_videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    }
    return _videoDataOutput;
}

#pragma mark -- 懒加载 输入输出中介 session
- (AVCaptureSession *)session{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canAddInput:self.input]) {
            [_session addInput:self.input];
        }
        if ([_session canAddOutput:self.videoDataOutput]) {
            [_session addOutput:self.videoDataOutput];
        }
    }
    return _session;
}

#pragma mark -- 懒加载预览视图
-(AVCaptureVideoPreviewLayer *)previewLayer{
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        CGFloat X = 36;
        CGFloat Y = 75;
        CGFloat Width = SCREENWIDTH - X*2;
        CGFloat Height= Width;
        
//        _previewLayer.frame = KEYWINDOW.bounds;
        _previewLayer.frame = CGRectMake(X, Y, Width, Height);
        _previewLayer.masksToBounds = YES;
        _previewLayer.cornerRadius = Width/2;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

#pragma mark -- 注销时结束获取
- (void)removeFromSuperview{
    [super removeFromSuperview];
    if ([faceIntervalTimer isValid]) {
        [faceIntervalTimer invalidate];
    }
    faceIntervalTimer = nil;
    
}

- (void)dealloc{
    
    if (self.session != nil && self.session.isRunning) {
        [self.session stopRunning];
    }
    
    if ([faceIntervalTimer isValid]) {
        [faceIntervalTimer invalidate];
    }
    faceIntervalTimer = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
 
 
*/

@end
