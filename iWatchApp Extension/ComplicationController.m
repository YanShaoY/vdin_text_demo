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

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionNone);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler([NSDate date]);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler([NSDate dateWithTimeIntervalSinceNow:60*60*24]);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population
- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    
    CLKComplicationTemplate *curTemplate = nil;
    
    if (complication.family == CLKComplicationFamilyUtilitarianLarge)
    {
        CLKComplicationTemplateUtilitarianLargeFlat *template = [CLKComplicationTemplateUtilitarianLargeFlat new];
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Modular"]];
        template.textProvider = [CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:@"点击开门"]];
        curTemplate = template;
    }
    else if (complication.family == CLKComplicationFamilyModularLarge)
    {
        
    }
    
    if (curTemplate)
    {
        CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:curTemplate];
        handler(entry);
    }
    else
    {
        handler(nil);
    }
    
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after to the given date
    handler(nil);
}

#pragma mark - Placeholder Templates

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    // This method will be called once per supported complication, and the results will be cached
    if (complication.family == CLKComplicationFamilyModularLarge)
    {
        CLKComplicationTemplateModularLargeStandardBody *tmp = [CLKComplicationTemplateModularLargeStandardBody new];
        tmp.headerImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Modular"]];
        tmp.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"龙易吉凶时"];
        tmp.body1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"当前时辰：吉"];
        tmp.body2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"下一时辰：凶"];
        handler(nil);
    }
    else if (complication.family == CLKComplicationFamilyUtilitarianLarge)
    {
        CLKComplicationTemplateUtilitarianLargeFlat *tmp = [CLKComplicationTemplateUtilitarianLargeFlat new];
        tmp.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Modular"]];
        tmp.textProvider = [CLKSimpleTextProvider textProviderWithText:@"当前时辰：吉"];
        handler(nil);
    }
    else
    {
        handler(nil);
    }
    
}

//刷新表盘组件数据
- (void)updateComplication
{
    CLKComplicationServer *server = [CLKComplicationServer sharedInstance];
    for (CLKComplication *complication in server.activeComplications)
    {
        [server reloadTimelineForComplication:complication];
    }
}

@end
