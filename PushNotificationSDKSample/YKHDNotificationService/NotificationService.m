//
//  NotificationService.m
//  YKHDNotificationService
//
//  Created by Carouesl on 2016/11/30.
//  Copyright © 2016年 Carouesl. All rights reserved.
//

#import "NotificationService.h"
#import <UIKit/UIKit.h>


@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService


- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    
    NSLog(@"didReceiveNotificationRequest");
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    //通过自定义的“id”字段判断是否要对内容进行修改
//    NSString *identifier = self.bestAttemptContent.userInfo[@"id"];
    BOOL needHandleContent = [self.bestAttemptContent.userInfo[@"needhandle"] boolValue];

    if (needHandleContent) {
        self.bestAttemptContent.body = @"这是前段处理后展示的内容";
        self.contentHandler(self.bestAttemptContent);
    
    }
    
    //如果有"image"字段，那么执行下载图片的操作
    NSString *imageURL = self.bestAttemptContent.userInfo[@"image"];
    if (imageURL) {
        [self downloadAndSave:[NSURL URLWithString:imageURL] block:^(NSURL *localURL) {
            NSError *err;
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"img" URL:localURL options:nil error:&err];
            if (err) {
                NSLog(@"生成图片attachment 失败：%@", err);
            }else{
                self.bestAttemptContent.attachments = @[attachment];
                
                
            //示例添加action  这里需要重新封装暂时写一个示例 这里暂时取得本地通知的一个样式
                 self.bestAttemptContent.categoryIdentifier = @"LocalNotificationCategory1";

                self.contentHandler(self.bestAttemptContent);
            }
            
            
            
        }];
    }
    //如果有"mp3"字段，那么执行下载音频的操作
    NSString *mp3URL = self.bestAttemptContent.userInfo[@"mp3"];
    if (mp3URL) {
        [self downloadAndSave:[NSURL URLWithString:mp3URL] block:^(NSURL *localURL) {
            NSLog(@"%@", localURL);
            NSError *err;
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"video" URL:localURL options:nil error:&err];
            if (err) {
                NSLog(@"生成音频attachment 失败：%@", err);
            }else{
                self.bestAttemptContent.attachments = @[attachment];
                self.contentHandler(self.bestAttemptContent);
            }
        }];
    }
    

    //如果有"video"字段，那么执行下载视频的操作
    NSString *videoURL = self.bestAttemptContent.userInfo[@"video"];
    if (videoURL) {
        [self downloadAndSave:[NSURL URLWithString:videoURL] block:^(NSURL *localURL) {
            NSLog(@"%@", localURL);
            NSError *err;
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"video" URL:localURL options:nil error:&err];
            if (err) {
                NSLog(@"生成视频 attachment 失败：%@", err);
            }else{
                self.bestAttemptContent.attachments = @[attachment];
                self.contentHandler(self.bestAttemptContent);
            }
        }];
    }
    
    
    NSLog(@"%@", self.bestAttemptContent.userInfo);
}

- (void)serviceExtensionTimeWillExpire {
    
    NSLog(@"serviceExtensionTimeWillExpire");
    
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

-(void)downloadAndSave:(NSURL *)url block:( void (^)(NSURL * localURL) )completionHandler
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (location) {
            NSArray *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachePath = [cache objectAtIndex:0];
            NSString *ext = url.pathExtension;
            NSString *newName = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
            NSString *copyToURL = [[cachePath stringByAppendingPathComponent:newName] stringByAppendingPathExtension:ext];
            NSData *fileData = [NSData dataWithContentsOfURL:location];
            if ([fileData writeToFile:copyToURL atomically:NO]) {
                completionHandler([NSURL fileURLWithPath:copyToURL]);
            }
        }
    }];
    
    [downloadTask resume];
}

/*
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    NSLog(@"didReceiveNotificationRequest 内容:%@",[request.content.userInfo objectForKey:@"type"]);
    NSString * attchUrl = [request.content.userInfo objectForKey:@"image"];
    //下载图片,放到本地
    UIImage * imageFromUrl = [self getImageFromURL:attchUrl];
    
    //获取documents目录
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectoryPath = [paths firstObject];
    
    NSString * localPath = [self saveImage:imageFromUrl withFileName:@"MyImage" ofType:@"png" inDirectory:documentsDirectoryPath];
    if (localPath && ![localPath isEqualToString:@""]) {
        UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:@"photo" URL:[NSURL URLWithString:[@"file://" stringByAppendingString:localPath]] options:nil error:nil];
        if (attachment) {
            self.bestAttemptContent.attachments = @[attachment];
        }
    }
    self.contentHandler(self.bestAttemptContent);
}

- (UIImage *) getImageFromURL:(NSString *)fileURL {
    NSLog(@"执行图片下载函数");
    UIImage * result;
    //dataWithContentsOfURL方法需要https连接
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

//将所下载的图片保存到本地
- (NSString *) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    NSString *urlStr = @"";
    if ([[extension lowercaseString] isEqualToString:@"png"]){
        urlStr = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]];
        [UIImagePNGRepresentation(image) writeToFile:urlStr options:NSAtomicWrite error:nil];
        
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] ||
               [[extension lowercaseString] isEqualToString:@"jpeg"]){
        urlStr = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:urlStr options:NSAtomicWrite error:nil];
        
    } else{
        NSLog(@"extension error");
    }
    return urlStr;
}



*/
@end
