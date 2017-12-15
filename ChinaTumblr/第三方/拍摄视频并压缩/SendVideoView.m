//
//  SendVideoView.m
//  压缩视频
//
//  Created by 施永辉 on 16/7/7.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "SendVideoView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
@interface SendVideoView ()<UITextViewDelegate>
{
     NSURL * CompressURL;
}
@end



@implementation SendVideoView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton * compressionBT = [UIButton buttonWithType:UIButtonTypeCustom];
    compressionBT.frame = CGRectMake(100, 100, 100, 30);
    [compressionBT setTitle:@"压缩视频" forState:UIControlStateNormal];
    [compressionBT setBackgroundColor:[UIColor blueColor]];
    [compressionBT addTarget:self action:@selector(compression) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:compressionBT];
    
   

}
//计算压缩大小
- (CGFloat)fileSize:(NSURL *)path
{
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}
//压缩
- (void)compression
{
      NSLog(@"压缩前大小 %f MB",[self fileSize:_videoUrl]);
    //    创建AVAsset对象
    AVAsset* asset = [AVAsset assetWithURL:_videoUrl];
    /*   创建AVAssetExportSession对象
     压缩的质量
     AVAssetExportPresetLowQuality   最low的画质最好不要选择实在是看不清楚
     AVAssetExportPresetMediumQuality  使用到压缩的话都说用这个
     AVAssetExportPresetHighestQuality  最清晰的画质
     
     */
    AVAssetExportSession * session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    
    AVAssetExportSession * session1 = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    AVAssetExportSession * session2 = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    
    
    //优化网络
    session.shouldOptimizeForNetworkUse = YES;
    session1.shouldOptimizeForNetworkUse = YES;
    session2.shouldOptimizeForNetworkUse = YES;
    //转换后的格式
    
    //拼接输出文件路径 为了防止同名 可以根据日期拼接名字 或者对名字进行MD5加密
    
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"hello.mp4"];
    
    NSString* path1 = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"hello1.mp4"];
    NSString* path2 = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"hello2.mp4"];
    
    
    //判断文件是否存在，如果已经存在删除
    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
    [[NSFileManager defaultManager]removeItemAtPath:path1 error:nil];
    [[NSFileManager defaultManager]removeItemAtPath:path2 error:nil];
    //设置输出路径
    session.outputURL = [NSURL fileURLWithPath:path];
    session1.outputURL = [NSURL fileURLWithPath:path1];
    session2.outputURL = [NSURL fileURLWithPath:path2];
    
    //设置输出类型  这里可以更改输出的类型 具体可以看文档描述
    session.outputFileType = AVFileTypeAppleM4V;
    session1.outputFileType = AVFileTypeAppleM4V;
    session2.outputFileType = AVFileTypeAppleM4V;
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"%@",[NSThread currentThread]);
        
        //压缩完成
        
        if (session.status==AVAssetExportSessionStatusCompleted) {
            //在主线程中刷新UI界面，弹出控制器通知用户压缩完成
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"导出完成");
                CompressURL = session.outputURL;
                NSLog(@"session压缩完毕,压缩后大小 %f MB",[self fileSize:CompressURL]);
                
                
                
                
                ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
                [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:CompressURL completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
                    }
//                    if (lastBackgroundTaskIdentifier!=UIBackgroundTaskInvalid) {
//                        [[UIApplication sharedApplication] endBackgroundTask:lastBackgroundTaskIdentifier];
//                    }
                    NSLog(@"成功保存视频到相簿.");
//                    [self pushToPlay:outputFileURL];
                }];
                
            });
            
        }
        
    }];
    
    
    [session1 exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"%@",[NSThread currentThread]);
        
        //压缩完成
        
        if (session1.status==AVAssetExportSessionStatusCompleted) {
            //在主线程中刷新UI界面，弹出控制器通知用户压缩完成
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"导出完成");
                CompressURL = session1.outputURL;
                NSLog(@"session1压缩完毕,压缩后大小 %f MB",[self fileSize:CompressURL]);
                
                
                
                
                ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
                [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:CompressURL completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
                    }
                    //                    if (lastBackgroundTaskIdentifier!=UIBackgroundTaskInvalid) {
                    //                        [[UIApplication sharedApplication] endBackgroundTask:lastBackgroundTaskIdentifier];
                    //                    }
                    NSLog(@"成功保存视频到相簿.");
                    //                    [self pushToPlay:outputFileURL];
                }];
                
            });
            
        }
        
    }];
    
    [session2 exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"%@",[NSThread currentThread]);
        
        //压缩完成
        
        if (session2.status==AVAssetExportSessionStatusCompleted) {
            //在主线程中刷新UI界面，弹出控制器通知用户压缩完成
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"导出完成");
                CompressURL = session2.outputURL;
                NSLog(@"session2压缩完毕,压缩后大小 %f MB",[self fileSize:CompressURL]);
                
                
                
                
                ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
                [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:CompressURL completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
                    }
                    //                    if (lastBackgroundTaskIdentifier!=UIBackgroundTaskInvalid) {
                    //                        [[UIApplication sharedApplication] endBackgroundTask:lastBackgroundTaskIdentifier];
                    //                    }
                    NSLog(@"成功保存视频到相簿.");
                    //                    [self pushToPlay:outputFileURL];
                }];
                
            });
            
        }
        
    }];
    
    
    
    
}

@end
