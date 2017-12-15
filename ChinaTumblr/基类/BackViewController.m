//
//  BackViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/16.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "BackViewController.h"

@interface BackViewController ()

@end

@implementation BackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 返回按钮
    [self createBackBtn];
}

// 返回按钮
- (void) createBackBtn {
    
    // 返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30.4, 18.4);
    
    backBtn.imageView.sd_layout
    .leftSpaceToView(backBtn, 0)
    .centerXEqualToView(backBtn)
    .widthIs(10.4)
    .heightIs(18.4);
    
    [backBtn setImage:[UIImage imageNamed:@"details_return"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    //    self.navigationItem.leftBarButtonItem = backItem;
    
    if (([[[ UIDevice currentDevice ] systemVersion ] floatValue ]>= 7.0 ? 20 : 0 ))
        
    {
        
        UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ] initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace
                                           
                                                                                          target : nil action : nil ];
        
        negativeSpacer.width = -5;//这个数值可以根据情况自由变化
        
        self.navigationItem.leftBarButtonItems = @[ negativeSpacer,  backItem] ;
        
    } else {
        self . navigationItem . leftBarButtonItem = backItem;
    }
    
}

// 返回按钮点击事件
- (void) doBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


// 页面将要消失
- (void) viewWillDisappear:(BOOL)animated {
    
    //这个接口可以动画的改变statusBar的前景色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

// 页面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // 设置导航栏背景色
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    //这个接口可以动画的改变statusBar的前景色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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
