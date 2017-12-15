//
//  MineViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/7/26.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "MineViewController.h"
#import "TISpringLoadedSpinnerView.h"   // 头像的弹簧效果
#import "TISpringLoadedView.h"   // 头像的弹簧效果
#import "LLSegmentBarVC.h" // 分页栏
#import "MinePostViewController.h" // 我发的帖子页面
#import "MineLikeViewController.h" // 我的喜欢页面
#import "MineFocusViewController.h" // 我的关注页面
#import "ZLShowBigImage.h" // 点击查看单张大图
#import "MineFocusCell.h"
#import "SheZhiViewController.h" // 设置页面
#import "LoginViewController.h" // 登录页面

#import "DongTaiViewController.h" // 动态

#import "ArtScrollView.h"




@interface MineViewController ()<UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    
    
    TISpringLoadedView * _springLoadedView;
    CADisplayLink * _displayLink;
    
    
    BOOL isIconImg;  // 用于判断修改的是背景图还是头像
    
    NSInteger _barSelectIndex;
    
    
    MinePostViewController *minePost;
    MineLikeViewController *mineLike;
    MineFocusViewController *mineFocus;
}

@property (nonatomic, copy) ArtScrollView *bigScrollView; //底层滚动图
@property (nonatomic, copy) UIImageView *topImgView; //顶部头像背景图
@property (nonatomic, copy) UIImageView *touxiangView; // 头像

@property (nonatomic, copy) UILabel *nickNameLb; // 昵称

@property (nonatomic, copy) UILabel *signtextLb; // 个性签名

@property (nonatomic,weak) LLSegmentBarVC * segmentVC; // 分页栏


@property (nonatomic, strong, nullable) UIRefreshControl *refreshControl;//刷新控件



@end

@implementation MineViewController


// lazy init懒加载
- (LLSegmentBarVC *)segmentVC{
    if (!_segmentVC) {
        LLSegmentBarVC *vc = [[LLSegmentBarVC alloc] init];
        // 添加到到控制器
        [self addChildViewController:vc];
        _segmentVC = vc;
    }
    return _segmentVC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 布局页面
    [self layoutView];
    
    // 获取用户资料数据
    [self initDataWithUserInfo];
    
    isIconImg = YES;
}

// 获取用户资料数据
- (void) initDataWithUserInfo {
    
    // 用户单利
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    // 获取到用户RSAKey
    NSString *userRsaPublicKey = [user objectForKey:@"severPublicKey"];
    
    
    // 生成一个16位的AES的key,并保存用于解密服务器返回的信息
    NSString *strAESkey = [NSString set32bitString:16];
    [user setObject:strAESkey forKey:@"aesKey"];
    // 最终加密好的key参数的密文
    NSString *keyMiWenStr = [RSAEncryptor encryptString:strAESkey publicKey:userRsaPublicKey];
    NSLog(@"keyMiWenStr:%@",keyMiWenStr);
    
    
    // 获取当前时间戳，转换成json类型，并用AES进行加密,并做了base64及urlcode转码处理
    NSDate *senddate = [NSDate date];
    NSString *date2 = [NSString stringWithFormat:@"%ld", (long)[senddate timeIntervalSince1970]];
    NSDictionary *cgDic = @{@"requestTime":date2};
    // 最终加密好的cg参数的密文
    NSString *cgMiWenStr = [[MakeJson createJson:cgDic] AES128EncryptWithKey:strAESkey];
    
    NSLog(@"cgMiWenStr:%@",cgMiWenStr);
    
    // 用户token
    NSString *userToken = [user objectForKey:@"token"];
    NSLog(@"userToken%@",userToken);
    
    
    NSDictionary *dicGetUserInfoData = @{@"uid":@""};
    NSString *strJiaMiGetUserInfoData = [[MakeJson createJson:dicGetUserInfoData] AES128EncryptWithKey:strAESkey];
    
    // 用于最终获取用户资料需要的Dic
    NSDictionary *dicForData = @{@"tk":userToken,@"key":keyMiWenStr,@"cg":cgMiWenStr,@"data":strJiaMiGetUserInfoData};
    NSLog(@"dicForData::::%@",dicForData);
    
    
    // 请求用户资料
    HttpRequest *http = [[HttpRequest alloc] init];
    
    [http PostUserInfoWithDic:dicForData Success:^(id userInfo) {
        
        NSDictionary *dicForUserInfo = [MakeJson createDictionaryWithJsonString:userInfo];
        
        // 将用户资料保存本地
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:dicForUserInfo forKey:@"userInfo"];
        
        // 修改昵称
        _nickNameLb.text = [NSString stringWithFormat:@"%@",[dicForUserInfo objectForKey:@"nickname"]];
        if ([_nickNameLb.text isEqualToString:@""]) {
            _nickNameLb.text = @"暂未设置昵称";
        }
        
        // 修改个性签名
        _signtextLb.text = [dicForUserInfo objectForKey:@"sign"];
        if ([_signtextLb.text isEqualToString:@""]) {
            _signtextLb.text = @"暂未设置签名...";
        }
        
        // 用户图片数组
        if ([[dicForUserInfo objectForKey:@"img"] isKindOfClass:[NSArray class]]) {
            _touxiangView.image = [UIImage imageNamed:@"账户管理_默认头像"];
            _topImgView.image = [UIImage imageNamed:@"personal_bg"];
        }else {
            
            // 修改头像
            [_touxiangView sd_setImageWithURL:[NSURL URLWithString:[[dicForUserInfo objectForKey:@"img"] valueForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
            
            // 修改背景图
            [_topImgView sd_setImageWithURL:[NSURL URLWithString:[[dicForUserInfo objectForKey:@"img"] valueForKey:@"background"]] placeholderImage:[UIImage imageNamed:@"personal_bg"]];
        }
        
    } failure:^(NSError *error) {
        
        // 请求失败
    }];
    
}

// 下拉刷新
- (void) start1 {
    
    _barSelectIndex = self.segmentVC.segmentBar.selectIndex;
    
    NSLog(@"刷新刷新刷新");
    
    
    // 用户资料还没有
    if (_nickNameLb.text == nil) {
        // 获取用户资料
        [self initDataWithUserInfo];
    }
    
    
    NSArray *items = @[@"帖子", @"喜欢", @"关注"];
    minePost = [[MinePostViewController alloc] init];
    mineLike = [[MineLikeViewController alloc] init];
    mineFocus = [[MineFocusViewController alloc] init];
    [self.segmentVC setUpWithItems:items childVCs:@[minePost,mineLike,mineFocus]];
    self.segmentVC.segmentBar.selectIndex = _barSelectIndex;
    
    [self.refreshControl endRefreshing];
}


// 布局页面
- (void) layoutView {
    
    // 底层滚动图
    _bigScrollView = [[ArtScrollView alloc] init];
    [self.view addSubview:_bigScrollView];
    [_bigScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.height.equalTo(@(H));
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        
    }];
    //    _bigScrollView.showsVerticalScrollIndicator = NO;//竖向滚动条
    _bigScrollView.showsHorizontalScrollIndicator = NO; // 横向滚动条
    _bigScrollView.backgroundColor = [UIColor whiteColor];
    
    
    // ios10新特性 自带刷新控件
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];//控制菊花的颜色
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"松手刷新"];
    self.refreshControl.attributedTitle = string; // 菊花下面的文字，可利用NSAttributedString设置各种文字属性
    [_bigScrollView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(start1) forControlEvents:(UIControlEventValueChanged)]; // 刷新方法
    // 注：1.默认的高度和宽度 2.原来只适用于UITableViewController3.当拉动刷新时，UIRefreshControl将在UIControlEventValueChanged事件下被触发
    
    
    
    // 顶部个人中心背景
    _topImgView = [[UIImageView alloc] init];
    [_bigScrollView addSubview:_topImgView];
    [_topImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bigScrollView).with.offset(- 20);
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        make.height.equalTo(@(W * 0.78125));
    }];
    _topImgView.image = [UIImage imageNamed:@"personal_bg.jpeg"];
    _topImgView.userInteractionEnabled = YES;
    // 遮罩层
    UIImageView *topzhezhaoImgView = [[UIImageView alloc] init];
    [_topImgView addSubview:topzhezhaoImgView];
    [topzhezhaoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_topImgView);
        make.left.equalTo(_topImgView);
        make.width.equalTo(_topImgView);
        make.height.equalTo(_topImgView);
    }];
    topzhezhaoImgView.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:0.5];
    topzhezhaoImgView.userInteractionEnabled = YES;
    // 点击事件（修改头像背景图或查看大图）
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeTopImgView)];
    [topzhezhaoImgView addGestureRecognizer:tapGesturRecognizer];
    
    
    // W * 0.78125 是顶部视图的高度
    _bigScrollView.contentSize = CGSizeMake(W, H + W * 0.78125 - W * 0.78125 * 0.13 - 64 + 20 - 2);
    
    
    // 设置按钮
    UIButton *setUpBtn = [[UIButton alloc] init];
    [_bigScrollView addSubview:setUpBtn];
    [setUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bigScrollView);
        make.right.equalTo(self.view);
        make.width.equalTo(@(100));
        make.height.equalTo(@(46));
    }];
    setUpBtn.titleLabel.sd_layout
    .rightSpaceToView(setUpBtn, 19)
    .centerYEqualToView(setUpBtn)
    .widthIs(29)
    .heightIs(13);
    setUpBtn.imageView.sd_layout
    .rightSpaceToView(setUpBtn.titleLabel, 5)
    .centerYEqualToView(setUpBtn)
    .widthIs(14)
    .heightIs(14);
    [setUpBtn setImage:[UIImage imageNamed:@"personal_icon3"] forState:UIControlStateNormal];
    [setUpBtn setTitle:@"设置" forState:UIControlStateNormal];
    [setUpBtn setTitleColor:FUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    setUpBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [setUpBtn addTarget:self action:@selector(setUpBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    

    // 头像的宽高
    CGFloat touxiangWandH = W * 0.228125;
    
    
    // 昵称
    _nickNameLb = [[UILabel alloc] init];
    [_topImgView addSubview:_nickNameLb];
    [_nickNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topImgView).with.offset(3 * W * 0.78125 / 50 + 0.406 * W * 0.78125 + touxiangWandH / 2);
        make.centerX.equalTo(_topImgView);
        make.height.equalTo(@(16));
    }];
    _nickNameLb.textColor = FUIColorFromRGB(0xffffff);
    _nickNameLb.font = [UIFont systemFontOfSize:16];
    
    // 个性签名
    _signtextLb = [[UILabel alloc] init];
    [_topImgView addSubview:_signtextLb];
    [_signtextLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nickNameLb.mas_bottom).with.offset(W * 0.78125 * 0.032);
        make.centerX.equalTo(_topImgView);
        make.height.equalTo(@(14));
    }];
    _signtextLb.textColor = [UIColor colorWithRed:152/255.0 green:153/255.0 blue:154/255.0 alpha:1.0];
    _signtextLb.font = [UIFont systemFontOfSize:14];
    
    
    [_bigScrollView layoutIfNeeded];
    
    // 分页栏
    // 1 设置segmentBar的frame
    [_topImgView addSubview:self.segmentVC.segmentBar];
    self.segmentVC.segmentBar.sd_layout
    .bottomEqualToView(_topImgView)
    .leftEqualToView(self.view)
    .heightIs(W * 0.78125 * 0.13)
    .widthIs(W);
    
    
    // 2 添加控制器的View
    self.segmentVC.view.frame = CGRectMake(0, W * 0.78125 - 20,_bigScrollView.frame.size.width, _bigScrollView.frame.size.height - 49 - 25 - W * 0.78125 * 0.13);
    [_bigScrollView addSubview:self.segmentVC.view];
    
    NSArray *items = @[@"帖子", @"喜欢", @"关注"];
    minePost = [[MinePostViewController alloc] init];
    mineLike = [[MineLikeViewController alloc] init];
    mineFocus = [[MineFocusViewController alloc] init];
    
    
    // 3 添加标题数组和控住器数组
    [self.segmentVC setUpWithItems:items childVCs:@[minePost,mineLike,mineFocus]];
    
    
    // 4  配置基本设置  可采用链式编程模式进行设置
    [self.segmentVC.segmentBar updateWithConfig:^(LLSegmentBarConfig *config) {
        config.itemNormalColor([UIColor colorWithRed:152/255.0 green:153/255.0 blue:154/255.0 alpha:1.0]).itemSelectColor([UIColor colorWithRed:250/255.0 green:171/255.0 blue:45/255.0 alpha:1.0]).indicatorColor([UIColor colorWithRed:250/255.0 green:171/255.0 blue:45/255.0 alpha:1.0]);
    }];
    
    
    // 分割线
    for (int i = 0; i < 2; i++) {
        
        UILabel *lbFenGe = [[UILabel alloc] init];
        [_topImgView addSubview:lbFenGe];
        [lbFenGe mas_makeConstraints:^(MASConstraintMaker *make) {
            if (iPhone6SP) {
                make.centerY.equalTo(self.segmentVC.segmentBar).with.offset(- 7);
            }else if (iPhone6S) {
                
                make.centerY.equalTo(self.segmentVC.segmentBar).with.offset(- 5);
            }else if (iPhone5S){
                
                make.centerY.equalTo(self.segmentVC.segmentBar).with.offset(- 3);
            }else {
                make.centerY.equalTo(self.segmentVC.segmentBar).with.offset(- 1);
            }
            make.left.equalTo(self.view).with.offset(W / 3 * (i+1) - 0.4);
            make.width.equalTo(@(0.8));
            make.height.equalTo(@(W * 0.78125 * 0.13 / 2 - 8));
        }];
        lbFenGe.backgroundColor = [UIColor whiteColor];
    }
    
    
    _bigScrollView.delegate = self;
    
    // 弹簧头像
    [self createTouxiang];
    
}

// 滚动视图代理事件（用于显示和隐藏topNavView）
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat minAlphaOffset = self.segmentVC.segmentBar.frame.origin.y;
    CGFloat offset = scrollView.contentOffset.y;
    
    if (offset > minAlphaOffset - self.segmentVC.segmentBar.frame.size.height || offset == minAlphaOffset - self.segmentVC.segmentBar.frame.size.height) {
        
        // 发送通知,用于修改资料
        // 创建消息中心
        NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
        // 在消息中心发布自己的消息
        [notiCenter postNotificationName:@"xiugaiScroll1" object:@"11"];
    }
}

// 设置的点击事件
- (void) setUpBtnClick {
    
    // 点击了设置
    SheZhiViewController *vc = [[SheZhiViewController alloc] init];
    // 隐藏底边栏
    [vc setHidesBottomBarWhenPushed:YES];
    // 跳转
    [self.navigationController pushViewController:vc animated:YES];
}



- (void) createTouxiang {
    
    // 头像的宽高
    CGFloat touxiangWandH = W * 0.228125;
    
    // 头像弹簧效果
    _springLoadedView = [[TISpringLoadedView alloc] initWithFrame:CGRectMake(0, 0, touxiangWandH, touxiangWandH)];
    _springLoadedView.center = CGPointMake(CGRectGetMidX(self.view.bounds), 0.406 * W * 0.78125);
    [_springLoadedView setRestCenter:CGPointMake(CGRectGetMidX(self.view.bounds), 0.406 * W * 0.78125)]; // Set where the view should spring back to.
    [_springLoadedView setSpringConstant:700]; // Set a spring constant. Effectively, as you increase this, the speed at which the spring returns to rest increases
    [_springLoadedView setDampingCoefficient:15]; // A damping coefficient. Shouldn't be negative or you'll bounce off screen.
    [_springLoadedView setInheritsPanVelocity:YES]; // Setting to YES allows you to throw the view. Doesn't play nice with panDistanceLimits.
    [_springLoadedView setBackgroundColor:[UIColor clearColor]];
    _springLoadedView.layer.cornerRadius = touxiangWandH / 2;
    _springLoadedView.clipsToBounds = YES;
    _springLoadedView.userInteractionEnabled = YES;
    [_topImgView addSubview:_springLoadedView];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:(id)kCFRunLoopCommonModes];
    
    // 头像
    _touxiangView = [[UIImageView alloc] init];
    [_springLoadedView addSubview:_touxiangView];
    [_touxiangView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_springLoadedView);
        make.centerY.equalTo(_springLoadedView);
        make.width.equalTo(_springLoadedView);
        make.height.equalTo(_springLoadedView);
    }];
    _touxiangView.image = [UIImage imageNamed:@"账户管理_默认头像"];
    _touxiangView.layer.cornerRadius = touxiangWandH / 2;
    _touxiangView.layer.borderColor = [[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5] CGColor];
    _touxiangView.clipsToBounds = YES;
    _touxiangView.layer.borderWidth = 1.5;
    _touxiangView.userInteractionEnabled = YES;
    // 点击事件（修改头像或查看大图）
    UITapGestureRecognizer *tapGesturRecognizer1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changetouxiangImgView)];
    [_touxiangView addGestureRecognizer:tapGesturRecognizer1];
    //    // 头像加拖拽手势
    //    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(touxiangPanAction:)];
    //    [_touxiangView addGestureRecognizer:panGR];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [_springLoadedView setRestCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))];
}


- (void)displayLinkTick:(CADisplayLink *)link {
    
//    [_spinnerView simulateSpringWithDisplayLink:link];
    [_springLoadedView simulateSpringWithDisplayLink:link];
}


// 修改头像或查看大图
- (void) changetouxiangImgView {
        
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"查看头像大图", @"修改当前头像",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
    actionSheet.delegate = self;
    actionSheet.tag = 20; // 用于和头像背景图进行区分
}

// 修改头像背景图或查看大图
- (void) changeTopImgView {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"查看背景图", @"修改背景图",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
    actionSheet.delegate = self;
    actionSheet.tag = 10; // 用于和头像进行区分
}

// 点击事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (actionSheet.tag) {
        case 10:
        {
            if (buttonIndex == 0) {
                
                // 打印
                NSLog(@"查看背景图");
                [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(bigBackImg) userInfo:nil repeats:NO];
                
            }else if (buttonIndex == 1) {
                
                isIconImg = NO;
                
                // 打印
                NSLog(@"修改背景图");
                UIAlertController *actionController = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        
                        // 实现照相功能
                        // 类型Camera
                        [self loadImageWithType:UIImagePickerControllerSourceTypeCamera];
                        
                    }else {
                        
                        NSLog(@"抱歉,暂时不能照相");
                        // 给用户提示
                        [self showMessage:@"不支持照相功能"];
                    }
                    
                    
                }];
                [actionController addAction:action1];
                
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    // 相册取照片 和照相相似  只需修改类型  类型为PhotoLabrary
                    [self loadImageWithType:UIImagePickerControllerSourceTypePhotoLibrary];
                    
                }];
                [actionController addAction:action2];
                
                UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    NSLog(@"取消");
                }];
                
                [actionController addAction:action3];
                
                [self presentViewController:actionController animated:YES completion:nil];
                
            }else {
                
                // 取消
                NSLog(@"取消");
            }
        }
            break;
        case 20:
        {
            if (buttonIndex == 0) {
                
                // 打印
                NSLog(@"查看头像大图");
                [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(bigIcon) userInfo:nil repeats:NO];
                
                
            }else if (buttonIndex == 1) {
                
                isIconImg = YES;
                
                // 打印
                NSLog(@"修改当前头像");
                UIAlertController *actionController = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        
                        // 实现照相功能
                        // 类型Camera
                        [self loadImageWithType:UIImagePickerControllerSourceTypeCamera];
                        
                    }else {
                        
                        NSLog(@"抱歉,暂时不能照相");
                        // 给用户提示
                        [self showMessage:@"不支持照相功能"];
                    }
                    
                    
                }];
                [actionController addAction:action1];
                
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    // 相册取照片 和照相相似  只需修改类型  类型为PhotoLabrary
                    [self loadImageWithType:UIImagePickerControllerSourceTypePhotoLibrary];
                    
                }];
                [actionController addAction:action2];
                
                UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    NSLog(@"取消");
                }];
                
                [actionController addAction:action3];
                
                [self presentViewController:actionController animated:YES completion:nil];
                
            }else {
                
                // 取消
                NSLog(@"取消");
            }
        }
            break;
            
        default:
            break;
    }
}


// 先让弹出框消失再显示背景大图
- (void) bigBackImg {
    
    [ZLShowBigImage showBigImage:_topImgView];
}

// 先让弹出框消失再显示头像大图
- (void)bigIcon {
    
    [ZLShowBigImage showBigImage:_touxiangView];
}

// 加载照片
- (void)loadImageWithType:(UIImagePickerControllerSourceType)type {
    
    // 创建UIImagePickerController对象
    UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
    // 设置资源类型
    imagePC.sourceType = type;
    // 设置是否可以后续操作
    imagePC.allowsEditing = YES;
    // 设置代理
    imagePC.delegate = self;
    
    // 一般都采用模态视图跳转方式
    [self presentViewController:imagePC animated:YES completion:^{
        
        NSLog(@"跳转完成");
    }];
}
// 提示框
- (void)showMessage:(NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
}

#pragma mark - UIImagePickerControllerDelegate -
// 点击choose完成按钮实现的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // 选取资源类型 这里是Media类型
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    // 判断当前的图片是普通图片 public.image
    if ([type isEqualToString:@"public.image"]) {
        // 选取图片 根据类型EditedImage 这个key得到图片image
        
        // 压缩大小
//        UIImage *yasuoDaXiaoImg = [self scaleToSize:[info objectForKey:UIImagePickerControllerEditedImage] size:CGSizeMake(200,200)];
        
        // colorWithPatternImage:这个方法理解为  将image转成Color
        UIImage *yasuoImg = [self imageData:[info objectForKey:UIImagePickerControllerEditedImage]];
        
        
        if (isIconImg == YES) {
            
            // 上传头像
            // 创建单例,获取到用户RSAKey
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSString *userRsaPublicKey = [user objectForKey:@"severPublicKey"];
            
            // 生成一个16位的AES的key,并保存用于解密服务器返回的信息
            NSString *strAESkey = [NSString set32bitString:16];
            [user setObject:strAESkey forKey:@"aesKey"];
            // 最终加密好的key参数的密文
            NSString *keyMiWenStr = [RSAEncryptor encryptString:strAESkey publicKey:userRsaPublicKey];
            
            // 获取当前时间戳，转换成json类型，并用AES进行加密,并做了base64及urlcode转码处理
            NSDate *senddate = [NSDate date];
            NSString *date2 = [NSString stringWithFormat:@"%ld", (long)[senddate timeIntervalSince1970]];
            NSDictionary *cgDic = @{@"requestTime":date2};
            // 最终加密好的cg参数的密文
            NSString *cgMiWenStr = [[MakeJson createJson:cgDic] AES128EncryptWithKey:strAESkey];
            
            // 用户token
            NSString *userToken = [user objectForKey:@"token"];
            
            
            NSDictionary *dataDic = @{@"type":@"icon"};
            NSString *dataMiWenStr = [[MakeJson createJson:dataDic] AES128EncryptWithKey:strAESkey];
            
            
            // 创建要发送的字典
            NSDictionary *dicData = @{@"tk":userToken,@"key":keyMiWenStr,@"cg":cgMiWenStr,@"data":dataMiWenStr};
            NSLog(@"%@",dicData);
            
            
            HttpRequest *http = [[HttpRequest alloc] init];
            [http testUploadImageWithPost:dicData andImg:yasuoImg Success:^(id arrForDetail) {
                
                if ([arrForDetail isKindOfClass:[NSString class]] && [arrForDetail isEqualToString:@"0"]) {
                    
                    // 修改失败
                    [MBHUDView hudWithBody:@"修改失败" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                    
                }else {
                    
                    // 上传成功
                    [MBHUDView hudWithBody:@"修改成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                    
                    
                    // 修改头像成功
                    _touxiangView.image = yasuoImg;
                }
                
            } failure:^(NSError *error) {
                
                
            }];
            
        }else {
            
            
            // 上传背景图
            // 创建单例,获取到用户RSAKey
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSString *userRsaPublicKey = [user objectForKey:@"severPublicKey"];
            
            // 生成一个16位的AES的key,并保存用于解密服务器返回的信息
            NSString *strAESkey = [NSString set32bitString:16];
            [user setObject:strAESkey forKey:@"aesKey"];
            // 最终加密好的key参数的密文
            NSString *keyMiWenStr = [RSAEncryptor encryptString:strAESkey publicKey:userRsaPublicKey];
            
            // 获取当前时间戳，转换成json类型，并用AES进行加密,并做了base64及urlcode转码处理
            NSDate *senddate = [NSDate date];
            NSString *date2 = [NSString stringWithFormat:@"%ld", (long)[senddate timeIntervalSince1970]];
            NSDictionary *cgDic = @{@"requestTime":date2};
            // 最终加密好的cg参数的密文
            NSString *cgMiWenStr = [[MakeJson createJson:cgDic] AES128EncryptWithKey:strAESkey];
            
            // 用户token
            NSString *userToken = [user objectForKey:@"token"];
            
            
            NSDictionary *dataDic = @{@"type":@"background"};
            NSString *dataMiWenStr = [[MakeJson createJson:dataDic] AES128EncryptWithKey:strAESkey];
            
            
            // 创建要发送的字典
            NSDictionary *dicData = @{@"tk":userToken,@"key":keyMiWenStr,@"cg":cgMiWenStr,@"data":dataMiWenStr};
            NSLog(@"%@",dicData);
            
            
            HttpRequest *http = [[HttpRequest alloc] init];
            [http testUploadImageWithPost:dicData andImg:yasuoImg Success:^(id arrForDetail) {
                
                if ([arrForDetail isKindOfClass:[NSString class]] && [arrForDetail isEqualToString:@"0"]) {
                    
                    // 修改失败
                    [MBHUDView hudWithBody:@"修改失败" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                    
                }else {
                    
                    // 上传成功
                    [MBHUDView hudWithBody:@"修改成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                    
                    
                    // 上传背景图
                    _topImgView.image = yasuoImg;
                }
                
            } failure:^(NSError *error) {
                
                
            }];
            
        }
        
        
        
    }
    // 跳回去  必须要加  否则用户无法跳回应用
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"返回完成");
    }];
    
}

// 点击cancel取消按钮时执行的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    NSLog(@"取消");
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"返回完成");
    }];
}


// 压缩图片大小
- (UIImage *)imageData:(UIImage *)myimage
{
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    if (data.length>100*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.3);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(myimage, 0.5);
        }else if (data.length>200*1024) {//0.25M-0.5M
            data=UIImageJPEGRepresentation(myimage, 0.9);
        }
    }
    
    UIImage *img = [UIImage imageWithData:data];
    
    return img;
}

// 压缩图片
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}




// 监听处理事件
- (void)listen:(NSNotification *)noti {

    NSString *strNoti = noti.object;
    
    // 用户资料修改了，在此修改头像和昵称
    if ([strNoti isEqualToString:@"2"]) {
        
        // 重新获取用户资料数据
        [self initDataWithUserInfo];
        
        // 销毁用户修改了资料的通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reviseUserInfo" object:@"2"];
    }
    
    
    // 登陆成功，在此修改头像和昵称
    if ([strNoti isEqualToString:@"3"]) {
        
        // 重新获取用户资料数据
        [self initDataWithUserInfo];
        
        // 重新加载页面
        [self start1];
        
        // 销毁通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginSuccess" object:@"3"];
    }
    
    
    // 注册成功，在此修改头像和昵称
    if ([strNoti isEqualToString:@"4"]) {
        
        // 重新获取用户资料数据
        [self initDataWithUserInfo];
        
        // 重新加载页面
        [self start1];
        
        // 销毁通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"registerSuccess" object:@"4"];
    }
    
    // 修改当前页的滚动效果
    if ([strNoti isEqualToString:@"14"]) {
        
        _bigScrollView.scrollEnabled = YES;
    }
    
    if ([strNoti isEqualToString:@"15"]) {
        
        _bigScrollView.scrollEnabled = NO;
    }
}


// 界面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    // 用户资料还没有
    if (_nickNameLb.text == nil) {
        // 获取用户资料
        [self initDataWithUserInfo];
    }
    
    // 设置navgationController不透明
    self.navigationController.navigationBar.translucent = NO;
    
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // 接收消息
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    
    
    // 修改了用户资料,需要改头像和昵称
    [notiCenter addObserver:self selector:@selector(listen:) name:@"reviseUserInfo" object:@"2"];
    // 登录成功
    [notiCenter addObserver:self selector:@selector(listen:) name:@"loginSuccess" object:@"3"];
    // 注册成功
    [notiCenter addObserver:self selector:@selector(listen:) name:@"registerSuccess" object:@"4"];
    
    // 修改当前页的滚动状态
    [notiCenter addObserver:self selector:@selector(listen:) name:@"xiugaiScrollMine" object:@"14"];
    // 修改当前页的滚动状态
    [notiCenter addObserver:self selector:@selector(listen:) name:@"xiugaiScrollMineNo" object:@"15"];
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
