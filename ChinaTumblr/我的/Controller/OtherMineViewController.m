//
//  MineViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/7/26.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "OtherMineViewController.h"
#import "TISpringLoadedSpinnerView.h"   // 头像的弹簧效果
#import "TISpringLoadedView.h"   // 头像的弹簧效果
#import "LLSegmentBarVC.h" // 分页栏
#import "OtherPostViewController.h" // 我发的帖子页面
#import "OtherLikeViewController.h" // 我的喜欢页面
#import "OtherFocusViewController.h" // 我的关注页面
#import "ZLShowBigImage.h" // 点击查看单张大图
#import "MineFocusCell.h"
#import "SheZhiViewController.h" // 设置页面
#import "LoginViewController.h" // 登录页面

#import "DongTaiViewController.h" // 动态


#import "MineNavViewController.h"
#import "NoticeNavViewController.h"
#import "FindNavViewController.h"
#import "HomeNavViewController.h"



@interface OtherMineViewController ()<UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    
    NSInteger _barSelectIndex;
    
    TISpringLoadedView * _springLoadedView;
    CADisplayLink * _displayLink;
    
    
    BOOL isIconImg;  // 用于判断修改的是背景图还是头像
    
    NSString *_strShowPage; // 判断显示的页面
    
    UIButton *guanzhuBtn; // 关注按钮
    
    NSArray *_arrForAllLikeUserId;
    
    NSDictionary *dicForUserInfo;
}

@property (nonatomic, copy) UIScrollView *bigScrollView; //底层滚动图
@property (nonatomic, copy) UIImageView *topImgView; //顶部头像背景图
@property (nonatomic, copy) UIImageView *touxiangView; // 头像

@property (nonatomic, copy) UILabel *nickNameLb; // 昵称

@property (nonatomic, copy) UILabel *signtextLb; // 个性签名

@property (nonatomic,weak) LLSegmentBarVC * segmentVC; // 分页栏

@property (nonatomic, strong, nullable) UIRefreshControl *refreshControl;//刷新控件



@end

@implementation OtherMineViewController


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
    
    _arrForAllLikeUserId = [NSArray array];
    dicForUserInfo = [NSDictionary dictionary];
    
    // 获取数据并创建视图
    [self initDataWithUserInfo];
    
    isIconImg = YES;
}

// 获取用户资料数据
- (void) initDataWithUserInfo {
    
    // 获取用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    // 请求用户资料
    HttpRequest *http = [[HttpRequest alloc] init];
    
    
    NSDictionary *dic = @{@"uid":_userId};
    NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
    
    [http PostUserInfoWithDic:dicData Success:^(id userInfo) {
        
        if ([userInfo isEqualToString:@"0"]) {
            
            // 失败了,返回上一级
            [self.navigationController popViewControllerAnimated:YES];
            
        }else {
            
            dicForUserInfo = [MakeJson createDictionaryWithJsonString:userInfo];
            
            // 用于创建页面时
            _strShowPage = [dicForUserInfo objectForKey:@"show_page"];
            
            // 布局页面
            [self layoutView];
            
            
            NSDictionary *dicLikeAllList = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2]};
            // 获取是否已关注该用户
            // 获取用户所有关注的人的ID
            [http PostGetAllFollowUserIdListWithDic:dicLikeAllList Success:^(id userInfo) {
                
                if ([userInfo isEqualToString:@"error"]) {
                    
                    NSLog(@"FNJKDSAFNKDANFJKASNFJKADJFKAS");
                    guanzhuBtn.selected = NO;
                    guanzhuBtn.hidden = NO;
                    guanzhuBtn.userInteractionEnabled = YES;
                    
                    
                }else {
                    
                    // 拿到了
                    _arrForAllLikeUserId = [userInfo componentsSeparatedByString:@","];
        
                    if ([_arrForAllLikeUserId containsObject:[dicForUserInfo valueForKey:@"id"]]) {
                        guanzhuBtn.selected = YES;
                        guanzhuBtn.hidden = NO;
                        guanzhuBtn.userInteractionEnabled = YES;
                    }else {
                        guanzhuBtn.selected = NO;
                        guanzhuBtn.hidden = NO;
                        guanzhuBtn.userInteractionEnabled = YES;
                    }
                }
                
            } failure:^(NSError *error) {
                
                guanzhuBtn.selected = NO;
                guanzhuBtn.hidden = NO;
                guanzhuBtn.userInteractionEnabled = YES;
                
            }];
            
            
            
            
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
        }
        
    } failure:^(NSError *error) {
        
        // 请求失败
        // 失败了,返回上一级
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}

// 下拉刷新
- (void) start1 {
    
    // 用户资料还没有
    if (_nickNameLb.text == nil) {
        // 获取用户资料
        [self initDataWithUserInfo];
    }
    
    _barSelectIndex = self.segmentVC.segmentBar.selectIndex;
    
    if ([_strShowPage isEqualToString:@"0"]) {
        NSArray *items = @[@"帖子"];
        OtherPostViewController *minePost = [[OtherPostViewController alloc] init];
        minePost.userId1 = _userId;
        if ([self.navigationController isKindOfClass:[MineNavViewController class]]) {
            minePost.strNavIndex = @"4";
        }
        if ([self.navigationController isKindOfClass:[FindNavViewController class]]) {
            minePost.strNavIndex = @"1";
        }
        if ([self.navigationController isKindOfClass:[HomeNavViewController class]]) {
            minePost.strNavIndex = @"0";
        }
        if ([self.navigationController isKindOfClass:[NoticeNavViewController class]]) {
            minePost.strNavIndex = @"3";
        }
        [self.segmentVC setUpWithItems:items childVCs:@[minePost]];
    }
    if ([_strShowPage isEqualToString:@"2"]) {
        NSArray *items = @[@"帖子",@"喜欢"];
        OtherPostViewController *minePost = [[OtherPostViewController alloc] init];
        OtherLikeViewController *mineLike = [[OtherLikeViewController alloc] init];
        minePost.userId1 = _userId;
        mineLike.userId1 = _userId;
        if ([self.navigationController isKindOfClass:[MineNavViewController class]]) {
            mineLike.strNavIndex = @"4";
            minePost.strNavIndex = @"4";
        }
        if ([self.navigationController isKindOfClass:[FindNavViewController class]]) {
            mineLike.strNavIndex = @"1";
            minePost.strNavIndex = @"1";
        }
        if ([self.navigationController isKindOfClass:[HomeNavViewController class]]) {
            mineLike.strNavIndex = @"0";
            minePost.strNavIndex = @"0";
        }
        if ([self.navigationController isKindOfClass:[NoticeNavViewController class]]) {
            mineLike.strNavIndex = @"3";
            minePost.strNavIndex = @"3";
        }
        [self.segmentVC setUpWithItems:items childVCs:@[minePost,mineLike]];
    }
    NSLog(@"_strShowPage%@",_strShowPage);
    
    if ([_strShowPage isEqualToString:@"4"]) {
        NSArray *items = @[@"帖子",@"关注"];
        OtherPostViewController *minePost = [[OtherPostViewController alloc] init];
        OtherFocusViewController *minefocus = [[OtherFocusViewController alloc] init];
        minePost.userId1 = _userId;
        minefocus.userId1 = _userId;
        if ([self.navigationController isKindOfClass:[MineNavViewController class]]) {
            minePost.strNavIndex = @"4";
        }
        if ([self.navigationController isKindOfClass:[FindNavViewController class]]) {
            minePost.strNavIndex = @"1";
        }
        if ([self.navigationController isKindOfClass:[HomeNavViewController class]]) {
            minePost.strNavIndex = @"0";
        }
        if ([self.navigationController isKindOfClass:[NoticeNavViewController class]]) {
            minePost.strNavIndex = @"3";
        }
        [self.segmentVC setUpWithItems:items childVCs:@[minePost,minefocus]];
    }
    if ([_strShowPage isEqualToString:@"6"]) {
        NSArray *items = @[@"帖子",@"喜欢",@"关注"];
        OtherPostViewController *minePost = [[OtherPostViewController alloc] init];
        OtherLikeViewController *mineLike = [[OtherLikeViewController alloc] init];
        OtherFocusViewController *minefocus = [[OtherFocusViewController alloc] init];
        minePost.userId1 = _userId;
        mineLike.userId1 = _userId;
        minefocus.userId1 = _userId;
        if ([self.navigationController isKindOfClass:[MineNavViewController class]]) {
            mineLike.strNavIndex = @"4";
            minePost.strNavIndex = @"4";
        }
        if ([self.navigationController isKindOfClass:[FindNavViewController class]]) {
            mineLike.strNavIndex = @"1";
            minePost.strNavIndex = @"1";
        }
        if ([self.navigationController isKindOfClass:[HomeNavViewController class]]) {
            mineLike.strNavIndex = @"0";
            minePost.strNavIndex = @"0";
        }
        if ([self.navigationController isKindOfClass:[NoticeNavViewController class]]) {
            mineLike.strNavIndex = @"3";
            minePost.strNavIndex = @"3";
        }
        [self.segmentVC setUpWithItems:items childVCs:@[minePost,mineLike,minefocus]];
    }
    
    
    self.segmentVC.segmentBar.selectIndex = _barSelectIndex;
    
    // 结束刷新
    [self.refreshControl endRefreshing];
}


// 布局页面
- (void) layoutView {
    
    // 底层滚动图
    _bigScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_bigScrollView];
    [_bigScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.height.equalTo(@(H));
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        
    }];
    _bigScrollView.showsHorizontalScrollIndicator = NO; // 横向滚动条
    _bigScrollView.backgroundColor = [UIColor whiteColor];
    _bigScrollView.scrollEnabled = YES;
    
    
    
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
    
    // 返回按钮
    UIButton *backBtn = [[UIButton alloc] init];
    [_bigScrollView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bigScrollView);
        make.left.equalTo(self.view);
        make.width.equalTo(@(100));
        make.height.equalTo(@(46));
    }];
    backBtn.imageView.sd_layout
    .leftSpaceToView(backBtn, 15)
    .centerYEqualToView(backBtn)
    .widthIs(10.4)
    .heightIs(18.4);
    [backBtn setImage:[UIImage imageNamed:@"details_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 关注按钮
    guanzhuBtn = [[UIButton alloc] init];
    [_bigScrollView addSubview:guanzhuBtn];
    [guanzhuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bigScrollView);
        make.right.equalTo(self.view);
        make.width.equalTo(@(100));
        make.height.equalTo(@(46));
    }];
    guanzhuBtn.titleLabel.sd_layout
    .rightSpaceToView(guanzhuBtn, 15)
    .centerYEqualToView(guanzhuBtn);
    [guanzhuBtn setTitle:@"＋关注" forState:UIControlStateNormal];
    [guanzhuBtn setTitle:@"已关注" forState:UIControlStateSelected];
    [guanzhuBtn setTitleColor:FUIColorFromRGB(0xfeaa0a) forState:UIControlStateNormal];
    [guanzhuBtn setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateSelected];
    guanzhuBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    guanzhuBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    guanzhuBtn.hidden = YES;
    [guanzhuBtn addTarget:self action:@selector(guanzhuClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    self.segmentVC.view.frame = CGRectMake(0, W * 0.78125 - 20,_bigScrollView.frame.size.width, _bigScrollView.frame.size.height - 25 - W * 0.78125 * 0.13);
    [_bigScrollView addSubview:self.segmentVC.view];
    
    if ([_strShowPage isEqualToString:@"0"]) {
        NSArray *items = @[@"帖子"];
        OtherPostViewController *minePost = [[OtherPostViewController alloc] init];
        minePost.userId1 = _userId;
        if ([self.navigationController isKindOfClass:[MineNavViewController class]]) {
            minePost.strNavIndex = @"4";
        }
        if ([self.navigationController isKindOfClass:[FindNavViewController class]]) {
            minePost.strNavIndex = @"1";
        }
        if ([self.navigationController isKindOfClass:[HomeNavViewController class]]) {
            minePost.strNavIndex = @"0";
        }
        if ([self.navigationController isKindOfClass:[NoticeNavViewController class]]) {
            minePost.strNavIndex = @"3";
        }
        // 3 添加标题数组和控住器数组
        [self.segmentVC setUpWithItems:items childVCs:@[minePost]];
    }
    if ([_strShowPage isEqualToString:@"2"]) {
        // 只显示喜欢帖子
        NSArray *items = @[@"帖子",@"喜欢"];
        OtherPostViewController *minePost = [[OtherPostViewController alloc] init];
        minePost.userId1 = _userId;
        OtherLikeViewController *otherLike = [[OtherLikeViewController alloc] init];
        otherLike.userId1 = _userId;
        if ([self.navigationController isKindOfClass:[MineNavViewController class]]) {
            otherLike.strNavIndex = @"4";
            minePost.strNavIndex = @"4";
        }
        if ([self.navigationController isKindOfClass:[FindNavViewController class]]) {
            otherLike.strNavIndex = @"1";
            minePost.strNavIndex = @"1";
        }
        if ([self.navigationController isKindOfClass:[HomeNavViewController class]]) {
            otherLike.strNavIndex = @"0";
            minePost.strNavIndex = @"0";
        }
        if ([self.navigationController isKindOfClass:[NoticeNavViewController class]]) {
            otherLike.strNavIndex = @"3";
            minePost.strNavIndex = @"3";
        }
        // 3 添加标题数组和控住器数组
        [self.segmentVC setUpWithItems:items childVCs:@[minePost,otherLike]];
    }
    if ([_strShowPage isEqualToString:@"4"]) {
        // 只显示喜欢帖子
        NSArray *items = @[@"帖子",@"关注"];
        OtherPostViewController *minePost = [[OtherPostViewController alloc] init];
        minePost.userId1 = _userId;
        OtherFocusViewController *otherFocus = [[OtherFocusViewController alloc] init];
        otherFocus.userId1 = _userId;
        if ([self.navigationController isKindOfClass:[MineNavViewController class]]) {
            minePost.strNavIndex = @"4";
        }
        if ([self.navigationController isKindOfClass:[FindNavViewController class]]) {
            minePost.strNavIndex = @"1";
        }
        if ([self.navigationController isKindOfClass:[HomeNavViewController class]]) {
            minePost.strNavIndex = @"0";
        }
        if ([self.navigationController isKindOfClass:[NoticeNavViewController class]]) {
            minePost.strNavIndex = @"3";
        }
        // 3 添加标题数组和控住器数组
        [self.segmentVC setUpWithItems:items childVCs:@[minePost,otherFocus]];
    }
    if ([_strShowPage isEqualToString:@"6"]) {
        // 只显示喜欢帖子
        NSArray *items = @[@"帖子",@"喜欢",@"关注"];
        OtherPostViewController *minePost = [[OtherPostViewController alloc] init];
        minePost.userId1 = _userId;
        OtherLikeViewController *otherLike = [[OtherLikeViewController alloc] init];
        otherLike.userId1 = _userId;
        OtherFocusViewController *otherFocus = [[OtherFocusViewController alloc] init];
        otherFocus.userId1 = _userId;
        if ([self.navigationController isKindOfClass:[MineNavViewController class]]) {
            otherLike.strNavIndex = @"4";
            minePost.strNavIndex = @"4";
        }
        if ([self.navigationController isKindOfClass:[FindNavViewController class]]) {
            otherLike.strNavIndex = @"1";
            minePost.strNavIndex = @"1";
        }
        if ([self.navigationController isKindOfClass:[HomeNavViewController class]]) {
            otherLike.strNavIndex = @"0";
            minePost.strNavIndex = @"0";
        }
        if ([self.navigationController isKindOfClass:[NoticeNavViewController class]]) {
            otherLike.strNavIndex = @"3";
            minePost.strNavIndex = @"3";
        }
        // 3 添加标题数组和控住器数组
        [self.segmentVC setUpWithItems:items childVCs:@[minePost,otherLike,otherFocus]];
    }
    // 4  配置基本设置  可采用链式编程模式进行设置
    [self.segmentVC.segmentBar updateWithConfig:^(LLSegmentBarConfig *config) {
        config.itemNormalColor([UIColor colorWithRed:152/255.0 green:153/255.0 blue:154/255.0 alpha:1.0]).itemSelectColor([UIColor colorWithRed:250/255.0 green:171/255.0 blue:45/255.0 alpha:1.0]).indicatorColor([UIColor colorWithRed:250/255.0 green:171/255.0 blue:45/255.0 alpha:1.0]);
    }];
    
    
    if ([_strShowPage isEqualToString:@"4"]) {
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
            make.centerX.equalTo(self.view);
            make.width.equalTo(@(0.8));
            make.height.equalTo(@(W * 0.78125 * 0.13 / 2 - 8));
        }];
        lbFenGe.backgroundColor = [UIColor whiteColor];
    }
    if ([_strShowPage isEqualToString:@"6"]) {
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
    }
    

    
    _bigScrollView.delegate = self;
    
    // 弹簧头像
    [self createTouxiang];
    
}


// 返回按钮点击事件
- (void) backClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
        [notiCenter postNotificationName:@"xiugaiScroll61" object:@"61"];
    }
    
}


// 关注按钮点击
- (void) guanzhuClick:(UIButton *)btn {
    
    btn.userInteractionEnabled = NO;
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    NSDictionary *idDic = @{@"uid":[dicForUserInfo valueForKey:@"id"]};
    NSString *dataStr = [[MakeJson createJson:idDic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStr};
    
    if (btn.selected == NO) {
        // 进行关注数据请求
        [http PostAddFollowUserWithDic:dicData Success:^(id userInfo) {
            // 打开用户交互
            btn.userInteractionEnabled = YES;
            // 数据请求成功
            if ([userInfo isEqualToString:@"0"]) {
                NSLog(@"关注用户失败");
            }else {
                // 关注成功
                btn.selected = !btn.selected;
                [MBHUDView hudWithBody:@"关注用户成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                
                
                // 做一个单例 用于修改发现页面的推荐用户
                if ([UserDefaults valueForKey:@"FollowUserOrBlacklistUser"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:[dicForUserInfo valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserOrBlacklistUser"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserOrBlacklistUser"]];
                    [tempArr addObject:[dicForUserInfo valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserOrBlacklistUser"];
                }
                
                // 做一个单例 用于修改发现页面的推荐用户
                if ([UserDefaults valueForKey:@"FollowUserForNews"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:[dicForUserInfo valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserForNews"]];
                    [tempArr addObject:[dicForUserInfo valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                }
                
            }
        } failure:^(NSError *error) {
            // 数据请求失败
            // 打开用户交互
            btn.userInteractionEnabled = YES;
        }];
    }else {
        
        // 进行删除关注数据请求
        [http PostDelFollowUserWithDic:dicData Success:^(id userInfo) {
            // 打开用户交互
            btn.userInteractionEnabled = YES;
            // 数据请求成功
            if ([userInfo isEqualToString:@"0"]) {
                NSLog(@"关注用户失败");
            }else {
                // 关注成功
                btn.selected = !btn.selected;
                [MBHUDView hudWithBody:@"取消关注成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                
                
                
                // 做一个单例 用于修改发现页面的推荐用户
                if ([UserDefaults valueForKey:@"CancleFollowUser"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:[dicForUserInfo valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUser"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"CancleFollowUser"]];
                    [tempArr addObject:[dicForUserInfo valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUser"];
                }
                
                
                // 做一个单例 用于修改消息页面的用户关注状态
                if ([UserDefaults valueForKey:@"CancleFollowUserForNews"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:[dicForUserInfo valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUserForNews"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"CancleFollowUserForNews"]];
                    [tempArr addObject:[dicForUserInfo valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUserForNews"];
                }
                
            
            }
        } failure:^(NSError *error) {
            // 数据请求失败
            // 打开用户交互
            btn.userInteractionEnabled = YES;
        }];
        
    }
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


// 查看大图
- (void) changetouxiangImgView {
    
    
    [ZLShowBigImage showBigImage:_touxiangView];

}

// 修改背景图或查看大图
- (void) changeTopImgView {
    
    [ZLShowBigImage showBigImage:_topImgView];
}



// 监听处理事件
- (void)listen:(NSNotification *)noti {
    
    NSString *strNoti = noti.object;
    
    // 修改当前页的滚动效果
    if ([strNoti isEqualToString:@"64"]) {
        
        _bigScrollView.scrollEnabled = YES;
    }
    
    if ([strNoti isEqualToString:@"65"]) {
        
        _bigScrollView.scrollEnabled = NO;
    }
}


// 界面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    // 设置navgationController不透明
    self.navigationController.navigationBar.translucent = NO;
    
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // 接收消息
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    
    // 修改当前页的滚动状态
    [notiCenter addObserver:self selector:@selector(listen:) name:@"xiugaiScrollMine64" object:@"64"];
    // 修改当前页的滚动状态
    [notiCenter addObserver:self selector:@selector(listen:) name:@"xiugaiScrollMineNo65" object:@"65"];
    
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
