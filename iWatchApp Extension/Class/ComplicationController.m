//
//  ComplicationController.m
//  iWatchApp Extension
//
//  Created by YanSY on 2018/6/25.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "ComplicationController.h"

@interface ComplicationController ()

@end

@implementation ComplicationController

#pragma mark - Timeline Configuration
// 时间前进的方向,如果是回忆的时间轴，可以选CLKComplicationTimeTravelDirectionBackward
- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionNone);
}

/*
 时间轴的起始点，ClockKit回调这个方法获取最早一个时刻，我们在实现中调用hander这个Block来给ClockKit传递那一刻需要展示的数据，
 因为不需要展示过去的数据，这里我们用当前时间.
 */
- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
//    handler([NSDate date]);
    handler(nil);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
//    handler([NSDate dateWithTimeIntervalSinceNow:60*60*24]);
    handler(nil);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population
//获取当前时间的各个表盘组件信息
- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    
    CLKComplicationTemplate * curTemplate = [self createTemplateForComplication:complication];
    if (curTemplate){
        CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:curTemplate];
        handler(entry);
    }else{
        handler(nil);
    }
    
}

//时间旅行，未来时间的组件信息，limit=100，提供的话不要超过这个数量
- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {

    handler(nil);
}

//时间旅行，过去时间的组件信息，limit=100，提供的话不要超过这个数量
- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    
    handler(nil);
}

#pragma mark - Placeholder Templates
//  App第一次启动时，ClockKit会调用这个方法来获取一个complications 模版，作为placeHolder模版展示。可以是假数据，示意即可
- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    
    // 根据提供的表盘类型创建占位符默认显示模板
    CLKComplicationTemplate * curTemplate = [self createTemplateForComplication:complication];
    handler(curTemplate);
    
}


#pragma mark -- 刷新表盘的显示组件数据
- (void)updateComplication{
    
    CLKComplicationServer *server = [CLKComplicationServer sharedInstance];
    
    for (CLKComplication * complication in server.activeComplications){
        
        [server reloadTimelineForComplication:complication];
    }
    
}

#pragma mark -- 创建对应表盘类型的显示组件模板
- (CLKComplicationTemplate *)createTemplateForComplication:(CLKComplication *)complication{
    
    CLKComplicationTemplate *curTemplate = nil;
    switch (complication.family) {
        case CLKComplicationFamilyModularSmall:{
            
            CLKComplicationTemplateModularSmallSimpleImage * template = [[CLKComplicationTemplateModularSmallSimpleImage alloc]init];
            UIImage * IMG = [UIImage imageNamed:@"ModularSmallSimpleImage"];
            CLKImageProvider * providerImg = [CLKImageProvider imageProviderWithOnePieceImage:IMG];
            providerImg.tintColor = [UIColor colorWithRed:0.22 green:0.93 blue:0.24 alpha:1.00];
            template.imageProvider = providerImg;
            curTemplate = template;
        }
            break;
             
        case CLKComplicationFamilyModularLarge:{
             
            CLKComplicationTemplateModularLargeStandardBody * template = [[CLKComplicationTemplateModularLargeStandardBody alloc]init];
            
            CLKSimpleTextProvider * headerText = [CLKSimpleTextProvider textProviderWithText:@"公司门禁" shortText:@"门禁"];
            headerText.tintColor = [UIColor colorWithRed:0.23 green:0.40 blue:1.00 alpha:1.00];
            template.headerTextProvider = headerText;
            
            CLKSimpleTextProvider * body1Text = [CLKSimpleTextProvider textProviderWithText:@"点击进入门禁APP" shortText:@"点击进入"];
            body1Text.tintColor = [UIColor colorWithRed:1.00 green:0.97 blue:0.30 alpha:1.00];
            template.body1TextProvider = body1Text;
            
            CLKSimpleTextProvider * body2Text = [CLKSimpleTextProvider textProviderWithText:@"APP开门准备工作已就绪" shortText:@"准备就绪"];
            body2Text.tintColor = [UIColor colorWithRed:0.22 green:0.93 blue:0.24 alpha:1.00];
            template.body2TextProvider = body2Text;
            
            UIImage * IMG = [UIImage imageNamed:@"ModularLargeStandardBody"];
            CLKImageProvider * providerImg = [CLKImageProvider imageProviderWithOnePieceImage:IMG];
            providerImg.tintColor = [UIColor colorWithRed:0.22 green:0.93 blue:0.24 alpha:1.00];
            template.headerImageProvider = providerImg;
            
            curTemplate = template;

        }
            break;
            
        case CLKComplicationFamilyUtilitarianSmall:{
            
            CLKComplicationTemplateUtilitarianSmallSquare * template = [[CLKComplicationTemplateUtilitarianSmallSquare alloc]init];
            
            UIImage * IMG = [UIImage imageNamed:@"UtilitarianSmallSquare"];
            CLKImageProvider * providerImg = [CLKImageProvider imageProviderWithOnePieceImage:IMG];
            providerImg.tintColor = [UIColor colorWithRed:0.22 green:0.93 blue:0.24 alpha:1.00];
            template.imageProvider = providerImg;
            
            curTemplate = template;
        }
            break;
         
        case CLKComplicationFamilyUtilitarianSmallFlat:{
            
            CLKComplicationTemplateUtilitarianSmallFlat * template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc]init];
            
            CLKSimpleTextProvider * providerText = [CLKSimpleTextProvider textProviderWithText:@"公司门禁" shortText:@"门禁"];
            providerText.tintColor = [UIColor colorWithRed:0.23 green:0.40 blue:1.00 alpha:1.00];
            template.textProvider = providerText;
            
            UIImage * IMG = [UIImage imageNamed:@"UtilitarianSmallFlat"];
            CLKImageProvider * providerImg = [CLKImageProvider imageProviderWithOnePieceImage:IMG];
            providerImg.tintColor = [UIColor colorWithRed:0.22 green:0.93 blue:0.24 alpha:1.00];
            template.imageProvider = providerImg;
            
            curTemplate = template;

        }
            break;
            
        case CLKComplicationFamilyUtilitarianLarge:
        {
            CLKComplicationTemplateUtilitarianLargeFlat * template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc]init];
            
            CLKSimpleTextProvider * providerText = [CLKSimpleTextProvider textProviderWithText:@"公司门禁" shortText:@"门禁"];
            providerText.tintColor = [UIColor colorWithRed:0.23 green:0.40 blue:1.00 alpha:1.00];
            template.textProvider = providerText;
            
            UIImage * IMG = [UIImage imageNamed:@"UtilitarianLargeFlat"];
            CLKImageProvider * providerImg = [CLKImageProvider imageProviderWithOnePieceImage:IMG];
            providerImg.tintColor = [UIColor colorWithRed:0.22 green:0.93 blue:0.24 alpha:1.00];
            template.imageProvider = providerImg;
            
            curTemplate = template;

        }
            break;
            
        case CLKComplicationFamilyCircularSmall:{
            
            CLKComplicationTemplateCircularSmallSimpleImage * template = [[CLKComplicationTemplateCircularSmallSimpleImage alloc]init];
            
            UIImage * IMG = [UIImage imageNamed:@"CircularSmallSimpleImage"];
            CLKImageProvider * providerImg = [CLKImageProvider imageProviderWithOnePieceImage:IMG];
            providerImg.tintColor = [UIColor colorWithRed:0.22 green:0.93 blue:0.24 alpha:1.00];
            template.imageProvider = providerImg;
            
            curTemplate = template;
        }
            
            break;
            
        case CLKComplicationFamilyExtraLarge:{
            
            CLKComplicationTemplateExtraLargeSimpleImage * template = [[CLKComplicationTemplateExtraLargeSimpleImage alloc]init];
            
            UIImage * IMG = [UIImage imageNamed:@"ExtraLargeSimpleImage"];
            CLKImageProvider * providerImg = [CLKImageProvider imageProviderWithOnePieceImage:IMG];
            providerImg.tintColor = [UIColor colorWithRed:0.22 green:0.93 blue:0.24 alpha:1.00];
            template.imageProvider = providerImg;
            
            curTemplate = template;
        }
            
            break;
            
        default:
            break;
    }
        return curTemplate;
}

@end










