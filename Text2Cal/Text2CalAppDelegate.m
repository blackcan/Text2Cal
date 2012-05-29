//
//  Text2CalAppDelegate.m
//  Text2Cal
//
//  Created by 罐頭 on 12/5/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Text2CalAppDelegate.h"
#import "iCal.h"

@implementation NSApplication (Text2CalApp)
NSDate *startDate;
NSDate *endDate;
NSString *eventName;
NSString *eventPlace;
NSInteger startYear;
NSInteger startMonth;
NSInteger startDay;
NSInteger startHour;
NSInteger startMinute;
NSInteger endYear;
NSInteger endMonth;
NSInteger endDay;
NSInteger endHour;
NSInteger endMinute;
NSMutableArray *dateChanges;

//測試用
-(void) awakeFromNib
{
    [self setNewEvent:@"2012/5/29  2012/5/30開會"];
}

-(NSString*) newEvent
{
    return @"";
}

//新增事件
-(void) setNewEvent:(NSString *)newEvent
{
    //初始化
    startDate = [NSDate date];
    endDate = [NSDate dateWithTimeIntervalSinceNow:3600];
    eventName = @"New Event";
    eventPlace = @"";
    
//    //取得使用者目前日期時間物件
//    NSCalendar *usersCalendar =
//    [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
//    
//    //設定DataComponent要存哪些項目（年月日...）
//    NSInteger unitFlags = NSYearCalendarUnit | 
//    NSMonthCalendarUnit |
//    NSWeekdayCalendarUnit |
//    NSDayCalendarUnit |  
//    NSHourCalendarUnit |
//    NSMinuteCalendarUnit;
//    
//    //宣告DateComponent
//    NSDateComponents *comps = [usersCalendar components:unitFlags fromDate:startDate];
//    
//    //取得起始日期時間細項
//    startYear = [comps year];
//    startMonth = [comps month];
//    startDay = [comps day];
//    startHour = [comps hour];
//    startMinute = 0;
    
    
    
    dateChanges = [[NSMutableArray alloc] init];

    //若傳入字串不為空則開始處理
    if (newEvent != nil) 
    {
        eventName = newEvent;
        
        //處理yyyy/mm/dd
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(20|21)?[0-9]{2}[- /.,](0?[1-9]|1[012])[- /.,]([12][0-9]|3[01]|0?[1-9])" options:NSRegularExpressionCaseInsensitive error:NULL];
        NSArray *matches = [regex matchesInString:newEvent options:1 range:NSMakeRange(0, [newEvent length])];
        
        
        for (NSTextCheckingResult *match in matches) 
        {
            NSRange matchRange = [match range];
            NSString *substring = [newEvent substringWithRange:matchRange];
            substring = [substring stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@" " withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@"." withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@"," withString:@"/"];
            NSDate *date = [NSDate dateWithNaturalLanguageString:substring];
                        
            [dateChanges addObject:[NSArray arrayWithObjects:date, NSStringFromRange(matchRange), nil]];
            
            eventName = [eventName stringByReplacingOccurrencesOfString:substring withString:@""];
            
        }
        
//        NSRange range;
//        NSInteger stringIndex;
        
//        //字串有"明天"
//        range = [newEvent rangeOfString:@"明天"];
//        stringIndex = range.location;
//        if (stringIndex != NSNotFound) 
//        {
//            startDay = startDay + 1;
//            eventName = [eventName stringByReplacingOccurrencesOfString:@"明天" withString:@""];
//        }
//        
//        range = [newEvent rangeOfString:@"一點"];
//        stringIndex = range.location;
//        if (stringIndex != NSNotFound) 
//        {
//            startHour = 1;
//            eventName = [eventName stringByReplacingOccurrencesOfString:@"一點" withString:@""];
//        }
//        
//        //字串有"下午"
//        range = [newEvent rangeOfString:@"下午"];
//        stringIndex = range.location;
//        if (stringIndex != NSNotFound) 
//        {
//            if (startHour < 12) 
//            {
//                startHour = startHour + 12;
//            }
//            eventName = [eventName stringByReplacingOccurrencesOfString:@"下午" withString:@""];
//        }
//        
//        //設定結束時間
//        endYear = startYear;
//        endMonth = startMonth;
//        endDay = startDay;
//        endHour = startHour + 1;
//        endMinute = startMinute;
//        
//        //將日期細項轉換為Date物件
//        NSDateComponents *comps = [[NSDateComponents alloc] init];
//        [comps setYear:startYear];
//        [comps setMonth:startMonth];
//        [comps setDay:startDay];
//        [comps setHour:startHour];
//        [comps setMinute:startMinute];
        
//        NSCalendar *usersCalendar =
//        [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
//        startDate = [usersCalendar dateFromComponents:comps];
//        
//        [comps setYear:endYear];
//        [comps setMonth:endMonth];
//        [comps setDay:endDay];
//        [comps setHour:endHour];
//        [comps setMinute:endMinute];
//        endDate = [usersCalendar dateFromComponents:comps];
        
        
        //處理dateChanges
        startDate = [[dateChanges objectAtIndex:0] objectAtIndex:0];
        endDate = [[dateChanges objectAtIndex:1] objectAtIndex:0];
        
        //新增事件
        iCalApplication *iCal;
        iCal = [SBApplication applicationWithBundleIdentifier:@"com.apple.iCal"];
        [iCal activate];
        iCalCalendar *theCalendar = nil;
        NSString *calendarName = @"行事曆";
        
        //找尋名字相同的calendar
        NSArray *matchingCalendars =
        [[iCal calendars] filteredArrayUsingPredicate:
         [NSPredicate predicateWithFormat:@"name == %@", calendarName]];
        if ( [matchingCalendars count] > 0 )
        {
            theCalendar = (iCalCalendar *) [matchingCalendars objectAtIndex:0];
        }
        
        iCalEvent *theEvent;
        NSDictionary *props = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         eventName, @"summary",
         startDate, @"startDate",
         endDate, @"endDate",
         nil];
        
        theEvent = [[[iCal classForScriptingClass:@"event"] alloc] initWithProperties: props];
        [[theCalendar events] addObject: theEvent];
        [theEvent show];
    }
}

@end
