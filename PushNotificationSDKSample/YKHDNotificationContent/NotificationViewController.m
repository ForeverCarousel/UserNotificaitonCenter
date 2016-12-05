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
@property (nonatomic, strong) UILabel* mylabel1;

@property (nonatomic, strong) UILabel* mylabel2;

@property (nonatomic, strong) UILabel* mylabel3;

@property (nonatomic, assign) CGFloat imageScale;
@end

@implementation NotificationViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // 图片  600*400
    self.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 200);

    self.imageScale = 0.5;
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    [self.view addSubview:_imageView];
    
    self.mylabel   = [[UILabel alloc] initWithFrame:CGRectMake(300, 0, 100, 50)];
    _mylabel.textAlignment = NSTextAlignmentLeft;
    _mylabel.font = [UIFont systemFontOfSize:14.0f];
    _mylabel.textColor = [UIColor purpleColor];
    _mylabel.backgroundColor = [UIColor orangeColor];
    _mylabel.text = @"自定义控件0";
    [self.view addSubview:_mylabel];
    
    self.mylabel1   = [[UILabel alloc] initWithFrame:CGRectMake(300, 50, 100, 50)];
    _mylabel1.textAlignment = NSTextAlignmentLeft;
    _mylabel1.font = [UIFont systemFontOfSize:14.0f];
    _mylabel1.textColor = [UIColor purpleColor];
    _mylabel1.backgroundColor = [UIColor redColor];
    _mylabel1.text = @"自定义控件1";
    [self.view addSubview:_mylabel1];
    
    self.mylabel2   = [[UILabel alloc] initWithFrame:CGRectMake(300, 100, 100, 50)];
    _mylabel2.textAlignment = NSTextAlignmentLeft;
    _mylabel2.font = [UIFont systemFontOfSize:14.0f];
    _mylabel2.textColor = [UIColor purpleColor];
    _mylabel2.backgroundColor = [UIColor greenColor];
    _mylabel2.text = @"自定义控件2";
    [self.view addSubview:_mylabel2];
    
    self.mylabel3   = [[UILabel alloc] initWithFrame:CGRectMake(300, 150, 100, 50)];
    _mylabel3.textAlignment = NSTextAlignmentLeft;
    _mylabel3.font = [UIFont systemFontOfSize:14.0f];
    _mylabel3.textColor = [UIColor purpleColor];
    _mylabel3.backgroundColor = [UIColor yellowColor];
    _mylabel3.text = @"自定义控件3";
    [self.view addSubview:_mylabel3];
    
  
    
}

- (void)didReceiveNotification:(UNNotification *)notification {
//    self.mylabel.text = notification.request.content.title;
    
    UNNotificationContent *content = notification.request.content;
    UNNotificationAttachment *attachment = content.attachments[0];
    /*
     file:///var/mobile/Library/SpringBoard/PushStore/Attachments/com.youku.pushSDKDemo/7bacb9e3ca70357e9a974533c5a8cabefc0a7034.jpeg 从URL可以看出来这里读取的是servic处理过后的的内容 并且其内容的空间和app是独立的 根据bundleID来映射的
     */
    if ([attachment.URL startAccessingSecurityScopedResource]) {
        NSData *data = [NSData dataWithContentsOfURL:attachment.URL];
        UIImage *image = [UIImage imageWithData:data];
        CGSize size = image.size;
        self.imageView.image = image;
        self.imageView.frame = CGRectMake(0, 0, size.width*_imageScale, size.height*_imageScale);
        self.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.frame), size.height*_imageScale);

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
