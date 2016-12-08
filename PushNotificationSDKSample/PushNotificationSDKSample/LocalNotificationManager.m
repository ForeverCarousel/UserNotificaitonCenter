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
@property (nonatomic, strong) NSMutableArray* categries;
@end


static LocalNotificationManager* manager = nil;

@implementation LocalNotificationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak typeof (self) weakSelf = self;
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> * _Nonnull categories) {
            self.categries  = [NSMutableArray array];
            for (UNNotificationCategory* category in categories) {
                [weakSelf.categries addObject:category.identifier];
            }
            [weakSelf.categries insertObject:@"LocalNotificationCategory0" atIndex:0]; //添加上默认类型
        }];
    
    }
    return self;
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
    
    UNNotificationContent * content = [self creatContentWithInfo:item];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:item.notificationID content:content trigger:trigger];

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
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:item.notificationID content:[self creatContentWithInfo:item] trigger:trigger];
    
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
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:item.notificationID content:[self creatContentWithInfo:item] trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"添加指定位置推送 ：%@", error ? [NSString stringWithFormat:@"error : %@", error] : @"success");
        if (!error) {
            self.callBackBlock(YES,nil);
        }else{
            self.callBackBlock(NO,error);
        }
    }];
}


-(UNMutableNotificationContent*) creatContentWithInfo:(LocalNotificationItem*) item
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = item.title;
    content.subtitle = item.subTitle;
    content.body = item.body;
    if (item.sound == nil) {
        content.sound = [UNNotificationSound defaultSound];
    }else{
        content.sound = [UNNotificationSound soundNamed:item.sound];
    }
    content.categoryIdentifier = self.categries[item.category];
    content.attachments = [self attachmentByType:item.attachmentType];
    return content;
}


- (NSArray*)attachmentByType:(LocalNotificationAttachmentType)type
{
    NSString *contentString = @"";
    NSString *path = @"";
    switch (type) {
        case NotificationAttachmentTypeImage:
            contentString = @"附件-图片";
            path = [[NSBundle mainBundle] pathForResource:@"attachment" ofType:@"png"];
            break;
            
        case NotificationAttachmentTypeImageGif:
            contentString = @"附件-图片-GIF";
            path = [[NSBundle mainBundle] pathForResource:@"eason" ofType:@"gif"];
            break;
            
        case NotificationAttachmentTypeAudio:
            contentString = @"附件-音频";
            path = [[NSBundle mainBundle] pathForResource:@"张智霖 - 少女的祈祷" ofType:@"mp3"];
            break;
            
        case NotificationAttachmentTypeMovie:
            contentString = @"附件-视频";
            path = [[NSBundle mainBundle] pathForResource:@"陈奕迅-人来人往" ofType:@"mp4"];
            break;
            
        default:
            break;
    }
    
    NSError *error = nil;
    /*    Attachment 不能超过大小限制
    Supported   File Types                            Maximum Size
    Audio       kUTTypeAudioInterchangeFileFormat     5 MB
    Image       kUTTypeJPEG                           10 MB
    Movie       kUTTypeMPEG                           50 MB
     */
    //这里url必须是file url。
    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"atta1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
    if (error) {
        NSLog(@"attachment error : %@", error);
    }
    if (attachment) {
        return @[attachment];
    }
    return nil;
    
}







-(void)dealloc
{
    
}



@end
