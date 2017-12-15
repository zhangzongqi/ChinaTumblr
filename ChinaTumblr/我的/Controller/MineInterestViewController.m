//
//  MineInterestViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/5.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "MineInterestViewController.h"
#import "MineInterestDetailViewController.h"
#import "MineFlagViewController.h"
@interface MineInterestViewController () {
    BOOL isEdit;
    UIButton *button;
}
@end

@implementation MineInterestViewController

- (void)viewDidLoad {
    
    
    self.title = @"我的兴趣";
    self.menuHeight = 44; //导航栏高度
    self.menuItemWidth = 60; //每个 MenuItem 的宽度
    self.menuBGColor = [UIColor whiteColor];
    self.menuViewStyle = WMMenuViewStyleLine;//这里设置菜单view的样式
    self.progressHeight = 5;//下划线的高度，需要WMMenuViewStyleLine样式
    self.progressWidth = 10;
    self.progressViewCornerRadius = 2.5f;
    self.progressColor = [UIColor colorWithRed:249/255.0 green:155/255.0 blue:14/255.0 alpha:1.0];//设置下划线(或者边框)颜色
    self.titleSizeSelected = 16;//设置选中文字大小
    self.titleColorSelected = [UIColor colorWithRed:249/255.0 green:155/255.0 blue:14/255.0 alpha:1.0];//设置选中文字颜色
    self.titleColorNormal = [UIColor grayColor];
    self.titleSizeNormal = 16;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
     
    [super viewDidLoad];
    [self createBackBtn];
}
// 返回按钮
- (void) createBackBtn {
    
    // 返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 0, 10.4, 18.4);
    
    [backBtn setImage:[UIImage imageNamed:@"details_return"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    //    self.navigationItem.leftBarButtonItem = backItem;
    
    if (([[[ UIDevice currentDevice ] systemVersion ] floatValue ]>= 7.0 ? 20 : 0 ))
        
    {
        
        UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ] initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace
                                           
                                                                                          target : nil action : nil ];
        
        negativeSpacer.width = 0 ;//这个数值可以根据情况自由变化
        
        self.navigationItem.leftBarButtonItems = @[ negativeSpacer,  backItem] ;
        
    } else {
        self . navigationItem . leftBarButtonItem = backItem;
    }
    button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 30)];
    [button setTitle:@"" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
}

//点击管理
- (void)edit:(UIButton *)butt {
    if(butt.titleLabel.text.length > 0) {
        isEdit = !isEdit;
        if ([butt.titleLabel.text isEqualToString:@"保存"]) {
            NSLog(@"保存操作");
        }
        [self reloadData];
    }
}



// 返回按钮点击事件
- (void) doBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
//设置viewcontroller的个数
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return 2;
}
//设置对应的viewcontroller
- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    if (index == 0) {
        MineInterestDetailViewController *mine = [[MineInterestDetailViewController alloc] init];
        mine.currentIndex = index;
        mine.currnetSelectedIndex = ^(NSInteger index) {
            if (index == 1) {
                if(isEdit) {
                    [button setTitle:@"保存" forState:UIControlStateNormal];
                }else {
                    [button setTitle:@"管理" forState:UIControlStateNormal];
                }
            }else {
                [button setTitle:@"" forState:UIControlStateNormal];
            }
        };
        return mine;
    }else {
        MineFlagViewController *mine = [[MineFlagViewController alloc] init];
        mine.currentIndex = index;
        mine.isEdit = isEdit;
        mine.currnetSelectedIndex = ^(NSInteger index) {
            if (index == 1) {
                if(isEdit) {
                 [button setTitle:@"保存" forState:UIControlStateNormal];
                }else {
                [button setTitle:@"管理" forState:UIControlStateNormal];
                }
            }else {
                [button setTitle:@"" forState:UIControlStateNormal];
            }
        };
        return mine;
    }
}

//设置每个viewcontroller的标题
- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    if (index == 0) {
        return @"领域";
    }
    return @"标签";
}





- (void) viewWillDisappear:(BOOL)animated {
    
    //这个接口可以动画的改变statusBar的前景色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}
- (void) viewWillAppear:(BOOL)animated {
    
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
