//
//  AppDelegate.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/7/25.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeViewController.h" // 引导页

// shareSDK
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//微信SDK头文件
#import "WXApi.h"
//新浪微博SDK头文件
#import "WeiboSDK.h"
//新浪微博SDK需要在项目Build Settings中的Other Linker Flags添加"-ObjC"


// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>


// 需要跳转的通知页面
#import "DeatalSystemNoticeViewController.h"  // 专题详情
#import "MineFansViewController.h" // 粉丝列表
#import "DongTaiViewController.h" // 帖子动态列表
#import "DetailImgViewController.h" // 帖子详情列表
#import "PingLunViewController.h" // 评论列表

#import "UIView+WZLBadge.h" // 小红点
#import "UITabBarItem+WZLBadge.h" // 小红点


@interface AppDelegate ()<WXApiDelegate,JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // RSA公钥
    NSString *strPublicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJx0bbeEcuKaXtJ5YfN79poZmP0XKYGx251mkMMEWsBAi0lTBop4KvibCUn8C48sjj19BJqi5PgdiRp3josUUoLv6r4NplawRLe1WCG/8lR61xtlcGIiV+fTI/0FT5uyn2Ru+5s4kCvKGtnXTfZnIecuP7oeFeTAD/r9v4Sb8DzQIDAQAB";
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:strPublicKey forKey:@"localPublickey"];
    
    
    // 导航条颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // 设置底边栏不透明
    [UITabBar appearance].translucent = NO;
    
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:@"1a32c1c3a5835d5c8ee09c5e"
                          channel:@"App Store"
                 apsForProduction:1
            advertisingIdentifier:advertisingId];
    
    
    // 社会化分享
    [self shareServe];
    
    // 引导页
    [self welcomeVC];
    
    return YES;
}


#pragma mark ----JPush----
// 注册APNs成功并上报DeviceToken
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}
// 实现注册APNs失败接口（可选）
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    
    // APP在运行时候，收到通知，走这个函数
    
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    NSLog(@"************%@",userInfo);
    
    
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBarItem *firstItem = tempAppDelegate.mainTabbarController.tabBar.items[3];
    [firstItem showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
    
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    // APP被系统通知调起时，收到通知，走这个函数
    
    // 设置图标上的推送消息个数
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - 1;
    
    [JPUSHService setBadge:[UIApplication sharedApplication].applicationIconBadgeNumber];
    
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UITabBarItem *firstItem = tempAppDelegate.mainTabbarController.tabBar.items[3];
        [firstItem showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
    }
    
    
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSLog(@"************%@",userInfo);
    
    
    // 做相应处理
    NSString *type = [NSString stringWithFormat:@"%@",[userInfo valueForKey:@"type"]];
    NSLog(@"type:%@",type);
    switch ([type integerValue]) {
        case 1: {
            // 专题活动
            // 获取delegate
            AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UINavigationController *currentNavController = tempAppDelegate.mainTabbarController.childViewControllers[tempAppDelegate.mainTabbarController.selectedIndex];
            DeatalSystemNoticeViewController *targetVc = [[DeatalSystemNoticeViewController alloc] init];
            targetVc.idStr = [userInfo objectForKey:@"specialEventId"];
            [targetVc setHidesBottomBarWhenPushed:YES];
            [currentNavController pushViewController:targetVc animated:YES];
        }
            break;
        case 2: {
            // 被人关注,打开粉丝列表
            // 专题活动
            // 获取delegate
            AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UINavigationController *currentNavController = tempAppDelegate.mainTabbarController.childViewControllers[tempAppDelegate.mainTabbarController.selectedIndex];
            MineFansViewController *targetVc = [[MineFansViewController alloc] init];
            [targetVc setHidesBottomBarWhenPushed:YES];
            [currentNavController pushViewController:targetVc animated:YES];
        }
            break;
        case 3: {
            // 帖子被人喜欢,打开帖子动态列表
            AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UINavigationController *currentNavController = tempAppDelegate.mainTabbarController.childViewControllers[tempAppDelegate.mainTabbarController.selectedIndex];
            DetailImgViewController *targetVc = [[DetailImgViewController alloc] init];
            targetVc.strId = [userInfo objectForKey:@"noteId"];
            [targetVc setHidesBottomBarWhenPushed:YES];
            [currentNavController pushViewController:targetVc animated:YES];
            DongTaiViewController *targetVc2 = [[DongTaiViewController alloc] init];
            targetVc2.noteId = [userInfo objectForKey:@"noteId"];
            [targetVc2 setHidesBottomBarWhenPushed:YES];
            [currentNavController pushViewController:targetVc2 animated:YES];
        }
            break;
        case 4: {
            // 帖子被人喜欢,打开帖子动态列表
            AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UINavigationController *currentNavController = tempAppDelegate.mainTabbarController.childViewControllers[tempAppDelegate.mainTabbarController.selectedIndex];
            DetailImgViewController *targetVc = [[DetailImgViewController alloc] init];
            targetVc.strId = [userInfo objectForKey:@"noteId"];
            [targetVc setHidesBottomBarWhenPushed:YES];
            [currentNavController pushViewController:targetVc animated:YES];
            PingLunViewController *targetVc2 = [[PingLunViewController alloc] init];
            targetVc2.noteId = [userInfo objectForKey:@"noteId"];
            [targetVc2 setHidesBottomBarWhenPushed:YES];
            [currentNavController pushViewController:targetVc2 animated:YES];
        }
            break;
        case 5: {
            // 帖子被人喜欢,打开帖子动态列表
            AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UINavigationController *currentNavController = tempAppDelegate.mainTabbarController.childViewControllers[tempAppDelegate.mainTabbarController.selectedIndex];
            DetailImgViewController *targetVc = [[DetailImgViewController alloc] init];
            targetVc.strId = [userInfo objectForKey:@"noteId"];
            [targetVc setHidesBottomBarWhenPushed:YES];
            [currentNavController pushViewController:targetVc animated:YES];
            PingLunViewController *targetVc2 = [[PingLunViewController alloc] init];
            targetVc2.noteId = [userInfo objectForKey:@"noteId"];
            [targetVc2 setHidesBottomBarWhenPushed:YES];
            [currentNavController pushViewController:targetVc2 animated:YES];
        }
            
        default:
            break;
    }
    
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}


// 社会化分享
- (void)shareServe {
    
    
    [ShareSDK registerApp:@"20de67fb00194"
     
          activePlatforms:@[
                            @(SSDKPlatformTypeMail),
                            @(SSDKPlatformTypeSMS),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ)
                            ]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wx7eea3e192420f594"
                                       appSecret:@"3a0f364b4eb9fdaffbd88974df0c7f4a"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"1106416198"
                                      appKey:@"FnYvjNOrMr4esZwi"
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
     }];
}



// 引导页
- (void)welcomeVC {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];   //设置通用背景颜色
    [self.window makeKeyAndVisible];
    
    // 获取应用程序持久化存储--属性列表中所保存的用户是否已查看过欢迎页
    NSString *strUserPro = [self readFromUserDefaults];
    // 判断该数据是否为空,并且其值为某一标识
    if (strUserPro != nil && [strUserPro isEqualToString:@"read"]) {
        
        // 获取到基类的tabbarController
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        // 底边栏
        self.mainTabbarController = [story instantiateViewControllerWithIdentifier:@"mainTabbar"];
        
        self.window.rootViewController = self.mainTabbarController;
        
    }else {
        
        // 没看过欢迎页,显示欢迎页
        WelcomeViewController *mainVC = [[WelcomeViewController alloc] init];
        self.window.rootViewController = mainVC;
    }
}

// 从持久化存储中获取是否查看欢迎页
- (NSString *)readFromUserDefaults {
    
    // 先定义变量用于保存获取的数据
    NSString *strReturn = nil;
    // 获取用户配置类的对象 - - 持久化存储中属性列表对象
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 通过实例方法获取存储的数据
    strReturn = [userDefaults stringForKey:@"welcome"];
    return strReturn;
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UITabBarItem *firstItem = tempAppDelegate.mainTabbarController.tabBar.items[3];
        [firstItem showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // 用户退出程序时, 删除部分单例
    // 标签数组消失
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"labelArr"];
    // 用户单例删除视频URL
    [user removeObjectForKey:@"vedioURL"];
    
    
    // 删除单例
    // 首页处理
    [UserDefaults removeObjectForKey:@"LoveTieZiForReviseHome"];
    [UserDefaults removeObjectForKey:@"DelLoveTieZiForReviseHome"];
    [UserDefaults removeObjectForKey:@"DelTieZiForShouYe"];
    // 发现页处理
    [UserDefaults removeObjectForKey:@"FollowUserOrBlacklistUser"];
    [UserDefaults removeObjectForKey:@"CancleFollowUser"];
    [UserDefaults removeObjectForKey:@"RemoveDisLikeUser"];
    // 消息页处理
    [UserDefaults removeObjectForKey:@"FollowUserForNews"];
    [UserDefaults removeObjectForKey:@"CancleFollowUserForNews"];
    // 我的页面处理
    [UserDefaults removeObjectForKey:@"LoveTieZiForReviseMine"];
    [UserDefaults removeObjectForKey:@"DelLoveTieZiForReviseMine"];
    [UserDefaults removeObjectForKey:@"DelTieZiForMine"];
}


@end
