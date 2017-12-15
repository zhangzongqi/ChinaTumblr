//
//  WelcomeViewController.m
//  headmastercome
//
//  Created by 琦琦 on 16/7/6.
//  Copyright © 2016年 zhongshipengrun. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AppDelegate.h"

#define W self.view.frame.size.width
#define H self.view.frame.size.height

@interface WelcomeViewController ()<UIScrollViewDelegate>

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 布局滚动视图的图片,设置其分页视图的属性等
    [self layoutScrollView];
}

// 布局滚动视图
- (void)layoutScrollView {
    
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, W, H)];
    [self.view addSubview:sv];
    sv.tag = 1;
    sv.delegate = self;
    
    sv.userInteractionEnabled = YES;
    // 设置滚动视图支持分页效果
    sv.pagingEnabled = YES;
    sv.showsVerticalScrollIndicator = NO;
    sv.showsHorizontalScrollIndicator = NO;
    
    // 通过循环依次往sv中添加图片,用来实现广告图轮播效果
    for (int i = 0; i < 3; i++) {
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*W, 0, W, H)];
        imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"guidepage%d",i+1]];
        [sv addSubview:imgView];
        
        if (i == 2) {
            
            imgView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
            [imgView addGestureRecognizer:singleTap];//点击图片事件
            
        }
    }
    // 设置滚动视图的内容尺寸
    sv.contentSize = CGSizeMake(3 * W, H);
}

// 实现按钮点击方法
- (void)tapClick {
    
    //  保存用户已经查看过此页面
    [self saveToUserDefaults];
    
    // 底边栏
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // 获取到基类的tabbarController
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    // 底边栏
    appDelegate.mainTabbarController = [story instantiateViewControllerWithIdentifier:@"mainTabbar"];
    appDelegate.window.rootViewController = appDelegate.mainTabbarController;

}

// 保存信息到用户配置持久化存储中
- (void)saveToUserDefaults {
    
    // 获取用户配置持久化对象
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 写数据
    [userDefaults setValue:@"read" forKey:@"welcome"];
    // 同步数据,将内存中的存储转换为存储模型(持久化)
    [userDefaults synchronize];
}

// 实现分页按钮点击方法
- (void)pageChanged:(UIPageControl *)pc {
    
    // 先获取分页控件的当前分页
    NSInteger currentPage = pc.currentPage;
    CGPoint ptOffset = CGPointMake(currentPage * W, 0); // 得到应该偏移的量
    // 设置滚动视图的内容偏移
    UIScrollView *sv = [self.view viewWithTag:1];
    [sv setContentOffset:ptOffset animated:YES];
    
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
