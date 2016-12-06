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

@property (assign, nonatomic )LocalNotificationCategory ca;
@property (assign, nonatomic )LocalNotificationAttachmentType at;

@property (nonatomic, strong) NSArray* categries;
@property (nonatomic, strong) NSArray* atTypes;
@property (nonatomic, strong) NSArray* titles;

@property (weak, nonatomic) IBOutlet UILabel *typeLable;
@property (weak, nonatomic) IBOutlet UILabel *attachmentLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _ca = LocalNotificationCategory0;
    self.categries = @[@(LocalNotificationCategory0),
                       @(LocalNotificationCategory1),
                       @(LocalNotificationCategory2),
                       @(LocalNotificationCategory3)];
    self.atTypes = @[@(NotificationAttachmentTypeNone),
                       @(NotificationAttachmentTypeImage),
                       @(NotificationAttachmentTypeImageGif),
                       @(NotificationAttachmentTypeAudio),
                       @(NotificationAttachmentTypeMovie)];
    self.titles = @[@"无附件",@"图片",@"动态图",@"音频",@"视频"];

}
- (IBAction)changeNotifyAttachment:(id)sender {
    
    static NSInteger index = 1;
    //    _ca = [_categries[index] integerValue];
    _at = index;
    NSString* t = _titles[index];
    if (index == 0) {
        t = @"默认类型";
    }
    _attachmentLabel.text = t;
    index ++;
    if (index > _atTypes.count - 1) {
        index = 0;
        
    }
    
    NSLog(@"当前选择第%lu种类型附件",(unsigned long)_ca);
    
}
- (IBAction)changeNotifyType:(id)sender {
    static NSInteger index = 1;
//    _ca = [_categries[index] integerValue];
    _ca = index;
    NSString* t = [NSString stringWithFormat:@"第%ld种类型",(long)index];
    if (index == 0) {
        t = @"默认类型";
    }
    _typeLable.text = t;
    index ++;
    if (index > _categries.count - 1) {
        index = 0;

    }

    NSLog(@"当前选择第%lu种类型",(unsigned long)_ca);
    
}

- (IBAction)registeLocalNotification:(id)sender {
    
    LocalNotificationItem* item = [[LocalNotificationItem alloc] init];
    item.title = @"这是主标题";
    item.subTitle = @"这是副标题";
    item.body = @" iOS 10 中，可以允许推送添加交互操作 action，这些 action 可以使得 App 在前台或后台执行一些逻辑代码。并且在锁屏界面通过 3d-touch 触发。如：推出键盘进行快捷回复，该功能以往只在 iMessage 中可行。";
    item.type = LocalNotificationTypeInterval;
    item.category = self.ca;
    item.timeInteval = 2.0f;
    item.attachmentType = self.at;
    item.repeat = NO;
    
    
    [[UserNotificationCenter defaultCenter] addLocaNotificaitonWithInfo:item FinishBlock:^(BOOL result, id  _Nullable response) {
        
    }];
    
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
