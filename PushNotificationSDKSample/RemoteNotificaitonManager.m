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








@end
