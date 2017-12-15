//
//  NoticeViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/7/26.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "NoticeViewController.h"
#import "WMTrendsViewController.h"  // 动态页面
#import "WMNoticeViewController.h"  // 消息页面
#import "WMSystemNoticeViewController.h" // 系统推送消息
#import "UITabBarItem+WZLBadge.h"
#import "JPUSHService.h"

@interface NoticeViewController ()<UITabBarControllerDelegate>

@end

@implementation NoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置导航条不透明
    self.navigationController.navigationBar.translucent = NO;
    
    // 切圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path = maskPath.CGPath;
    self.view.layer.mask = maskLayer;
}

// 标题们
- (NSArray <NSString *> *)titles {
    
    return @[@"专题",@"消息"];
}

// 一些属性
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    
    // 已修改MenuView的Frame  具体搜索MenuViewframe
    // 已修改lineWidth 具体搜索LineWidth(一个单元格的2/5)
    self.menuBGColor = [UIColor clearColor];
    self.menuItemWidth = W / 2;
    self.menuViewStyle = WMMenuViewStyleLine;
    self.progressViewBottomSpace = 0;
    self.progressHeight = 2.0;
    self.menuHeight = 44;
    self.titleColorNormal = [UIColor colorWithRed:152/255.0 green:153/255.0 blue:154/255.0 alpha:1.0];
    self.titleColorSelected = [UIColor colorWithRed:250/255.0 green:170/255.0 blue:44/255.0 alpha:1.0];
    self.titleSizeNormal = 15;
    self.titleSizeSelected = 16;
    self.showOnNavigationBar = YES;
    
    
    return self.titles.count;
}


// page
- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
        {
            WMSystemNoticeViewController *trendsVc = [[WMSystemNoticeViewController alloc] init];
            return trendsVc;
        }
            break;
            
        case 1:
        {
            WMNoticeViewController *noticeVc = [[WMNoticeViewController alloc] init];
            return noticeVc;
        }
            break;
            
        default:{
            
            return nil;
        }
            break;
    }
    
    
}

//// 监听处理事件
//- (void)listen:(NSNotification *)noti {
//    
//    NSString *strNoti = noti.object;
//    
//    
//    // 登录成功
//    if ([strNoti isEqualToString:@"91"]) {
//        
//        [self reloadData];
//        
//        // 销毁用户登录成功的通知
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginSuccessForXiaoXi" object:@"91"];
//    }
//}


// 页面将要加载
- (void) viewWillAppear:(BOOL)animated {
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // 设置导航栏背景色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0]];
}

- (void) viewDidAppear:(BOOL)animated {
    
//    // 接收消息
//    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
//    
//    // 登录成功
//    [notiCenter addObserver:self selector:@selector(listen:) name:@"loginSuccessForXiaoXi" object:@"91"];
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        
        // 设置图标上的推送消息个数
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        [JPUSHService resetBadge];
        
        // 刷新数据
        [self reloadData];
        
        [self.tabBarController.tabBar.items[3] clearBadge];
    }
}

// 页面将要消失
- (void) viewWillDisappear:(BOOL)animated {
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
