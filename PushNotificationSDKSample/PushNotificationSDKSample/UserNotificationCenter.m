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
#import "localnotificationManager.h"
#import "RemoteNotificaitonManager.h"

static UserNotificationCenter* manager = nil;

@interface UserNotificationCenter ()

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




#pragma mark -  本地推送

- (void)registLocaNotificaitonWithInfo:(nonnull LocalNotificationItem*)item  FinishBlock:(callBack) callBack
{
    if (version() < 10.0) {
        
    }else{
        [[LocalNotificationManager shareInstance] registNotificaitonWithInfo:item FinishBlock:^(BOOL result, id  _Nullable response) {
            callBack(result,response);
        }];
    }
}








#pragma mark - 远程推送


-(void)registRemoteNotificationWithFinishBlock:(callBack)block
{
    [[RemoteNotificaitonManager shareInstance]  registRemoteNotificationWithFinishBlock:^(BOOL result, id  _Nullable response) {
        
    }];
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

