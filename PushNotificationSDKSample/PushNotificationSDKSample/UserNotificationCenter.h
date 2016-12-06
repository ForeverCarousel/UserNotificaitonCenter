//
//  YoukuHDNotificationCenter.h
//  PushNotificationSDKSample
//
//  Created by Carouesl on 2016/11/29.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalNotificationItem.h"
#import <UIKit/UIKit.h>
//@class LocalNotificationItem;

typedef void(^callBack)(BOOL result , _Nullable id response);

@interface UserNotificationCenter : NSObject

+ (nonnull UserNotificationCenter*)defaultCenter;
-(void)registNotificationsWithFinishBlock:(nonnull callBack)block;





#pragma mark - 本地通知

/**
 注册本地通知

 @param item 推送类型 支持枚举列举的类型 版本需求高于iOS 10.0
 @param callBack 返回结果
 */
- (void)addLocaNotificaitonWithInfo:(nonnull LocalNotificationItem*)item  FinishBlock:(nonnull callBack) callBack;

-(void) removeLocalNotificaitons;


#pragma mark - 远程通知



#pragma mark  AppDelegate

- (void)application:(nullable UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken;

- (void)application:(nullable UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nullable NSError *)error;

- (void)application:(nullable UIApplication *)application didReceiveRemoteNotification:(nullable NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult result))completionHandler;





@end
