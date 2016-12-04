//
//  NotificationViewController.m
//  YKHDNotificationContent
//
//  Created by Carouesl on 2016/11/30.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* mylabel;

@end

@implementation NotificationViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    NSLog(@"自定义UI");
//}
//
//- (void)didReceiveNotification:(UNNotification *)notification {
//    self.label.text = notification.request.content.body;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:_imageView];
    

}

- (void)didReceiveNotification:(UNNotification *)notification {
    self.mylabel.text = notification.request.content.title;
    
    UNNotificationContent *content = notification.request.content;
    UNNotificationAttachment *attachment = content.attachments[0];
    if ([attachment.URL startAccessingSecurityScopedResource]) {
        NSData *data = [NSData dataWithContentsOfURL:attachment.URL];
        UIImage *image = [UIImage imageWithData:data];
        CGSize size = image.size;
        self.imageView.image = image;
        self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
        [attachment.URL stopAccessingSecurityScopedResource];
    }
    
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption option))completion
{
    NSString *actionID = response.actionIdentifier;
    
//    if ([actionID isEqualToString:@"action.play"]) {
//        NSLog(@"play");
//        self.bodyLabel.text = @"play taped~";
//    }else if([actionID isEqualToString:@"action.pause"]){
//        NSLog(@"pause");
//        self.bodyLabel.text = @"pause taped~";
//    }else if([actionID isEqualToString:@"action.cancel"]){
//        
//        NSLog(@"cancel");
//        
//        completion(UNNotificationContentExtensionResponseOptionDismiss);
//    }
//    
}

//- (UNNotificationContentExtensionMediaPlayPauseButtonType)mediaPlayPauseButtonType
//{
//    return UNNotificationContentExtensionMediaPlayPauseButtonTypeDefault;
//}
//
//-(CGRect)mediaPlayPauseButtonFrame
//{
//    return CGRectMake(20, 120, 60, 60);
//}
//
//- (void)mediaPlay
//{
//    self.buttonStateLable.text = @"play";
//}
//- (void)mediaPause
//{
//    self.buttonStateLable.text = @"pause";
//}


@end
