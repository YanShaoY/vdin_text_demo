//
//  GAFileService.m
//  Demo
//
//  Created by YanSY on 2018/5/21.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "GAFileService.h"

@implementation GAFileService

//获取caches 下 User路径 caches/USER/
+ (NSString *)obtainUserDir{
    
    NSString *path = [self cachesObtainDir:@"YanSY"];
    return path;
}

//返回 GA文件夹 路径 caches/USER/GA/  (ps:此文件夹里包含通用产生的图片,文件,视频等)
+ (NSString *)obtainGADir{
    
    NSString *path = [self obtainFolderWithSourceFolderPath:[self obtainUserDir] folderName:@"GA"];
    return  path;
}

+ (NSString *)obtainFolderWithSourceFolderPath:(NSString *)path folderName:(NSString *)name{
    
    NSString *dirPath = [path stringByAppendingPathComponent:name];
    BOOL isDir = NO;
    BOOL isCreated = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
    if (isCreated == NO || isDir == NO) {
        
        NSError* error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if(success == NO)
            NSLog(@"%s--创建文件失败: %@",__FUNCTION__,error.debugDescription);
    }
    
    NSLog(@"%s--%@",__FUNCTION__,dirPath);
    return dirPath;
}

+ (NSString *)cachesObtainDir:(NSString *)dir{
    
    NSArray  * paths     = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * cachePath = [paths objectAtIndex:0];
    NSString * path = [self obtainFolderWithSourceFolderPath:cachePath folderName:dir];
    return path;
}


@end
