//
//  AppDelegate.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/7/25.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTabbarViewController.h" // 底边栏基类

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BaseTabbarViewController *mainTabbarController;

@end

