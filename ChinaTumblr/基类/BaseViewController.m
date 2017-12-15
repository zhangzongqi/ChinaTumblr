//
//  BaseViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/16.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic, copy) MBProgressHUD *HUD;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 页面背景色
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    // 设置导航条不透明
    self.navigationController.navigationBar.translucent = NO;
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
