//
//  LocalNotificationItem.h
//  PushNotificationSDKSample
//
//  Created by Carouesl on 2016/12/1.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSUInteger, LocalNotificationType) {
    LocalNotificationTypeInterval,      //基于时间戳推送
    LocalNotificationTypeCalendar,      //基于日期周期性推送
    LocalNotificationTypeLocation,      //基于地理位置推送
};

typedef NS_ENUM(NSUInteger, LocalNotificationCategory) {
    LocalNotificationCategory1,
    LocalNotificationCategory2,
    LocalNotificationCategory3,
};



typedef NS_ENUM(NSUInteger, LocationCondation) {
    LocationCondationDefault,           //默认只有进入时推送
    LocationCondationEntry,             //进入指定区域推送
    LocationCondationExit,              //离开指定区域推送
    LocationCondationBoth,              //两种情况都推送
};

@interface LocalNotificationItem : NSObject

@property (nonatomic, assign) LocalNotificationType type; //类型
@property (nonatomic, copy) NSString* title;              //标题
@property (nonatomic, copy) NSString* subTitle;           //副标题
@property (nonatomic, copy) NSString* body;               //内容
@property (nonatomic, copy) NSString* sound;              //推送提示铃声 铃声的文件必须添加到工程内或者在系统Library/Sounds文件夹下 重名的话首选后者路径下的文件
@property (nonatomic, copy) NSString* notificationID;     //通知的ID
@property (nonatomic, assign) BOOL repeat;                //是否重复通知


@property (nonatomic, assign) NSTimeInterval timeInteval; //触发通知的时间 单位为秒最少为60s type = 0 时有效

@property (nonatomic, strong) NSDateComponents* dateComponents; //触发通知的日期  type = 1 时有效

#warning  陈晓龙 这里应该是两个double类型的 暂时先用CGPoint
@property (nonatomic, assign) CGPoint Coordinate2D;       //坐标  type = 2 时有效
@property (nonatomic, assign) CGFloat radius;             //以上述坐标为中心的半径  type = 2 时有效
@property (nonatomic, assign) LocationCondation condation;//推送时机


@end