//
//  DateStringParser.m
//  Text2Cal
//
//  Created by Blackcan on 12/5/30.
//  Copyright (c) 2012年 BCTech. All rights reserved.
//

#import "DateStringParser.h"

@implementation DateStringParser

NSDate *startDate;
NSDate *endDate;
NSString *eventName;

-(NSDate *)startDate
{
    return startDate;
}
-(NSDate *)endDate
{
    return endDate;
}
-(NSString *)eventName
{
    return eventName;
}
-(id)initWithString:(NSString *)newEvent
{
    NSMutableArray *dateChanges = [[NSMutableArray alloc] init];
    eventName = newEvent;
    startDate = [NSDate date];
    endDate = [NSDate dateWithTimeIntervalSinceNow:3600];
    
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
    return self;
}
@end
