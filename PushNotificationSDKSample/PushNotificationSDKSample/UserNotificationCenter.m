//
//  YoukuHDNotificationCenter.m
//  PushNotificationSDKSample
//
//  Created by Carouesl on 2016/11/29.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import "UserNotificationCenter.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "LocalNotificationItem.h"
#import "LocalNotificationManager.h"
#import "RemoteNotificaitonManager.h"

static UserNotificationCenter* manager = nil;

@interface UserNotificationCenter () <UNUserNotificationCenterDelegate>

@property (nonatomic, copy) callBack localNotificationCallback;
@property (nonatomic, copy) callBack remoteNotificationCallback;

@end



@implementation UserNotificationCenter

static inline CGFloat version (){
    CGFloat version = [[UIDevice currentDevice].systemVersion floatValue];
    return version;
}



- (instancetype)init
{
    self = [super init];
    if (self) {
        
//        [self resetMethodsImplentataion];
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        
    }
    return self;
}

+ (instancetype)defaultCenter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark - 注册推送

-(void)registNotificationsWithFinishBlock:(callBack)block
{
    //暂时
    [LocalNotificationManager shareInstance]; //这里需要借用一下本地通知的category
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
                    if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined)
                    {
                        NSLog(@"未选择");
                    }else if (settings.authorizationStatus == UNAuthorizationStatusDenied){
                        NSLog(@"未授权");
                    }else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized){
                        NSLog(@"已授权");
                    }
                }];
                
                //向APNS注册远程推送
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

#pragma mark -  本地推送

- (void)addLocaNotificaitonWithInfo:(nonnull LocalNotificationItem*)item  FinishBlock:(callBack) callBack
{
    if (version() < 10.0) {
        
    }else{
        [[LocalNotificationManager shareInstance] registNotificaitonWithInfo:item FinishBlock:^(BOOL result, id  _Nullable response) {
            callBack(result,response);
        }];
    }
}



-(void) removeLocalNotificaitons
{
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
}




#pragma mark - 远程推送


-(void)registRemoteNotificationWithFinishBlock:(callBack)block
{
    [[RemoteNotificaitonManager shareInstance]  registRemoteNotificationWithFinishBlock:^(BOOL result, id  _Nullable response) {
        
    }];
}

#pragma mark - User Notification Center Delegate
/*
 willPresentNotification:withCompletionHandler 用于前台运行
 didReceiveNotificationResponse:withCompletionHandler 用于后台及程序退出
 didReceiveRemoteNotification:fetchCompletionHandler用于静默推送
 

 */
// The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    NSLog(@"will prese notification");
    // 展示
    completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
    
    //    // 不展示
    //    completionHandler(UNNotificationPresentationOptionNone);
    
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler
{
    NSLog(@"did receive notification resoponse");
    //现获取是哪个分类 然后再获取这个分类下是哪个action
    if ([response.notification.request.content.categoryIdentifier isEqualToString:@"LocalNotificationCategory1"]) {
        [self handleResponse:response];
    }
    //可以设置当收到通知后, 有哪些效果呈现(声音/提醒/数字角标)
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
//    completionHandler();
}

- (void)handleResponse:(UNNotificationResponse *)response {
    
    NSString *actionIndentifier = response.actionIdentifier;
    
    // 处理留言
    if ([actionIndentifier isEqualToString:@"action2"]) {
        
        UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"点击了第2个按钮" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [a show];
    }

}



#pragma mark - Application Delegate
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    
}














#pragma mark - swizzling methods

-(void)resetMethodsImplentataion
{
    NSArray* originalM = [self originalMethods];
    NSArray* targetM = [self targetMethods];
    for (int i = 0; i< originalM.count ; ++ i)
    {
        SEL original = NSSelectorFromString(originalM[i]);
        SEL target = NSSelectorFromString(targetM[i]);
        [self swizzlingMethod:original withMethod:target];
    }
}

-(NSArray*)originalMethods
{
    NSString* method_a = @"application:didRegisterForRemoteNotificationsWithDeviceToken:";
    NSString* method_b = @"application:didFailToRegisterForRemoteNotificationsWithError:";
    NSString* method_c = @"application:didRegisterUserNotificationSettings:";
    NSString* method_d = @"application:handleActionWithIdentifier:forRemoteNotification:completionHandler:";
    NSArray* methods = @[method_a,method_b,method_c,method_d];
    return methods;
}

-(NSArray*) targetMethods
{
    NSString* method_a = @"ykhd_application:didRegisterForRemoteNotificationsWithDeviceToken:";
    NSString* method_b = @"ykhd_application:didFailToRegisterForRemoteNotificationsWithError:";
    NSString* method_c = @"ykhd_application:didRegisterUserNotificationSettings:";
    NSString* method_d = @"ykhd_application:handleActionWithIdentifier:forRemoteNotification:completionHandler:";
    NSArray* methods = @[method_a,method_b,method_c,method_d];
    return methods;}


-(void)swizzlingMethod:(SEL) original  withMethod:(SEL) target
{
    id AppDelgate = [UIApplication sharedApplication].delegate;
    Method methodOriginal = class_getInstanceMethod([AppDelgate class], original);
    Method methodTarget = class_getInstanceMethod([self class], target);
    IMP original_IMP = method_getImplementation(methodOriginal);
    IMP target_IMP = method_getImplementation(methodTarget);
    method_setImplementation(methodOriginal, target_IMP);
    method_setImplementation(methodTarget, original_IMP);
//    method_exchangeImplementations(methodOriginal, methodTarget);
}





-(void)ykhd_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"YKHD_DeviceToken is : %@",deviceToken);
}

-(void)ykhd_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"YKHD_fail to register Error : %@",error.description);
    
}

-(void)ykhd_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types == UIUserNotificationTypeNone) {
        NSLog(@"YKHD_用户拒绝了推送权限");
    }
    else{
        NSLog(@"YKHD_获得推送权限");
        [application registerForRemoteNotifications];
    }
}


- (void)ykhd_application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}





















@end

