//
//  GAFileService.h
//  Demo
//
//  Created by YanSY on 2018/5/21.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAFileService : NSObject

//返回 GA文件夹 路径 caches/USER/GA/  (ps:此文件夹里包含通用产生的图片,文件,视频等)
+ (NSString *)obtainGADir;

//在某个文件夹下面建一个文件夹
+ (NSString *)obtainFolderWithSourceFolderPath:(NSString *)path folderName:(NSString *)name;

@end
