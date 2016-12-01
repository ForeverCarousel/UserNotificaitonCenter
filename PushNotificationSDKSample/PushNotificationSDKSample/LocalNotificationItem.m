//
//  LocalNotificationItem.m
//  PushNotificationSDKSample
//
//  Created by Carouesl on 2016/12/1.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import "LocalNotificationItem.h"
#import <objc/runtime.h>


@implementation LocalNotificationItem


- (instancetype)init
{
    self = [super init];
    if (self) {
        //设置一些缺省值
        _condation = LocationCondationDefault;
        _repeat = NO;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        _notificationID = strDate;
    }
    return self;
}

-(void)setTimeInteval:(NSTimeInterval)timeInteval
{
    if (timeInteval < 60) {
        _timeInteval  = 60;
    }
}

-(void)setSound:(NSString *)sound
{
    NSString *valuedSound = [sound stringByReplacingOccurrencesOfString:@" " withString:@""];
    _sound = valuedSound;
}

-(NSString *)description
{
    unsigned int count = 0;
    objc_property_t*  properties =  class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; ++ i) {
        objc_property_t pt =properties[i];
        const char* name = property_getName(pt);
        NSString* key = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
        NSString* value = [self valueForKey:key];
        NSLog(@"%@ = %@",key,value);
    }
    return nil;
}

@end

