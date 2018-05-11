//
//  BaseModel.m
//  Demo
//
//  Created by YanSY on 2017/12/20.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel
- (NSString *)description
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    uint count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        id value = [self valueForKey:name]?:@"nil";
        [dictionary setObject:value forKey:name];
    }
    
    free(properties);
    return [NSString stringWithFormat:@"<%@:%p> -- %@", [self class], self, dictionary];
    
}

- (NSString *)debugDescription
{
    if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSDictionary class]] || [self isKindOfClass:[NSNumber class]] || [self isKindOfClass:[NSString class]])
    {
        return self.debugDescription;
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    uint count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        id value = [self valueForKey:name]?:@"nil"; // 默认值为nil字符串
        [dictionary setObject:value forKey:name];
    }
    free(properties);
    return [NSString stringWithFormat:@"<%@: %p> -- \n%@", [self class], self, dictionary];
}

@end
