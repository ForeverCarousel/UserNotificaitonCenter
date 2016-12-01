//
//  AppDelegate.m
//  PushNotificationSDKSample
//
//  Created by Carouesl on 2016/11/29.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import "AppDelegate.h"
#import "UserNotificationCenter.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()
@property (nonatomic, copy) void (^contentHandler)(UNNotificationContent *contentToDeliver);

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UserNotificationCenter defaultCenter] registRemoteNotificationWithFinishBlock:^(BOOL result, id  _Nullable response) {
        
    }];
    
    
    NSDictionary* userinfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userinfo)
    {
        UIAlertView* a = [[UIAlertView alloc] initWithTitle:@"有需要处理的推送内容" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [a show];
        NSLog(@"有需要处理的推送内容");
    }
    else
    {
        UIAlertView* a = [[UIAlertView alloc] initWithTitle:@"没有需要处理的推送内容" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [a show];
        NSLog(@"没有需要处理的推送内容");
    }
    return YES;
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"DeviceToken is : %@",deviceToken);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"fail to register Error : %@",error.description);

}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types == UIUserNotificationTypeNone) {
        NSLog(@"用户拒绝了推送权限");
    }
    else{
        NSLog(@"获得推送权限");
        [application registerForRemoteNotifications];
    }
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}



//Implement the application:didReceiveRemoteNotification:fetchCompletionHandler: method instead of this one whenever possible. If your delegate implements both methods, the app object calls the application:didReceiveRemoteNotification:fetchCompletionHandler: method.
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    if (application.applicationState == UIApplicationStateActive) {
        UIAlertView* a = [[UIAlertView alloc] initWithTitle:@"前台状态：获取到推送内容" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [a show];
    }
    else if(application.applicationState == UIApplicationStateInactive)
    {
        UIAlertView* a = [[UIAlertView alloc] initWithTitle:@"后台状态：获取到推送内容" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [a show];
        
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
