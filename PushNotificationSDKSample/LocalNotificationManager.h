//
//  LocalNotificationManager.h
//  PushNotificationSDKSample
//
//  Created by Carouesl on 2016/12/1.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LocalNotificationItem;

typedef void(^callBack)(BOOL result ,_Nullable id response);

@interface LocalNotificationManager : NSObject

+(nonnull LocalNotificationManager*) shareInstance;

- (void)registNotificaitonWithInfo:(nonnull LocalNotificationItem*)item  FinishBlock:(_Nonnull callBack) callBack;


@end
