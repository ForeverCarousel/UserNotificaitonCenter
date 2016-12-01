//
//  LocalNotificationManager.m
//  PushNotificationSDKSample
//
//  Created by Carouesl on 2016/12/1.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import "LocalNotificationManager.h"
#import <UserNotifications/UserNotifications.h>
#import "LocalNotificationItem.h"
#import <CoreLocation/CoreLocation.h>


@interface LocalNotificationManager()

@property (nonatomic, copy) callBack callBackBlock;

@end


static LocalNotificationManager* manager = nil;

@implementation LocalNotificationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setCategories];
    }
    return self;
}

+(LocalNotificationManager* ) shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self  alloc] init];
    });
    return manager;
}


#pragma mark - 通知类型

-(void)registNotificaitonWithInfo:(LocalNotificationItem *)item FinishBlock:(callBack)callBack
{
    LocalNotificationType type = item.type;
    self.callBackBlock = callBack;
    switch (type) {
        case LocalNotificationTypeInterval:
        {
            [self addNotificationWithTimeIntervalTriggerWithInfo:item];
        }
            break;
        case LocalNotificationTypeCalendar:
        {
            [self addNotificationWithCalendarTriggerWithInfo:item];
        }
            break;
        case LocalNotificationTypeLocation:
        {
            [self addNotificationWithLocationTriggerWithInfo:item];
        }
            break;
            
        default:
            break;
    }
    
}



- (void)addNotificationWithTimeIntervalTriggerWithInfo:(LocalNotificationItem*) item
{
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:item.timeInteval repeats:item.repeat];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:item.notificationID content:[self contentWithInfo:item] trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"添加时间戳定时推送 : %@", error ? [NSString stringWithFormat:@"error : %@", error] : @"success");
        if (!error) {
            self.callBackBlock(YES,nil);
        }else{
            self.callBackBlock(NO,error);
        }
        
    }];
}

- (void)addNotificationWithCalendarTriggerWithInfo:(LocalNotificationItem*) item
{
    
    NSDateComponents *components = item.dateComponents;
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:item.notificationID content:[self contentWithInfo:item] trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"添加周期性定时推送 ：%@", error ? [NSString stringWithFormat:@"error : %@", error] : @"success");
        if (!error) {
            self.callBackBlock(YES,nil);
        }else{
            self.callBackBlock(NO,error);
        }
    }];
}

- (void)addNotificationWithLocationTriggerWithInfo:(LocalNotificationItem*) item
{
    CLLocationCoordinate2D cen = CLLocationCoordinate2DMake(item.Coordinate2D.x,item.Coordinate2D.y);
    CLRegion *region = [[CLCircularRegion alloc] initWithCenter:cen radius:item.radius identifier:item.notificationID];
    region.notifyOnEntry = NO;
    region.notifyOnExit = NO;
    
    if (item.condation ==  LocationCondationEntry) {
        region.notifyOnEntry = YES;
        region.notifyOnExit = NO;
        
    }else if (item.condation == LocationCondationExit){
        region.notifyOnEntry = NO;
        region.notifyOnExit = YES;
    }else if (item.condation == LocationCondationBoth){
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
    }else{
        region.notifyOnEntry = YES;
        region.notifyOnExit = NO;
    }
    
    UNLocationNotificationTrigger *trigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:item.repeat];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:item.notificationID content:[self contentWithInfo:item] trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"添加指定位置推送 ：%@", error ? [NSString stringWithFormat:@"error : %@", error] : @"success");
        if (!error) {
            self.callBackBlock(YES,nil);
        }else{
            self.callBackBlock(NO,error);
        }
    }];
}


-(UNMutableNotificationContent*) contentWithInfo:(LocalNotificationItem*) item
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = item.title;
    content.subtitle = item.subTitle;
    content.body = item.body;
    content.categoryIdentifier = @"1";
    if (item.sound == nil) {
        content.sound = [UNNotificationSound defaultSound];
    }else{
        content.sound = [UNNotificationSound soundNamed:item.sound];
    }
    return content;
}

#pragma mark - 通知类别

- (void)setCategories
{
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"需要解锁" options:UNNotificationActionOptionAuthenticationRequired];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2" title:@"启动app" options:UNNotificationActionOptionForeground];
    //intentIdentifiers，需要填写你想要添加到哪个推送消息的 id
    UNNotificationCategory *category1 = [UNNotificationCategory categoryWithIdentifier:@"category1" actions:@[action1, action2] intentIdentifiers:@[@"1"] options:UNNotificationCategoryOptionNone];
    
    UNNotificationAction *action3 = [UNNotificationAction actionWithIdentifier:@"action3" title:@"红色样式" options:UNNotificationActionOptionDestructive];
    UNNotificationAction *action4 = [UNNotificationAction actionWithIdentifier:@"action4" title:@"红色解锁启动" options:UNNotificationActionOptionAuthenticationRequired | UNNotificationActionOptionDestructive | UNNotificationActionOptionForeground];
    UNNotificationCategory *category2 = [UNNotificationCategory categoryWithIdentifier:@"category2" actions:@[action3, action4] intentIdentifiers:@[@"2"] options:UNNotificationCategoryOptionCustomDismissAction];
    
    UNTextInputNotificationAction *action5 = [UNTextInputNotificationAction actionWithIdentifier:@"action5" title:@"" options:UNNotificationActionOptionForeground textInputButtonTitle:@"回复" textInputPlaceholder:@"写你想写的"];
    UNNotificationCategory *category3 = [UNNotificationCategory categoryWithIdentifier:@"category3" actions:@[action5] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:category1, category2, category3, nil]];
}






-(void)dealloc
{
    
}



@end
