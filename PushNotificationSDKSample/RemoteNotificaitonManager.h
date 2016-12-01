//
//  RemoteNotificaitonManager.h
//  PushNotificationSDKSample
//
//  Created by Carouesl on 2016/12/1.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^callBack)(BOOL result ,_Nullable id response);




@interface RemoteNotificaitonManager : NSObject


+(RemoteNotificaitonManager*) shareInstance;


@end
