//
//  ViewController.m
//  PushNotificationSDKSample
//
//  Created by Carouesl on 2016/11/29.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import "ViewController.h"
#import "UserNotificationCenter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


}
- (IBAction)changeNotifyType:(id)sender {
}

- (IBAction)registeLocalNotification:(id)sender {
    
    LocalNotificationItem* item = [[LocalNotificationItem alloc] init];
    item.title = @"这是主标题";
    item.subTitle = @"这是副标题";
    item.body = @" iOS 10 中，可以允许推送添加交互操作 action，这些 action 可以使得 App 在前台或后台执行一些逻辑代码。并且在锁屏界面通过 3d-touch 触发。如：推出键盘进行快捷回复，该功能以往只在 iMessage 中可行。";
    item.type = LocalNotificationTypeInterval;
    item.timeInteval = 5.0f;
    item.repeat = NO;
    
    
    [[UserNotificationCenter defaultCenter] registLocaNotificaitonWithInfo:item FinishBlock:^(BOOL result, id  _Nullable response) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
