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





- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}



-(void)registRemoteNotificationWithFinishBlock:(nonnull callBack)block
{
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}





@end
