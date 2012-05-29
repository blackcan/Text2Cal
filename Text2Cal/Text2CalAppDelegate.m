//
//  Text2CalAppDelegate.m
//  Text2Cal
//
//  Created by blackcan on 12/5/26.
//  Copyright (c) 2012年 BCTech. All rights reserved.
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
    [self setNewEvent:@"6/1/2012~6/2/2012開會"];
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
    dateChanges = [[NSMutableArray alloc] init];

    //若傳入字串不為空則開始處理
    if (newEvent != nil) 
    {
        eventName = newEvent;
        
        //處理yyyy/mm/dd
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=[^0-9]|^)(20|21)?[0-9]{2}[- /.,](0?[1-9]|1[012])[- /.,]([12][0-9]|3[01]|0?[1-9])" options:NSRegularExpressionCaseInsensitive error:NULL];
        NSArray *matches = [regex matchesInString:newEvent options:1 range:NSMakeRange(0, [newEvent length])];
        
        
        for (NSTextCheckingResult *match in matches) 
        {
            NSRange matchRange = [match range];
            NSString *substring = [newEvent substringWithRange:matchRange];
            substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            substring = [substring stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@" " withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@"." withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@"," withString:@"/"];
            
            //將eventName出現的日期資訊刪除
            eventName = [eventName stringByReplacingOccurrencesOfString:substring withString:@""];
                        
            [dateChanges addObject:[NSArray arrayWithObjects:substring, NSStringFromRange(matchRange), nil]];
            
        }
        
        //處理mm/dd/yyyy
        regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=[^0-9]|^)(0?[1-9]|1[012])[- /.,]([12][0-9]|3[01]|0?[1-9])[- /.,](20|21)?[0-9]{2}" options:NSRegularExpressionCaseInsensitive error:NULL];
        matches = [regex matchesInString:newEvent options:1 range:NSMakeRange(0, [newEvent length])];
        
        
        for (NSTextCheckingResult *match in matches) 
        {
            NSRange matchRange = [match range];
            NSString *substring = [newEvent substringWithRange:matchRange];
            substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            substring = [substring stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@" " withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@"." withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@"," withString:@"/"];
            
            //將eventName出現的日期資訊刪除
            eventName = [eventName stringByReplacingOccurrencesOfString:substring withString:@""];
            
            [dateChanges addObject:[NSArray arrayWithObjects:substring, NSStringFromRange(matchRange), nil]];
            
        }
        
        //處理民國yyy/mm/dd
        regex = [NSRegularExpression regularExpressionWithPattern:@"[1|2][0-9]{2}[- /.,](0?[1-9]|1[012])[- /.,]([12][0-9]|3[01]|0?[1-9])" options:NSRegularExpressionCaseInsensitive error:NULL];
        matches = [regex matchesInString:newEvent options:1 range:NSMakeRange(0, [newEvent length])];
        
        
        for (NSTextCheckingResult *match in matches) 
        {
            NSRange matchRange = [match range];
            NSString *substring = [newEvent substringWithRange:matchRange];
            substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            substring = [substring stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@" " withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@"." withString:@"/"];
            substring = [substring stringByReplacingOccurrencesOfString:@"," withString:@"/"];
            
            //將eventName出現的日期資訊刪除
            eventName = [eventName stringByReplacingOccurrencesOfString:substring withString:@""];
            
            //民國年轉成西元年
            NSString *yearString = [substring substringToIndex:3];
            yearString = [NSString stringWithFormat:@"%d", [yearString integerValue] + 1911];
            substring = [NSString stringWithFormat:@"%@%@", yearString, [substring substringFromIndex:3]];
            
            [dateChanges addObject:[NSArray arrayWithObjects:substring, NSStringFromRange(matchRange), nil]];
            
        }
        
        //處理dateChanges
        if ([dateChanges count] == 1) 
        {
            startDate = [NSDate dateWithNaturalLanguageString:[[dateChanges objectAtIndex:0] objectAtIndex:0]];
            endDate = [NSDate dateWithTimeInterval:3600 sinceDate:startDate];
        }
        else if ([dateChanges count] == 2)
        {
            startDate = [NSDate dateWithNaturalLanguageString:[[dateChanges objectAtIndex:0] objectAtIndex:0]];
            endDate = [NSDate dateWithNaturalLanguageString:[[dateChanges objectAtIndex:1] objectAtIndex:0]];
        }
        
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
