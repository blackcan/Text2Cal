//
//  DateStringParser.h
//  Text2Cal
//
//  Created by Blackcan on 12/5/30.
//  Copyright (c) 2012年 BCTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateStringParser : NSObject
-(id)initWithString:(NSString *)newEvent; //初始化Parser，將傳入的字串開始剖析
-(NSDate *)startDate; //傳回起始日期
-(NSDate *)endDate; //傳回結束日期
-(NSString *)eventName; //傳回事件名稱
@end
