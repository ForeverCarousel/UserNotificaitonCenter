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
@property (nonatomic, strong) NSArray* categries;
@end


static LocalNotificationManager* manager = nil;

@implementation LocalNotificationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.categries = @[@"LocalNotificationCategory0",@"LocalNotificationCategory1",@"LocalNotificationCategory2",@"LocalNotificationCategory3"];
        [self setCategoriesWithCategoryIdetifiers:_categries];
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
            path = [[NSBundle mainBundle] pathForResource:@"陈奕迅-K歌之王" ofType:@"mp4"];
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

#pragma mark - 通知类别

- (void)setCategoriesWithCategoryIdetifiers:(NSArray*)categories
{
    /* action options
     identifier：行为标识符，用于调用代理方法时识别是哪种行为。
     title：行为名称。
     以下可以组合配置
     UNNotificationActionOptionAuthenticationRequired = (1 << 0), 是否需要解锁
     UNNotificationActionOptionDestructive = (1 << 1),            是否显示为红色
     UNNotificationActionOptionForeground = (1 << 2),             是否启动App
     behavior：点击按钮文字输入，是否弹出键盘
    */
    
    /* category options
     UNNotificationCategoryOptionNone = (0), 关掉通知时不通知代理方法
     UNNotificationCategoryOptionCustomDismissAction = (1 << 0),关掉通知时需要通知代理方法

     */
    UNNotificationAction *action1 = [UNNotificationAction
                      actionWithIdentifier:@"action1"
                                     title:@"需要解锁"
                                   options:UNNotificationActionOptionAuthenticationRequired];
    
    UNNotificationAction *action2 = [UNNotificationAction
                      actionWithIdentifier:@"action2"
                                     title:@"启动app"
                                    options:UNNotificationActionOptionForeground];
    
    //intentIdentifiers，需要填写你想要添加到哪个推送消息的 id
    UNNotificationCategory *category1 = [UNNotificationCategory
                            categoryWithIdentifier:categories[1]
                                           actions:@[action1, action2]
                                 intentIdentifiers:@[]
                                           options:UNNotificationCategoryOptionNone];
    
    
    
    
    UNNotificationAction *action3 = [UNNotificationAction
                      actionWithIdentifier:@"action3"
                                     title:@"红色样式不启动App"
                                   options:UNNotificationActionOptionDestructive];
    
    UNNotificationAction *action4 = [UNNotificationAction
                      actionWithIdentifier:@"action4"
                                     title:@"红色解锁启动"
                                     options:UNNotificationActionOptionAuthenticationRequired | UNNotificationActionOptionDestructive | UNNotificationActionOptionForeground];
    
    UNNotificationCategory *category2 = [UNNotificationCategory
                          categoryWithIdentifier:categories[2]
                                         actions:@[action3, action4]
                               intentIdentifiers:@[]
                                         options:UNNotificationCategoryOptionCustomDismissAction];
    
    
    
    
    UNTextInputNotificationAction *action5 = [UNTextInputNotificationAction
                               actionWithIdentifier:@"action5"
                                              title:@""
                                            options:UNNotificationActionOptionForeground
                               textInputButtonTitle:@"发送吧"
                               textInputPlaceholder:@"输入回复内容"];
    
    UNNotificationCategory *category3 = [UNNotificationCategory
                             categoryWithIdentifier:categories[3]
                                            actions:@[action5]
                                  intentIdentifiers:@[]
                                            options:UNNotificationCategoryOptionCustomDismissAction];
    
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:category1, category2, category3, nil]];
}






-(void)dealloc
{
    
}



@end
