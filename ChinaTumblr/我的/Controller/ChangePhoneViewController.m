//
//  ChangePhoneViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/18.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "ChangePhoneViewController.h"

@interface ChangePhoneViewController ()

@end

@implementation ChangePhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置导航栏标题
    UILabel *lbItemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    lbItemTitle.text = @"更换手机号";
    lbItemTitle.textColor = FUIColorFromRGB(0x212121);
    lbItemTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = lbItemTitle;
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
