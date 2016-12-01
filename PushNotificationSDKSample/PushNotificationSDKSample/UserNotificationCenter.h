//
//  YoukuHDNotificationCenter.h
//  PushNotificationSDKSample
//
//  Created by Carouesl on 2016/11/29.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalNotificationItem.h"
//@class LocalNotificationItem;

typedef void(^callBack)(BOOL result , _Nullable id response);

@interface UserNotificationCenter : NSObject

+ (UserNotificationCenter* )defaultCenter;


#pragma mark - 本地通知

/**
 注册本地通知

 @param item 推送类型 支持枚举列举的类型 版本需求高于iOS 10.0
 @param callBack 返回结果
 */
- (void)registLocaNotificaitonWithInfo:(nonnull LocalNotificationItem*)item  FinishBlock:(callBack) callBack;





#pragma mark - 远程通知

/**
 注册远程通知
 
 @param block 返回结果
 */
- (void)registRemoteNotificationWithFinishBlock:(callBack) block;









@end
