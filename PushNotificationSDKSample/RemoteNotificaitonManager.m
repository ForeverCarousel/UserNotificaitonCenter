//
//  RemoteNotificaitonManager.m
//  PushNotificationSDKSample
//
//  Created by Carouesl on 2016/12/1.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import "RemoteNotificaitonManager.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>


static RemoteNotificaitonManager* manager = nil;

@implementation RemoteNotificaitonManager

static inline CGFloat version (){
    CGFloat version = [[UIDevice currentDevice].systemVersion floatValue];
    return version;
}




- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+(RemoteNotificaitonManager* ) shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self  alloc] init];
    });
    return manager;
}

-(void)registRemoteNotificationWithFinishBlock:(callBack)block
{
    if ([self isNotifyEnable]) {
        return;
    }
    
    UIApplication* application = [UIApplication sharedApplication];
    if (version() < 8.0)
    {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    else if(version() >= 8.0 && version() < 10.0)
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
    }
    else if(version() >= 10.0)
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNAuthorizationOptions options = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert;
        [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //获取用户设置的通知状态
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@", settings);
                }];
                
                //向APNS注册
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }else{
                
            }
        }];
    }
    
    
}


//判断用户是否允许推送
-(BOOL)isNotifyEnable
{
    if (version() < 8.0)
    {
        if ([UIApplication sharedApplication].enabledRemoteNotificationTypes  == UIRemoteNotificationTypeNone)
        {
            return NO;
        }
        else
            return YES;
    }
    else if (version() >= 8.0)
    {
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone)
        {
            return NO;
        }
        else
            return YES;
    }
    else
        return NO;
}






@end
