//
//  Text2CalAppDelegate.m
//  Text2Cal
//
//  Created by blackcan on 2012/5/26.
//  Copyright (c) 2012年 BCTech. All rights reserved.
//

#import "Text2CalAppDelegate.h"
#import "DateStringParser.h"
#import "iCal.h"

@implementation NSApplication (Text2CalApp)

//測試用
-(void) awakeFromNib
{
    [self setNewEvent:@"後天開會"];
}

-(NSString*) newEvent
{
    return @"";
}

//新增事件
-(void) setNewEvent:(NSString *)newEvent
{
    //若傳入字串不為空則開始處理
    if (newEvent != nil) 
    {        
        DateStringParser *dateStringParser = [[DateStringParser alloc] initWithString:newEvent];
        
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
        
        //建立事件
        iCalEvent *theEvent;
        NSDictionary *props = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         [dateStringParser eventName], @"summary",
         [dateStringParser startDate], @"startDate",
         [dateStringParser endDate], @"endDate",
         nil];
        
        //新增事件
        theEvent = [[[iCal classForScriptingClass:@"event"] alloc] initWithProperties: props];
        [[theCalendar events] addObject: theEvent];
        [theEvent show];
    }
}

@end
