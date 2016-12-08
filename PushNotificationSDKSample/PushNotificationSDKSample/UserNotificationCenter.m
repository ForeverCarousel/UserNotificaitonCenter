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


typedef void(^authCallBack)(BOOL result, id response);


static UserNotificationCenter* manager = nil;

@interface UserNotificationCenter () <UNUserNotificationCenterDelegate>

@property (nonatomic, copy) authCallBack authCallBack;
@property (nonatomic, copy) callBack localNotificationCallback;
@property (nonatomic, copy) callBack remoteNotificationCallback;
@property (nonatomic, strong) LocalNotificationManager* localManager;
@property (nonatomic, strong) RemoteNotificaitonManager* remoteManager;

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
        NSArray* categries = @[
                               @"LocalNotificationCategory0",
                               @"LocalNotificationCategory1",
                               @"LocalNotificationCategory2",
                               @"LocalNotificationCategory3"
                               ];
        [self setCategoriesWithCategoryIdetifiers:categries];
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

-(LocalNotificationManager *)localManager
{
    if (!_localManager) {
        _localManager = [[LocalNotificationManager alloc] init];
    }
    return _localManager;
}

-(RemoteNotificaitonManager *)remoteManager
{
    if (!_remoteManager) {
        _remoteManager = [[RemoteNotificaitonManager alloc] init];
    }
    return _remoteManager;
}
                               
                               
#pragma mark - 注册远程推送



-(void)registRemoteNotificationWithFinishBlock:(nonnull callBack)callBack;
{
    if (version() < 10.0)
    {
        
    }
    else
    {
        
        [self  getAuthorization:^(BOOL result, id reason) {
            if (result && [reason isEqualToString:@"已授权"])
            {
                [self.remoteManager  registRemoteNotificationWithFinishBlock:^(BOOL result, id  _Nullable response) {
                    if (result) {
                        
                    }
                    
                }];
                
            }
            
        }];
    }

}

#pragma mark -  本地推送

- (void)addLocaNotificaitonWithInfo:(nonnull LocalNotificationItem*)item  FinishBlock:(callBack) callBack
{
    if (version() < 10.0) {
        
    }else{
        [self  getAuthorization:^(BOOL result, id reason) {
            if (result) {
                [self.localManager registNotificaitonWithInfo:item FinishBlock:^(BOOL result, id  _Nullable response) {
                    callBack(result,response);
                }];
                
            }
            
        }];
    }
}



#pragma mark -  获取用户权限
-(void)getAuthorization:(authCallBack)block
{
    self.authCallBack = block;
    
    if ([self isNotifyEnable]) {
        self.authCallBack (YES, @"已授权");
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
        __weak typeof (self) weakSelf = self;
        [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //获取用户设置的通知状态 本地和远程都需要获取权限
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined){
                        weakSelf.authCallBack(NO,@"未选择");
                        NSLog(@"未选择");
                    }else if (settings.authorizationStatus == UNAuthorizationStatusDenied){
                        weakSelf.authCallBack(NO,@"未授权");

                        NSLog(@"未授权");

                    }else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized){
                        weakSelf.authCallBack(YES,@"已授权");
                        NSLog(@"已授权");
                    }
                }];
                
            }else{
                weakSelf.authCallBack(NO,error);
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


#pragma mark - 注册category

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
                                     title:@"YKHD定义按钮一"
                                     options:UNNotificationActionOptionAuthenticationRequired];
    
    UNNotificationAction *action2 = [UNNotificationAction
                                     actionWithIdentifier:@"action2"
                                     title:@"启动iPad优酷客户端"
                                     options:UNNotificationActionOptionForeground | UNNotificationActionOptionDestructive];
    
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





-(void) removeLocalNotificaitons
{
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
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

- (void)handleNotificationFromLaunchOption:(NSDictionary *)launchOptions
{
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
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"DeviceToken is : %@",deviceToken);

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"fail to register Error : %@",error.description);
    self.authCallBack(NO,error);


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

-(void)application:(nullable UIApplication *)application didRegisterUserNotificationSettings:(nullable UIUserNotificationSettings *)notificationSettings
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

