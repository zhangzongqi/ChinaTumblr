//
//  BaseTabbarViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/7/26.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "BaseTabbarViewController.h"
#import "PublishTextViewController.h" // 发布文字
#import "PublishPhotoViewController.h" // 发布图片
#import "PublishVideoViewController.h" // 发布视频

#import "ZFTableViewController.h"
#import "FindViewController.h" 
#import "NoticeViewController.h"
#import "MineViewController.h"

#import "UITabBarItem+WZLBadge.h"


#define BtnWidthAndHeight 0.20625 * W
#define SpaceWidth (1 - 0.20625 * 3) * W / 4

@interface BaseTabbarViewController () <UITabBarControllerDelegate> {
    
    NSUInteger xuanzhuanNum;
}

@property (nonatomic, copy) UIButton *publishBtn; // 发布按钮

@property (nonatomic, copy) UIView *zhezhaoUv; // 遮罩层

@end

@implementation BaseTabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    
    xuanzhuanNum = 0;
    
    // 修改tabbar背景色
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = FUIColorFromRGB(0x151515);
    backView.frame = self.tabBar.bounds;
    [[UITabBar appearance] insertSubview:backView atIndex:0];
    
    
    // 正常状态下
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:1.0], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    
    // 高亮状态下
    UIColor *titleHighlightedColor = [UIColor colorWithRed:250/255.0 green:170/255.0 blue:44/255.0 alpha:1.0];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:titleHighlightedColor, UITextAttributeTextColor,nil] forState:UIControlStateSelected];
    
    
    // 发布按钮
    _publishBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/5 * 2, 0, self.view.frame.size.width/5, 49)];
    
    _publishBtn.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    [self.tabBar addSubview:_publishBtn];
    
    _publishBtn.titleLabel.sd_layout
    .bottomSpaceToView(_publishBtn, 4)
    .centerXEqualToView(_publishBtn)
    .heightIs(12);
    
    _publishBtn.imageView.sd_layout
    .bottomSpaceToView(_publishBtn, 20)
    .centerXEqualToView(_publishBtn)
    .widthIs(23)
    .heightIs(23);
    
    [_publishBtn setTitleColor:[UIColor colorWithRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:1.0] forState:UIControlStateNormal];
    _publishBtn.titleLabel.font = [UIFont systemFontOfSize:10.5];
    [_publishBtn setTitle:@"嘚瑟" forState:UIControlStateNormal];
    [_publishBtn setImage:[UIImage imageNamed:@"TabBar_off3"] forState:UIControlStateNormal];
    [_publishBtn addTarget:self action:@selector(publishBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 遮罩层
    _zhezhaoUv = [[UIView alloc] initWithFrame:self.view.bounds];
    _zhezhaoUv.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:0.1];
    _zhezhaoUv.hidden = YES;
    _zhezhaoUv.tag = 1*100000;
    [self.view addSubview:_zhezhaoUv];
    
    // 模糊遮罩层
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImgView.image = [UIImage imageNamed:@"huoying.jpg"];
    bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    bgImgView.userInteractionEnabled = YES;
    [_zhezhaoUv addSubview:bgImgView];
    /*
     毛玻璃的样式(枚举)
     UIBlurEffectStyleExtraLight,
     UIBlurEffectStyleLight,
     UIBlurEffectStyleDark
     */
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//    effectView.alpha = 0.95;
    effectView.frame = CGRectMake(0, 0, bgImgView.frame.size.width, bgImgView.frame.size.height);
    [bgImgView addSubview:effectView];
    
    
    // 关闭按钮图片
    UIImageView *closeImgView = [[UIImageView alloc] init];
    [bgImgView addSubview:closeImgView];
    [closeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgImgView);
        make.bottom.equalTo(bgImgView).with.offset(-21);
        make.width.equalTo(@(19));
        make.height.equalTo(@(19));
    }];
    closeImgView.image = [UIImage imageNamed:@"TabBar_on3"];
    closeImgView.tag = 123;
    // 关闭
    UILabel *lbClose = [[UILabel alloc] init];
    [bgImgView addSubview:lbClose];
    lbClose.text = @"关闭";
    lbClose.font = [UIFont systemFontOfSize:10.5];
    lbClose.textColor = [UIColor colorWithRed:250/255.0 green:170/255.0 blue:44/255.0 alpha:1.0];
    [lbClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(closeImgView.mas_bottom).with.offset(4.5);
        make.centerX.equalTo(self.tabBar);
        make.width.equalTo(@(0));
        make.height.equalTo(@(0));
    }];
    lbClose.tag = 124;
    lbClose.textAlignment = NSTextAlignmentCenter;
    
    
    // 文字
    UIButton *btnText = [[UIButton alloc] initWithFrame:CGRectMake(SpaceWidth, H, BtnWidthAndHeight, BtnWidthAndHeight)];
    [bgImgView addSubview:btnText];
    btnText.titleLabel.sd_layout
    .centerXEqualToView(btnText)
    .bottomSpaceToView(btnText, BtnWidthAndHeight * 0.23)
    .heightIs(11)
    .widthIs(23);
    btnText.imageView.sd_layout
    .centerXEqualToView(btnText)
    .topSpaceToView(btnText ,BtnWidthAndHeight * 0.23)
    .heightIs(BtnWidthAndHeight - BtnWidthAndHeight * 0.46 - 16)
    .widthEqualToHeight();
    btnText.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnText.titleLabel.font = [UIFont systemFontOfSize:11];
    [btnText setImage:[UIImage imageNamed:@"publish_icon1"] forState:UIControlStateNormal];
    // 切圆角和边框
    btnText.layer.cornerRadius = BtnWidthAndHeight / 2;
    btnText.clipsToBounds = YES;
    btnText.layer.borderColor = [[UIColor colorWithRed:85/255.0 green:85/255.0 blue:86/255.0 alpha:1.0] CGColor];
    btnText.layer.borderWidth = 1;
    
    btnText.backgroundColor = [UIColor clearColor];
    btnText.tag = 2*100000;
    // 设置标题
    [btnText setTitle:@"文字" forState:UIControlStateNormal];
    [btnText setTitleColor:FUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [btnText addTarget:self action:@selector(btnTextClick:) forControlEvents:UIControlEventTouchUpInside];
    btnText.alpha = 0.5;
    
    
    // 照片
    UIButton *btnPicture = [[UIButton alloc] initWithFrame:CGRectMake(SpaceWidth*2 + BtnWidthAndHeight, H, BtnWidthAndHeight, BtnWidthAndHeight)];
    [bgImgView addSubview:btnPicture];
    btnPicture.titleLabel.sd_layout
    .centerXEqualToView(btnPicture)
    .bottomSpaceToView(btnPicture, BtnWidthAndHeight * 0.23)
    .heightIs(11)
    .widthIs(23);
    btnPicture.imageView.sd_layout
    .centerXEqualToView(btnPicture)
    .topSpaceToView(btnPicture ,BtnWidthAndHeight * 0.23)
    .heightIs(BtnWidthAndHeight - BtnWidthAndHeight * 0.46 - 16)
    .widthEqualToHeight();
    btnPicture.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnPicture.titleLabel.font = [UIFont systemFontOfSize:11];
    [btnPicture setImage:[UIImage imageNamed:@"publish_icon2"] forState:UIControlStateNormal];
    // 切圆角和边框
    btnPicture.layer.cornerRadius = BtnWidthAndHeight / 2;
    btnPicture.clipsToBounds = YES;
    btnPicture.layer.borderColor = [[UIColor colorWithRed:85/255.0 green:85/255.0 blue:86/255.0 alpha:1.0] CGColor];;
    btnPicture.layer.borderWidth = 1;
    
    btnPicture.backgroundColor = [UIColor clearColor];
    btnPicture.tag = 3*100000;
    // 设置标题
    [btnPicture setTitle:@"图片" forState:UIControlStateNormal];
    [btnPicture setTitleColor:FUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    
    [btnPicture addTarget:self action:@selector(btnPictureClick:) forControlEvents:UIControlEventTouchUpInside];
    btnPicture.alpha = 0.5;
    
    
    // 视频
    UIButton *btnVideo = [[UIButton alloc] initWithFrame:CGRectMake(SpaceWidth*3 + BtnWidthAndHeight*2, H, BtnWidthAndHeight, BtnWidthAndHeight)];
    [bgImgView addSubview:btnVideo];
    btnVideo.titleLabel.sd_layout
    .centerXEqualToView(btnVideo)
    .bottomSpaceToView(btnVideo, BtnWidthAndHeight * 0.23)
    .heightIs(11)
    .widthIs(23);
    btnVideo.imageView.sd_layout
    .centerXEqualToView(btnVideo)
    .topSpaceToView(btnVideo ,BtnWidthAndHeight * 0.23)
    .heightIs(BtnWidthAndHeight - BtnWidthAndHeight * 0.46 - 16)
    .widthEqualToHeight();
    btnVideo.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnVideo.titleLabel.font = [UIFont systemFontOfSize:11];
    [btnVideo setImage:[UIImage imageNamed:@"publish_icon3"] forState:UIControlStateNormal];
    // 切圆角和边框
    btnVideo.layer.cornerRadius = BtnWidthAndHeight / 2;
    btnVideo.clipsToBounds = YES;
    btnVideo.layer.borderColor = [[UIColor colorWithRed:85/255.0 green:85/255.0 blue:86/255.0 alpha:1.0] CGColor];;
    btnVideo.layer.borderWidth = 1;
    
    btnVideo.backgroundColor = [UIColor clearColor];
    btnVideo.tag = 4*100000;
    
    // 设置标题
    [btnVideo setTitle:@"视频" forState:UIControlStateNormal];
    [btnVideo setTitleColor:FUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    
    [btnVideo addTarget:self action:@selector(btnVideoClick:) forControlEvents:UIControlEventTouchUpInside];
    btnVideo.alpha = 0.5;
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if (viewController.tabBarController.selectedIndex ==0) {
//        UINavigationController *navigation =(UINavigationController *)viewController;
//        ZFTableViewController *notice=(ZFTableViewController *)navigation.topViewController;
//        [notice downRefresh];
    }
    if (viewController.tabBarController.selectedIndex ==1) {
//        UINavigationController *navigation =(UINavigationController *)viewController;
//        FindViewController *notice=(FindViewController *)navigation.topViewController;
        // 先请求推荐用户接口,看是否有推荐用户
//        [notice initDataForTuiJianUser];
        // 获取全部标签
//        [notice getAllBiaoQian];
    }
    if (viewController.tabBarController.selectedIndex ==4) {
//        UINavigationController *navigation =(UINavigationController *)viewController;
//        MineViewController *notice=(MineViewController *)navigation.topViewController;
//        [notice start1];
    }
}
//禁止tab多次点击
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    UIViewController *tbselect=tabBarController.selectedViewController;
    if([tbselect isEqual:viewController]){
        return NO;
    }
    return YES;
}



// 发文字
- (void) btnTextClick:(UIButton *)btnText {
    
    NSLog(@"发文字");
    
    PublishTextViewController * vc = [[PublishTextViewController alloc] init];
    
    [self presentViewController:vc animated:YES completion:^{
        
        // 跳转完成 控制三个按钮回原位
        [self moveButtonToOriginalPlace];
        
    }];
}

// 发图片
- (void) btnPictureClick:(UIButton *)btnPicture {
    
    NSLog(@"发图片");
    
    
    PublishPhotoViewController *vc = [[PublishPhotoViewController alloc] init];
    
    [self presentViewController:vc animated:YES completion:^{
        
        // 跳转完成 控制三个按钮回原位
        [self moveButtonToOriginalPlace];
        
    }];
}

// 发视频
- (void) btnVideoClick:(UIButton *) btnVideo {
    
    NSLog(@"发视频");
    
    
    PublishVideoViewController *vc = [[PublishVideoViewController alloc] init];
    [self presentViewController:vc animated:YES completion:^{
        
        // 跳转完成 控制三个按钮回原位
        [self moveButtonToOriginalPlace];
    }];
    
}

// 控制三个按钮回原位
- (void) moveButtonToOriginalPlace {
    
    // 获取到三个按钮
    UIButton *btnText = [self.view viewWithTag:2*100000];
    UIButton *btnPicture = [self.view viewWithTag:3*100000];
    UIButton *btnVideo = [self.view viewWithTag:4*100000];
    
    // 视频按钮改变位置
    btnVideo.frame = CGRectMake(SpaceWidth * 3 + BtnWidthAndHeight * 2, H, BtnWidthAndHeight, BtnWidthAndHeight);
    btnVideo.alpha = 0.5;
    // 图片按钮改变位置
    btnPicture.frame = CGRectMake(SpaceWidth*2 + BtnWidthAndHeight, H, BtnWidthAndHeight, BtnWidthAndHeight);
    btnPicture.alpha = 0.5;
    // 文字按钮改变位置
    btnText.frame = CGRectMake(SpaceWidth, H, BtnWidthAndHeight, BtnWidthAndHeight);
    btnText.alpha = 0.5;
    
    
    // 旋转动画
    UIImageView *closeImgView = [self.view viewWithTag:123];
    [UIView animateWithDuration:0.25 animations:^{
        closeImgView.transform=CGAffineTransformMakeRotation(- M_PI_4);
    }];
    // 关闭label
    UILabel *closeLb = [self.view viewWithTag:124];
    [UIView animateWithDuration:0.15 animations:^{
        closeLb.size = CGSizeMake(0, 0);
        closeLb.centerX = self.tabBar.centerX;
    }];
    
}


// 发布点击事件
- (void)publishBtnClick:(UIButton *)publishBtn {
    
    [self.view addSubview:_zhezhaoUv];
    
    // 让发布按钮图片/文字消失
//    [_publishBtn setTitle:@"" forState:UIControlStateNormal];
    
    // 旋转动画
    UIImageView *closeImgView = [self.view viewWithTag:123];
    if (xuanzhuanNum == 0) {
        [UIView animateWithDuration:0.25 animations:^{
            closeImgView.transform=CGAffineTransformMakeRotation(M_PI_2);
        }];
        xuanzhuanNum ++;
    }else {
        
        [UIView animateWithDuration:0.25 animations:^{
            closeImgView.transform=CGAffineTransformMakeRotation(M_PI * 8);
        }];
    }
    
    // 关闭label
    UILabel *closeLb = [self.view viewWithTag:124];
    [UIView animateWithDuration:0.15 animations:^{
        closeLb.size = CGSizeMake(22, 11);
        closeLb.centerX = self.tabBar.centerX;
    }];
    
    
    
    
    self.view.userInteractionEnabled = NO;
    
    // 获取到遮罩层
    UIView *zhezhaoUv = [self.view viewWithTag:1*100000];
    UIButton *btnText = [self.view viewWithTag:2*100000];
    
    // 显示
    zhezhaoUv.hidden = NO;
    // 改变透明度
    [UIView animateWithDuration:0.15f animations:^{
        UIColor *color = [UIColor blackColor];
        zhezhaoUv.backgroundColor = [color colorWithAlphaComponent:0.3];
    } completion:^(BOOL finished) {
        
        // 控制第二个按钮开始动
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(btnPictureStart) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        [UIView animateWithDuration:0.15f animations:^{
            
            // 改变位置
            btnText.frame = CGRectMake(SpaceWidth, (1 - 0.2) * H - BtnWidthAndHeight, BtnWidthAndHeight, BtnWidthAndHeight);
            btnText.alpha = 1.0;
        }];
    }];
}

// 控制第二个按钮出现
- (void) btnPictureStart {
    
    UIButton *btnPicture = [self.view viewWithTag:3*100000];
    
    [UIView animateWithDuration:0.15f animations:^{
        
        // 控制第三个按钮开始动
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(btnVideoStart) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        // 改变位置
        btnPicture.frame = CGRectMake(SpaceWidth * 2 + BtnWidthAndHeight, (1 - 0.2) * H - BtnWidthAndHeight, BtnWidthAndHeight, BtnWidthAndHeight);
        btnPicture.alpha = 1.0;
    }];
}

// 控制第三个按钮出现
- (void) btnVideoStart {
    
    UIButton *btnVideo = [self.view viewWithTag:4*100000];
    
    [UIView animateWithDuration:0.15f animations:^{
        
        // 改变位置
        btnVideo.frame = CGRectMake(SpaceWidth * 3 + BtnWidthAndHeight*2, (1 - 0.2) * H - BtnWidthAndHeight, BtnWidthAndHeight, BtnWidthAndHeight);
        btnVideo.alpha = 1.0;
    }completion:^(BOOL finished) {
        
        // 打开用户可操作
        self.view.userInteractionEnabled = YES;
    }];
}

// 点击视图
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 旋转动画
    UIImageView *closeImgView = [self.view viewWithTag:123];
    [UIView animateWithDuration:0.25 animations:^{
        closeImgView.transform=CGAffineTransformMakeRotation(- M_PI_4);
    }];
    // 关闭label
    UILabel *closeLb = [self.view viewWithTag:124];
    [UIView animateWithDuration:0.15 animations:^{
        closeLb.size = CGSizeMake(0, 0);
        closeLb.centerX = self.tabBar.centerX;
    }];
    
    // 遮罩层
    UIView *zhezhaoUv = [self.view viewWithTag:1*100000];
    UIButton *btnVideo = [self.view viewWithTag:4*100000];
    
    [UIView animateWithDuration:0.15f animations:^{
        
        // 控制第二个按钮回原位置
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(btnPictureEnd) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        btnVideo.frame = CGRectMake(SpaceWidth * 3 + BtnWidthAndHeight * 2, H, BtnWidthAndHeight, BtnWidthAndHeight);
        btnVideo.alpha = 0.5;
        
    }completion:^(BOOL finished) {
        
        // 改变透明度
        [UIView animateWithDuration:0.15f animations:^{
            UIColor *color = [UIColor blackColor];
            zhezhaoUv.backgroundColor = [color colorWithAlphaComponent:0.1];
        } completion:^(BOOL finished) {
            
            // 隐藏
            zhezhaoUv.hidden = YES;
        }];
    }];
    
}

// 控制第二个按钮回原位置
- (void) btnPictureEnd {
    
    UIButton *btnPicture = [self.view viewWithTag:3*100000];
    
    [UIView animateWithDuration:0.15f animations:^{
        
        // 控制第一个按钮回原位置
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(btnTextEnd) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        // 改变位置
        btnPicture.frame = CGRectMake(SpaceWidth*2 + BtnWidthAndHeight, H, BtnWidthAndHeight, BtnWidthAndHeight);
        btnPicture.alpha = 0.5;
    }];
}

// 控制第一个按钮回原位置
- (void) btnTextEnd {
    
    UIButton *btnText = [self.view viewWithTag:2*100000];
    
    [UIView animateWithDuration:0.15f animations:^{
        
        // 改变位置
        btnText.frame = CGRectMake(SpaceWidth, H, BtnWidthAndHeight, BtnWidthAndHeight);
        btnText.alpha = 0.5;
    } completion:^(BOOL finished) {
        
        // 设置发布按钮文字/图片
//        [_publishBtn setTitle:@"+" forState:UIControlStateNormal];
    }];
}


// 视图即将显示
- (void)viewWillAppear:(BOOL)animated {
    
    self.delegate = self;
    
    UIView *uv = [self.view viewWithTag:1*100000];
    
    if (uv.hidden == NO) {
        
        uv.hidden = YES;
    }
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
