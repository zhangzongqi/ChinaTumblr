//
//  ZFTableViewController.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFTableViewController.h"
#import "ZFVideoModel.h"
#import "ZFVideoResolution.h"
#import "Masonry/Masonry.h"
//#import <ZFDownload/ZFDownloadManager.h>
#import "ZFPlayer.h"

#import "HomeImgTableViewCell.h" // 图片cell
#import "HomeTextCell.h" // 文字cell
#import "HomeVideoCell.h" // 视频cell
#import "SearchViewController.h" // 搜索页
#import "DongTaiViewController.h" // 动态
#import "PingLunViewController.h" // 评论

#import <AudioToolbox/AudioToolbox.h> // 用于设置点击时的震动反馈

#import "XLPhotoBrowser.h"  // 用于全部图片展示
#import "OtherMineViewController.h" // 其他人个人页面

#import "LoginViewController.h" // 登录页面

#import <zhPopupController/zhPopupController.h> // 弹出效果

#import "ShareAndOtherView.h" // 弹出分享框

#import "DetailImgViewController.h" // 帖子详情
#import "DeatalSystemNoticeViewController.h" // 专题详情

#import "UITabBarItem+WZLBadge.h" // 角标



#define KPraiseBtnWH          30
#define KBorkenTime          0.8f
#define KToBrokenHeartWH    120/195

@interface ZFTableViewController () <ZFPlayerDelegate,CAAnimationDelegate,UIActionSheetDelegate,TopScrollViewDelegate,MBProgressHUDDelegate> {
    
    NSInteger pageStart; // 请求数据开始位置
    NSInteger pageSize; // 一页的数量
    
    NSArray *_arrForAllLike; // 所有喜欢
    
    // 当前要删除的帖子的id
    NSString *_strCurrentDelId ;
    // 当前要删除的帖子的排序
    NSString *_strCurrentDelPaiXu;
    
    // bannerArr
    NSMutableArray *_bannerArr;
}

@property (nonatomic, strong) NSMutableArray      *tableViewArr;
//@property (nonatomic, strong) NSMutableArray      *dataSource;
@property (nonatomic, strong) ZFPlayerView        *playerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;

@property (nonatomic, copy) MBProgressHUD *HUD;

@end

@implementation ZFTableViewController

#pragma mark - life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 隐藏cell间的分隔线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 379.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    // 继续配置_tableView;
    // 创建一个下拉刷新的头
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 调用下拉刷新方法
        [self downRefresh];
    }];
    header.stateLabel.textColor = FUIColorFromRGB(0xffffff);
    header.lastUpdatedTimeLabel.textColor = FUIColorFromRGB(0xffffff);
    
    // 设置_tableView的顶头
    self.tableView.mj_header = header;
    
    // 设置_tableView的底部
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 调用上拉刷新方法
        [self upRefresh];
    }];
    
    
    // 动画
    [self createLoadingForBtnClick];
    
    // 判断用户是否登录超时
    [self panduanUserTimeOut];
    
    // 初始化数组
    [self initArr];
    
    // 页面背景色
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    // 设置导航条不透明
    self.navigationController.navigationBar.translucent = NO;
    
    // 创建Tabbar图标
    [self createTabbarImg];
    
    // 创建导航栏搜索和logo
    [self createSearchAndLogo];
    
}

// 下拉刷新方法
- (void)downRefresh {
    
    // 起始位置
    pageStart = 0;
    
    // 清空数组
//    [_tableViewArr removeAllObjects];
//    [self.tableView reloadData];
    
    // 动画
    [self createLoadingForBtnClick];
    
    // 请求数据
    [self initData];
}

// 上拉下拉刷新动画
- (void) createLoadingForBtnClick {
    
    _HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 展示
    [_HUD show:YES];
    
    
//    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    _HUD.mode = MBProgressHUDModeCustomView;
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"load" withExtension:@"gif"];
//    UIImageView *gifImageView = [[UIImageView alloc] initWithImage:[UIImage animatedImageWithAnimatedGIFURL:url]];
//    gifImageView.frame = CGRectMake(0, 0, 153.5, 124);
//    _HUD.customView = gifImageView;
//    _HUD.color = [UIColor clearColor];
//    [_HUD show:YES];
    
}


// 上拉刷新方法
- (void)upRefresh {
    
    // 起始位置
    pageStart = _tableViewArr.count;
    
    // 请求数据
    [self initData];
}


// 初始化数组
- (void) initArr {
    
    // 初始化
    pageStart = 0;
    pageSize = 10;
    
    // tableViewArr
    _tableViewArr = [NSMutableArray array];
    
    _arrForAllLike = [NSArray array];
    
    _bannerArr = [NSMutableArray array]; // 滚动图数组
}


// 判断用户是否登录
- (void) panduanUserTimeOut {
    
    // 先判断用户是否登录
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    
    NSLog(@"hhhhhhh::%@",[user valueForKey:@"ceshiChaoShi"]);
    NSLog(@"hhhhhhh2::%@",[user valueForKey:@"ceshiChaoShifanhuijieguo"]);
    
    
    if ([[user objectForKey:@"token"] length] < 1) {
    
        // 隐藏动画
        [_HUD hide:YES];
        
        // 未登录
        LoginViewController *vc = [[LoginViewController alloc] init];
        [vc setHidesBottomBarWhenPushed:YES];

        [self.navigationController pushViewController:vc animated:YES];
        
    }else {
        
        
        // 已登录,判断是否登录超时
        HttpRequest *http = [[HttpRequest alloc] init];
        NSArray *arr = [GetUserJiaMi getUserTokenAndCgAndKey];
        NSDictionary *dic = @{@"tk":arr[0],@"key":arr[1],@"cg":arr[2]};
        
        
        NSDictionary *dicForUserhhhhhhhhhceshi = @{@"token":[user objectForKey:@"token"],@"CurrentCanShu":dic,@"userInfo":[user valueForKey:@"userInfo"]};
        [user setValue:dicForUserhhhhhhhhhceshi forKey:@"ceshiChaoShi"];
        
        
        [http PostPanduanUserTimeOutWithDic:dic Success:^(id statusInfo) {
            
            // 不用执行任何操作
            if ([statusInfo isEqualToString:@"error"]) {
                // 超时,不用进行处理
                // 隐藏动画
                [_HUD hide:YES];
            }
            if ([statusInfo isEqualToString:@"weichaoshi"]) {
                
                // 设置小红点
                if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
                    
                    [self.tabBarController.tabBar.items[3] showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
                }else {
                    
                    // 没有小红点
                }
                
                
                // 请求数据
                [self initData];
            }
            
        } failure:^(NSError *error) {
            
            // 网络错误，请求失败
            // 隐藏动画
            [_HUD hide:YES];
        }];
    }
}



// 创建Tabbar图标
- (void) createTabbarImg {
    
    // 首页
    UIImage *select0 = [UIImage imageNamed:@"TabBar_on1"];
    [self.tabBarController.childViewControllers[0].tabBarItem  setSelectedImage:[select0 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UIImage *normal0 = [UIImage imageNamed:@"TabBar_off1"];
    [self.tabBarController.childViewControllers[0].tabBarItem  setImage:[normal0 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // 发现
    UIImage *select1 = [UIImage imageNamed:@"TabBar_on2"];
    [self.tabBarController.childViewControllers[1].tabBarItem  setSelectedImage:[select1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UIImage *normal1 = [UIImage imageNamed:@"TabBar_off2"];
    [self.tabBarController.childViewControllers[1].tabBarItem  setImage:[normal1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // 消息
    UIImage *select3 = [UIImage imageNamed:@"TabBar_on4"];
    [self.tabBarController.childViewControllers[3].tabBarItem  setSelectedImage:[select3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UIImage *normal3 = [UIImage imageNamed:@"TabBar_off4"];
    [self.tabBarController.childViewControllers[3].tabBarItem  setImage:[normal3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    
    // 我的
    UIImage *select4 = [UIImage imageNamed:@"TabBar_on5"];
    [self.tabBarController.childViewControllers[4].tabBarItem  setSelectedImage:[select4 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UIImage *normal4 = [UIImage imageNamed:@"TabBar_off5"];
    [self.tabBarController.childViewControllers[4].tabBarItem  setImage:[normal4 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    
//    float fffirst = 3562;
//    float countNum = 0;
//    for (int i = 0; i < 120; i++) {
//        countNum = countNum + fffirst;
//        fffirst = fffirst - 6;
//    }
//    NSLog(@"等额本金本息前十年总还款差额:%f",2748*120 - countNum);
    
}

// 创建导航栏搜索和Logo
- (void) createSearchAndLogo {
    
    // UINavigationItem
    UINavigationItem *navItem = self.navigationItem;
    
    
    // 首页搜索左边小logo
    UIButton *homeLogo = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
//    UIImage *logoImage = [self reSizeImage:[UIImage imageNamed:@"Icon-Small"] toSize:CGSizeMake(28, 28)];
    UIImage *logoImage = [UIImage imageNamed:@"Icon-Small"];
    [homeLogo setImage:logoImage forState:UIControlStateNormal];
    // 左视图
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:homeLogo];

//    if (([[[ UIDevice currentDevice ] systemVersion ] floatValue ]>= 7.0 ? 20 : 0 )) {
//        UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ] initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace target:nil action:nil];
//
//        negativeSpacer.width = - 10;//这个数值可以根据情况自由变化
//
//        self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftItem];
//
//    } else {
        self.navigationItem.leftBarButtonItem = leftItem;
//    }
    homeLogo.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    
    
    
    
    
    
    
    
    
    // 导航条中间搜索按钮
    UIButton *btnForSearch = [[UIButton alloc] init];
    btnForSearch.frame = CGRectMake(0, 0, W - 10, 32);
    
    // 首页搜索按钮
    btnForSearch.backgroundColor = [UIColor colorWithRed:41/255.0 green:42/255.0 blue:43/255.0 alpha:1.0];
    btnForSearch.layer.cornerRadius = 16;
    btnForSearch.clipsToBounds = YES;
    
    // 搜索小图标
    UIImageView * imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s首页01"]];
    imgView.frame = CGRectMake(15, 9, 15, 15);
    [btnForSearch addSubview:imgView];
    
    // 搜索提示语
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 150, 24)];
    lb.text = @"输入关键字,搜你喜欢";
    lb.textColor = [UIColor grayColor];
    lb.alpha = 0.9;
    lb.font = [UIFont systemFontOfSize:12];
    [btnForSearch addSubview:lb];
    
    // 搜索
    UILabel *lb2 = [[UILabel alloc] initWithFrame:CGRectMake(W - homeLogo.frame.size.width - 10 - 15 - 45 - 20, 10, 45, 14)];
    [btnForSearch addSubview:lb2];
//    [lb2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(btnForSearch);
//        make.right.equalTo(btnForSearch.mas_right).with.offset(-15);
//    }];
    lb2.textColor = [UIColor colorWithRed:186/255.0 green:187/255.0 blue:188/255.0 alpha:1.0];
    lb2.text = @"搜一搜";
    lb2.font = [UIFont systemFontOfSize:14];
    lb2.textAlignment = NSTextAlignmentRight; // 居右
    
    
    // 加入标题视图
    navItem.titleView = btnForSearch;
    [btnForSearch addTarget:self action:@selector(searchBtn:) forControlEvents:UIControlEventTouchUpInside];
}


// 搜索按钮点击事件
- (void) searchBtn:(UIButton *)btn {
    
    // 搜索页面
    SearchViewController *searchVc = [[SearchViewController alloc] init];
    
    // 设置跳转的样式
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    //    transition.subtype = kCATransitionFromTop;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    // 跳转，动画设置为NO
    [searchVc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:searchVc animated:NO];
}

// 修改图片大小
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [reSizeImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

// 请求数据
- (void)initData {
    
    
//    GetBannerListWithPosition
    
    
    
    // 创建数据请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    NSArray *arrUserJiaMi = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    
    
    // 请求banner数据
    [http GetBannerListWithPosition:@"1" Success:^(id arrForDetail) {
        
        if ([arrForDetail isKindOfClass:[NSString class]]) {
            
            // 没有拿到数据，把banner去掉
            [self.tableView.tableHeaderView removeFromSuperview];
            self.tableView.tableHeaderView = nil;
            
        }else {
            
            _bannerArr = arrForDetail;
            
            UIImageView *imgViewback = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, W, 0.1875 * [[[UIApplication sharedApplication] delegate] window].frame.size.height + 6)];
            imgViewback.userInteractionEnabled = YES;
            imgViewback.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
            _topScrollView=[[TopScrollView alloc] initWithDataArray:_bannerArr];
//            _topScrollView.frame = CGRectMake(0, 0, W, 0.1875 * (H+64+49));
            _topScrollView.delegate=self;
            [imgViewback addSubview:_topScrollView];
            self.tableView.tableHeaderView = imgViewback;
        }
        
    } failure:^(NSError *error) {
        
//        [self.tableView.tableHeaderView removeFromSuperview];
//        self.tableView.tableHeaderView = nil;
    }];
    
    
    
    // 请求下面数据
    // 第0页
    if (pageStart == 0) {
        
        NSDictionary *dataDic = @{@"pageSize":@"10"};
        NSString *strDataJiaMi = [[MakeJson createJson:dataDic] AES128EncryptWithKey:arrUserJiaMi[3]];
        
        NSDictionary *dicDataJiaMi = @{@"tk":arrUserJiaMi[0],@"key":arrUserJiaMi[1],@"cg":arrUserJiaMi[2],@"data":strDataJiaMi};
        
        // 进行数据请求
        [http PostGetNoteListPageForHomeWithDic:dicDataJiaMi Success:^(id userInfo) {
            
            if ([userInfo isKindOfClass:[NSString class]]) {
                
                // 失败
                // 隐藏动画
                [_HUD hide:YES];
                // 表格刷新完毕,结束上下刷新视图
                [self.tableView.mj_footer endRefreshing];
                [self.tableView.mj_header endRefreshing];
                
            }else {
                
                // 恢复下拉刷新
                [self.tableView.mj_footer resetNoMoreData];
                
                // 清空数组
                [_tableViewArr removeAllObjects];
                // 成功
                [_tableViewArr addObjectsFromArray:userInfo];
                
                // 获取用户所有喜欢的帖子编号
                NSDictionary *dicLikeAllList = @{@"tk":arrUserJiaMi[0],@"key":arrUserJiaMi[1],@"cg":arrUserJiaMi[2]};
                [http PostGetAllLoveNoteIdListWithDic:dicLikeAllList Success:^(id userInfo) {
                    
                    if ([userInfo isEqualToString:@"error"]) {
                        
                        NSLog(@"获取用户所有喜欢的帖子编号失败");
                        
                    }else {
                        
                        // 拿到了
                        _arrForAllLike = [userInfo componentsSeparatedByString:@","];
                        
                        for (int i = 0; i < _tableViewArr.count; i++) {
                            
                            UserLikeTieZiListModel *model = _tableViewArr[i];
                            // 判断是否已经喜欢
                            if ([_arrForAllLike containsObject:model.id1]) {
                                model.isLike = @"YES";
                            }else {
                                model.isLike = @"NO";
                            }
                        }
                    }
                    
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    // 表格刷新完毕,结束上下刷新视图
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView.mj_header endRefreshing];
                    // 刷新列表
                    [self.tableView reloadData];
//                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    
                } failure:^(NSError *error) {
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    // 表格刷新完毕,结束上下刷新视图
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView.mj_header endRefreshing];
                }];
            }
            
        } failure:^(NSError *error) {
            
            // 隐藏动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
        }];
        
    }else {
        
        UserLikeTieZiListModel *model = [_tableViewArr lastObject];
        
        NSDictionary *dataDic = @{@"pageSize":[NSString stringWithFormat:@"%ld",pageSize],@"startTime":model.update_time,@"lastNoteId":model.id1};
        NSString *strDataJiaMi = [[MakeJson createJson:dataDic] AES128EncryptWithKey:arrUserJiaMi[3]];
        
        NSDictionary *dicDataJiaMi = @{@"tk":arrUserJiaMi[0],@"key":arrUserJiaMi[1],@"cg":arrUserJiaMi[2],@"data":strDataJiaMi};
        
        // 数据请求
        HttpRequest *http = [[HttpRequest alloc] init];
        [http PostGetNoteListPageForHomeWithDic:dicDataJiaMi Success:^(id userInfo) {
            
            if ([userInfo isKindOfClass:[NSString class]]) {
                
                // 失败
                // 隐藏动画
                [_HUD hide:YES];
                // 表格刷新完毕,结束上下刷新视图
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                [self.tableView.mj_header endRefreshing];
                
            }else {
                
                // 成功
                [_tableViewArr addObjectsFromArray:userInfo];
                
                // 获取用户所有喜欢的帖子编号
                NSDictionary *dicLikeAllList = @{@"tk":arrUserJiaMi[0],@"key":arrUserJiaMi[1],@"cg":arrUserJiaMi[2]};
                
                [http PostGetAllLoveNoteIdListWithDic:dicLikeAllList Success:^(id userInfo) {
                    
                    if ([userInfo isEqualToString:@"error"]) {
                        
                    }else {
                        
                        // 拿到了
                        _arrForAllLike = [userInfo componentsSeparatedByString:@","];
                        
                        for (int i = 0; i < _tableViewArr.count; i++) {
                            
                            UserLikeTieZiListModel *model = _tableViewArr[i];
                            // 判断是否已经喜欢
                            if ([_arrForAllLike containsObject:model.id1]) {
                                model.isLike = @"YES";
                            }else {
                                model.isLike = @"NO";
                            }
                        }
                    }
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    // 表格刷新完毕,结束上下刷新视图
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView.mj_header endRefreshing];
                    // 刷新列表
                    [self.tableView reloadData];
                    
                } failure:^(NSError *error) {
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    // 表格刷新完毕,结束上下刷新视图
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView.mj_header endRefreshing];
                    // 刷新列表
                    [self.tableView reloadData];
                }];
                
            }
            
        } failure:^(NSError *error) {
            
            // 隐藏动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
        }];
    }
}

#pragma mark -----TopScrollView-----
-(void)didClickScrollViewWithIndex:(NSInteger)index {
    
    BannerModel *model = _bannerArr[index];
    
    switch ([model.target_type integerValue]) {
        case 7:{
            // 帖子详情
            DetailImgViewController *vc = [[DetailImgViewController alloc] init];
            vc.strId = model.data_id;
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 11:{
            // 专题详情
            DeatalSystemNoticeViewController *vc = [[DeatalSystemNoticeViewController alloc] init];
            vc.idStr = model.data_id;
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}



- (UIStatusBarStyle)preferredStatusBarStyle {
    // 这里设置横竖屏不同颜色的statusbar
    if (ZFPlayerShared.isLandscape) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return ZFPlayerShared.isStatusBarHidden;
}

#pragma mark - Table view data source
// 返回的分组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// 返回的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.tableViewArr.count;
}

// 绑定数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserLikeTieZiListModel *model = _tableViewArr[indexPath.row];
    
    // 用户单利
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    
    if ([model.type isEqualToString:@"1"]) {
        
        static NSString *CellIdentifier = @"Cell";
        // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
        HomeImgTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
        if (cell == nil) {
            cell = [[HomeImgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // 头像
        [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        // 昵称
        cell.nickNameLb.text = model.nickname;
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.update_time integerValue]];
        NSArray *imgandIdArr = model.files;
        // 发布的图片
        [cell.showImgView sd_setImageWithURL:[NSURL URLWithString:[imgandIdArr[0] valueForKey:@"path"]] placeholderImage:[UIImage imageNamed:@""]];
        // 张数
        cell.imgNumLb.text = [NSString stringWithFormat:@"1/%ld",imgandIdArr.count];
        // 内容
        if (model.content == nil) {
            cell.textLb.text = @"";
        }else {
            cell.textLb.attributedText = [self getAttributedStringWithString:model.content lineSpace:5];
        }
        // 评论数量
        [cell.pinglunNumBtn setTitle:[NSString stringWithFormat:@"%@ 条评论",model.comment_num] forState:UIControlStateNormal];
        // 动态数量
        [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%@ 动态",model.active_num] forState:UIControlStateNormal];
        // 给标签
        NSArray *arrGuanjianCi = [model.kwList componentsSeparatedByString:@","];
        [cell giveArrForbiaoqian:arrGuanjianCi andNavIndex:0];
        
        // 拿到用户id
        NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
        if ([model.uid isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
            
            cell.gerenBtn.hidden = NO;
            cell.timeLb.frame = CGRectMake(W - (0.0234375 * W * 2 * 2 + 78 + 20), 18.5, 78, 15);
            // 头像点击block
            cell.iconImgViewClick = ^{
                [self iconImgViewBy:model];
            };
            
        }else {
            
            cell.gerenBtn.hidden = YES;
            cell.timeLb.frame = CGRectMake(W - (0.0234375 * W + 78), 18.5, 78, 15);
            // 头像点击block
            cell.iconImgViewClick = ^{
                [self iconImgViewBy:model];
            };
        }
        
        
        // 是否已经喜欢
        if ([model.isLike isEqualToString:@"YES"]) {
            cell.praiseBtn.selected = YES;
        }else {
            cell.praiseBtn.selected = NO;
        }
        
        
        // 个人操作
        cell.gerenBtnViewClick = ^{
            [self gerenBtnBy:indexPath];
        };
        // 动态
        cell.dongtaiBtnClick = ^{
            [self dongtaiBtnBy:model];
        };
        // 分享
        cell.shareBtnClick = ^{
            [self shareBtnBy:model];
        };
        // 评论
        cell.pinglunBtnClick = ^{
            [self pinglunBtnBy:model];
        };
        // 展示图点击Block
        cell.showImgViewClick = ^{
            NSMutableArray *arrForImg = [NSMutableArray array];
            for (int i = 0; i < imgandIdArr.count; i++) {
                [arrForImg addObject:[imgandIdArr[i] valueForKey:@"path"]];
            }
            [self showImgViewBy:arrForImg];
        };
        // 喜欢点击block
        cell.LoveButtonClick = ^(){
            [self loveButtonBy:indexPath];
        };
        
        // 选中无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }else if ([model.type isEqualToString:@"0"]) {
        
        static NSString *CellIdentifier = @"Cell";
        // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
        HomeTextCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
        if (cell == nil) {
            cell = [[HomeTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // 头像
        [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        // 昵称
        cell.nickNameLb.text = model.nickname;
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.update_time integerValue]];
        // 文字
        if (model.content == nil) {
            cell.lbText.text = @"";
        }else {
            cell.lbText.attributedText = [self getAttributedStringWithString:model.content lineSpace:5];
        }
        // 评论数量
        [cell.pinglunNumBtn setTitle:[NSString stringWithFormat:@"%@ 条评论",model.comment_num] forState:UIControlStateNormal];
        // 动态数量
        [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%@ 动态",model.active_num] forState:UIControlStateNormal];
        // 给标签
        NSArray *arrGuanjianCi = [model.kwList componentsSeparatedByString:@","];
        [cell giveArrForbiaoqian:arrGuanjianCi andNavIndex:0];
        
        // 选中无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        // 拿到用户id
        NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
        if ([model.uid isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
            
            
            cell.gerenBtn.hidden = NO;
            cell.timeLb.frame = CGRectMake(W - (0.0234375 * W * 2 * 2 + 78 + 20), 18.5, 78, 15);
            // 头像点击block
            cell.iconImgViewClick = ^{
                [self iconImgViewBy:model];
            };
            
        }else {
            
            
            cell.gerenBtn.hidden = YES;
            cell.timeLb.frame = CGRectMake(W - (0.0234375 * W + 78), 18.5, 78, 15);
            // 头像点击block
            cell.iconImgViewClick = ^{
                [self iconImgViewBy:model];
            };
        }
        
        // 是否已经喜欢
        if ([model.isLike isEqualToString:@"YES"]) {
            
            cell.praiseBtn.selected = YES;
        }else {
            cell.praiseBtn.selected = NO;
        }
        
        
        // 个人操作
        cell.gerenBtnViewClick = ^{
            [self gerenBtnBy:indexPath];
        };
        // 动态
        cell.dongtaiBtnClick = ^{
            [self dongtaiBtnBy:model];
        };
        // 分享
        cell.shareBtnClick = ^{
            [self shareBtnBy:model];
        };
        // 评论
        cell.pinglunBtnClick = ^{
            [self pinglunBtnBy:model];
        };
        // 喜欢点击
        cell.LoveButtonClick = ^(){
            
            [self loveButtonBy:indexPath];
        };
        
        return cell;
        
    }else {
        
        // 创建Cell
        static NSString *CellIdentifier = @"Cell";
        // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
        HomeVideoCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
        if (cell == nil) {
            cell = [[HomeVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // 选中无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // 取到对应cell的model
        __block UserLikeTieZiListModel *model = _tableViewArr[indexPath.row];
        // 赋值model
        __block NSIndexPath *weakIndexPath = indexPath;
        __block HomeVideoCell *weakCell = cell;
        __weak typeof(self) weakSelf = self;
        
        // 给标签
        NSArray *arrGuanjianCi = [model.kwList componentsSeparatedByString:@","];
        [cell giveArrForbiaoqian:arrGuanjianCi andNavIndex:0];
        // 头像
        [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        // 昵称
        cell.nickNameLb.text = model.nickname;
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.update_time integerValue]];
        // 文字
        if (model.content == nil) {
            cell.textLb.text = @"";
        }else {
            cell.textLb.attributedText = [self getAttributedStringWithString:model.content lineSpace:5];
        }
        
        // 拿到用户id
        NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
        if ([model.uid isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
            
            
            cell.gerenBtn.hidden = NO;
            cell.timeLb.frame = CGRectMake(W - (0.0234375 * W * 2 * 2 + 70 + 20), 18.5, 90, 15);
            // 头像点击block
            cell.iconImgViewClick = ^{
                [self iconImgViewBy:model];
            };
            
        }else {
            
            
            cell.gerenBtn.hidden = YES;
            cell.timeLb.frame = CGRectMake(W - (0.0234375 * W + 78), 18.5, 78, 15);
            // 头像点击block
            cell.iconImgViewClick = ^{
                [self iconImgViewBy:model];
            };
        }
        
        // 评论数量
        [cell.pinglunNumBtn setTitle:[NSString stringWithFormat:@"%@ 条评论",model.comment_num] forState:UIControlStateNormal];
        // 动态数量
        [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%@ 动态",model.active_num] forState:UIControlStateNormal];
        [cell.picView sd_setImageWithURL:[NSURL URLWithString:[model.files[0] valueForKey:@"path_cover"]]placeholderImage:[UIImage imageNamed:@""]];
        
        // 是否已经喜欢
        if ([model.isLike isEqualToString:@"YES"]) {
            
            cell.praiseBtn.selected = YES;
        }else {
            cell.praiseBtn.selected = NO;
        }
        
        
        // 个人操作
        cell.gerenBtnViewClick = ^{
            [self gerenBtnBy:indexPath];
        };
        // 动态
        cell.dongtaiBtnClick = ^{
            [self dongtaiBtnBy:model];
        };
        // 分享
        cell.shareBtnClick = ^{
            [self shareBtnBy:model];
        };
        // 评论
        cell.pinglunBtnClick = ^{
            [self pinglunBtnBy:model];
        };
        // 喜欢
        cell.LoveButtonClick = ^(){
            
            [self loveButtonBy:indexPath];
        };
        
        
        // 点击播放的回调
        cell.playBlock = ^(UIButton *btn){
            
            // 取出字典中的第一视频URL
            NSArray *arrFiles = model.files;
            NSURL *videoURL = [NSURL URLWithString:[arrFiles[0] valueForKey:@"path"]];
            
            ZFPlayerModel *playerModel = [[ZFPlayerModel alloc] init];
            playerModel.videoURL         = videoURL;
            playerModel.placeholderImageURLString = [arrFiles[0] valueForKey:@"path_cover"];
            playerModel.scrollView       = weakSelf.tableView;
            playerModel.indexPath        = weakIndexPath;
            // player的父视图tag
            playerModel.fatherViewTag = weakCell.picView.tag;
            
            // 设置播放控制层和model
            [weakSelf.playerView playerControlView:nil playerModel:playerModel];
            // 下载功能
            weakSelf.playerView.hasDownload = NO;
            // 自动播放
            [weakSelf.playerView autoPlayTheVideo];
        };
        
        return cell;
    }
}


// 个人操作
- (void) gerenBtnBy:(NSIndexPath *)indexPath {
    
    // 拿到模型数据
    UserLikeTieZiListModel *model = _tableViewArr[indexPath.row];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"操作"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"修改本条帖子",@"删除本条帖子",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
    actionSheet.delegate = self;
    actionSheet.tag = 222;
    
    // 当前要删除的帖子的id
    _strCurrentDelId = model.id1;
    // 当前要删除的帖子的排序
    _strCurrentDelPaiXu = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    // 把当前模型加进去
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 存储时直接把最外层数组转成NSData类型
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    [user setValue:data forKey:@"rightBtnModel"];
}
// 点击事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 222) {
        // 右侧点击
        if (buttonIndex == 0) {
            
            // 用户单例
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            SearchTieZiWithKeyWordModel *model1 = [NSKeyedUnarchiver unarchiveObjectWithData:[user valueForKey:@"rightBtnModel"]];
            
            if ([model1.type isEqualToString:@"0"]) {
                // 纯文字
                // 跳转  传过去参数
                PublishTextViewController *vc = [[PublishTextViewController alloc] init];
                vc.model = model1;
                [self presentViewController:vc animated:YES completion:nil];
            }else if ([model1.type isEqualToString:@"1"]){
                // 图片
                // 跳转到修改页面  传过去参数
                PublishPhotoViewController *vc = [[PublishPhotoViewController alloc] init];
                vc.model = model1;
                [self presentViewController:vc animated:YES completion:nil];
            }else {
                // 视频
                PublishVideoViewController *vc = [[PublishVideoViewController alloc] init];
                vc.model = model1;
                [self presentViewController:vc animated:YES completion:nil];
            }
            
            // 删除用户单例
            [user removeObjectForKey:@"rightBtnModel"];
            
            
        }else if (buttonIndex == 1) {
            
            // 图片
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"帖子删除后不可恢复,是否删除" delegate:self cancelButtonTitle:@"删除" otherButtonTitles:@"取消", nil];
            alert.delegate = self;
            alert.tag = 321;
            [alert show];
            
        }else {
            // 取消
            NSLog(@"点击了取消");
            _strCurrentDelId = @"";
            _strCurrentDelPaiXu = @"";
        }
    }
    
    
    if (actionSheet.tag == 111) {
        // 用户单例
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        SearchTieZiWithKeyWordModel *model1 = [NSKeyedUnarchiver unarchiveObjectWithData:[user valueForKey:@"jubaoModel"]];
        NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
        HttpRequest *http = [[HttpRequest alloc] init];
        
        if (buttonIndex == 0) {
            
            NSDictionary *dicForData = @{@"noteId":model1.id1,@"type":@"1",@"content":@""};
            NSString *strData = [[MakeJson createJson:dicForData] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dic = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            [http PostAccusationNoteWithDic:dic Success:^(id userInfo) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            } failure:^(NSError *error) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            }];
            
        }else if (buttonIndex == 1) {
            
            NSDictionary *dicForData = @{@"noteId":model1.id1,@"type":@"2",@"content":@""};
            NSString *strData = [[MakeJson createJson:dicForData] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dic = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            [http PostAccusationNoteWithDic:dic Success:^(id userInfo) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            } failure:^(NSError *error) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            }];
            
        }else if (buttonIndex == 2){
            
            NSDictionary *dicForData = @{@"noteId":model1.id1,@"type":@"3",@"content":@""};
            NSString *strData = [[MakeJson createJson:dicForData] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dic = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            [http PostAccusationNoteWithDic:dic Success:^(id userInfo) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            } failure:^(NSError *error) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            }];
            
        }else if (buttonIndex == 3) {
            
            NSDictionary *dicForData = @{@"noteId":model1.id1,@"type":@"0",@"content":@""};
            NSString *strData = [[MakeJson createJson:dicForData] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dic = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            [http PostAccusationNoteWithDic:dic Success:^(id userInfo) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            } failure:^(NSError *error) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            }];
            
        }else {
            // 取消
            NSLog(@"点击了取消");
        }
    }
    
}

// 弹出代理事件
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 321) {
        if (buttonIndex == 0) {
            
            // 创建动画
            [self createLoadingForBtnClick];
            // 0.5秒后，执行删除
            [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(DelTieZiEvent) userInfo:nil repeats:NO];
            
        }else {
            NSLog(@"没删除");
        }
    }
}

// 删除帖子操作
- (void) DelTieZiEvent {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 获取用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    NSDictionary *dic = @{@"id":_strCurrentDelId};
    NSLog(@"_strCurrentDelId::%@",_strCurrentDelId);
    NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSLog(@"strData::::::%@",strData);
    
    NSDictionary *dicForData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
    NSLog(@"dicForData:::::::%@",dicForData);
    [http PostDelNoteWithDic:dicForData Success:^(id userInfo) {
        
        // 请求成功
        if ([userInfo isEqualToString:@"0"]) {
            // 删除失败
            // 结束动画
            [_HUD hide:YES];
        }else {
            
            
            // 结束动画
            [_HUD hide:YES];
            // 删除成功
            [MBHUDView hudWithBody:@"删除成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
            
            
            // 做一个单例 用于删除首页数据
            if ([UserDefaults valueForKey:@"DelTieZiForMine"] == nil) {
                NSMutableArray *tempArr = [NSMutableArray array];
                [tempArr addObject:_strCurrentDelId];
                [UserDefaults setValue:tempArr forKey:@"DelTieZiForMine"];
            }else {
                NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelTieZiForMine"]];
                [tempArr addObject:_strCurrentDelId];
                [UserDefaults setValue:tempArr forKey:@"DelTieZiForMine"];
            }
            
            
            // 从当前数组删除这一条，并刷新列表
            SearchTieZiWithKeyWordModel *model = _tableViewArr[[_strCurrentDelPaiXu integerValue]];
            [_tableViewArr removeObject:model];
            [self.tableView reloadData];
        }
        
        _strCurrentDelId = @"";
        _strCurrentDelPaiXu = @"";
        
    } failure:^(NSError *error) {
        
        // 结束动画
        [_HUD hide:YES];
        // 请求失败
        _strCurrentDelId = @"";
        _strCurrentDelPaiXu = @"";
    }];
}

// 动态
- (void) dongtaiBtnBy:(UserLikeTieZiListModel *)model {
    DongTaiViewController * vc = [[DongTaiViewController alloc] init];
    [vc setHidesBottomBarWhenPushed:YES];
    vc.noteId = model.id1;
    [self.navigationController pushViewController:vc animated:YES];
}

// 取消分享点击事件
- (void) cancleBtnClick:(UIButton *)btn {
    [self.zh_popupController dismiss];
}
- (void) jubaoBtnClick:(UIButton *)jubaoBtn {
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    SearchTieZiWithKeyWordModel *model1 = [NSKeyedUnarchiver unarchiveObjectWithData:[user valueForKey:@"jubaoModel"]];
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([model1.uid isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        
        // 自己
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"这是您自己发的帖子哟~"];
        
    }else {
        
        // 不是自己
        // 先消失
        [self.zh_popupController dismiss];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"举报该帖子"
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"色情、政治敏感",@"广告、无聊",@"内容侵权、剽窃",@"其它违规",nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
        
        actionSheet.delegate = self;
        actionSheet.tag = 111;
    }
}
// 添加不喜欢用户
- (void) disLikeBtnClick:(UIButton *)btn {
    
    // 动画
    [self createLoadingForBtnClick];
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    UserLikeTieZiListModel *model1 = [NSKeyedUnarchiver unarchiveObjectWithData:[user valueForKey:@"jubaoModel"]];
    
    // 获取用户加密相关
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    NSDictionary *dic = @{@"uid":model1.uid};
    NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
    
    NSLog(@"********%@",dicData);
    
    // 进行数据请求
    HttpRequest *http = [[HttpRequest alloc] init];
    // 进行不喜欢数据请求
    [http PostAddDislikeUserWithDic:dicData Success:^(id userInfo) {
        
        [_HUD hide:YES];
        
        if ([userInfo isEqualToString:@"0"]) {
            
            
        }else {
            
            // 先消失弹出框
            [self.zh_popupController dismiss];
            // 提示
            [http GetHttpDefeatAlert:userInfo];
            // 删除用户单例
            [user removeObjectForKey:@"jubaoModel"];
            
            for (int i = 0; i < _tableViewArr.count; i++) {
                UserLikeTieZiListModel *model = _tableViewArr[i];
                if ([model1.uid isEqualToString:model.uid]) {
                    [_tableViewArr removeObjectAtIndex:i];
                    i --;
                }
            }
            
            [self.tableView reloadData];
            
            
            // 做一个单例 用于修改发现页面的推荐用户
            if ([UserDefaults valueForKey:@"FollowUserOrBlacklistUser"] == nil) {
                NSMutableArray *tempArr = [NSMutableArray array];
                [tempArr addObject:model1.uid];
                [UserDefaults setValue:tempArr forKey:@"FollowUserOrBlacklistUser"];
            }else {
                NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserOrBlacklistUser"]];
                [tempArr addObject:model1.uid];
                [UserDefaults setValue:tempArr forKey:@"FollowUserOrBlacklistUser"];
            }
            
        }
        
    } failure:^(NSError *error) {
        
        [_HUD hide:YES];
    }];
}
// 分享的Block触发的事件
- (void) shareBtnBy:(UserLikeTieZiListModel *)model {
    
    ShareAndOtherView *vc = [[ShareAndOtherView alloc] initWithFrame:CGRectMake(0, 0, W, 309)];
    [vc.cancleBtn addTarget:self action:@selector(cancleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [vc.jubaoBtn addTarget:self action:@selector(jubaoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [vc.disLikeBtn addTarget:self action:@selector(disLikeBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    self.zh_popupController = [zhPopupController new];
    self.zh_popupController.layoutType = zhPopupLayoutTypeBottom;
    [self.zh_popupController presentContentView:vc];
    
    
    // 把当前模型加进去
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 存储时直接把最外层数组转成NSData类型
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    [user setValue:data forKey:@"jubaoModel"];
    
    
    
//    NSLog(@"分享");
//    NSString *strTitle = @"嘚瑟";
//    NSString *strSummry = @"你，值得被追随\n他，嘚瑟却不失本色\n只有你，配得上我的特别";
    
//    //1、创建分享参数
//    NSArray* imageArray = @[[UIImage imageNamed:@"logo的副本"]];
//    if (imageArray) {
//        
//        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//        [shareParams SSDKSetupShareParamsByText:strSummry images:imageArray url:[NSURL URLWithString:@"https://app.blog.huopinb.com/Update.html"]title:strTitle type:SSDKContentTypeAuto];
//        
//        //2、分享（可以弹出我们的分享菜单和编辑界面）
//        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
//                                 items:nil
//                           shareParams:shareParams
//                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
//                       
//                       switch (state) {
//                           case SSDKResponseStateSuccess:
//                           {
//                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
//                                                                                   message:nil
//                                                                                  delegate:self
//                                                                         cancelButtonTitle:@"确定"
//                                                                         otherButtonTitles:nil];
//                               [alertView show];
//                               break;
//                           }
//                           case SSDKResponseStateFail:
//                           {
//                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
//                                                                               message:[NSString stringWithFormat:@"%@",error]
//                                                                              delegate:nil
//                                                                     cancelButtonTitle:@"OK"
//                                                                     otherButtonTitles:nil, nil];
//                               [alert show];
//                               break;
//                           }
//                           default:
//                               break;
//                       }
//                   }
//         ];}
}
// 评论的block
- (void) pinglunBtnBy:(UserLikeTieZiListModel *)model {
    PingLunViewController *vc = [[PingLunViewController alloc] init];
    [vc setHidesBottomBarWhenPushed:YES];
    vc.targetUid = model.uid;
    vc.noteId = model.id1;
    [self.navigationController pushViewController:vc animated:YES];
}
// 展示图片点击
- (void) showImgViewBy:(NSArray *)imgArr {
    [XLPhotoBrowser showPhotoBrowserWithImages:imgArr currentImageIndex:0];
}
// 头像点击block触发事件
- (void) iconImgViewBy:(UserLikeTieZiListModel *)model {
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 拿到用户id
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([model.uid isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        [TipIsYourSelf tipIsYourSelf];
    }else {
        // 跳转到他人主页
        OtherMineViewController *vc = [[OtherMineViewController alloc] init];
        [vc setHidesBottomBarWhenPushed:YES];
        vc.userId = model.uid;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


// 喜欢点击block触发事件
- (void)loveButtonBy:(NSIndexPath *)indexPath {
    
    // 数据请求对象
    HttpRequest *http = [[HttpRequest alloc] init];
    // 用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    
    // 点击时候的震动反馈
    AudioServicesPlaySystemSound(1519);
    
    UserLikeTieZiListModel *model = _tableViewArr[indexPath.row];
    
    // 喜欢动画设置
    [self playAnimation:indexPath];
    
    
    
    NSDictionary *idDic = @{@"noteId":model.id1};
    NSString *dataStr = [[MakeJson createJson:idDic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStr};
    
    // 修改状态
    if ([model.type isEqualToString:@"1"]) {
        HomeImgTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        cell.praiseBtn.userInteractionEnabled = NO;
        if (cell.praiseBtn.selected == NO) {
            // 进行喜欢数据请求
            [http PostAddLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"喜欢帖子失败");
                }else {
                    NSLog(@"喜欢帖子成功");
                    model.isLike = @"YES";
                    
                    // 做一个单例 喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"LoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"LoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }else {
            // 进行删除喜欢数据请求
            [http PostDelLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"删除喜欢帖子失败");
                }else {
                    NSLog(@"删除喜欢帖子成功");
                    model.isLike = @"NO";
                    
                    // 做一个单例 取消喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }
        cell.praiseBtn.selected = !cell.praiseBtn.selected;
        
    }else if ([model.type isEqualToString:@"0"]) {
        HomeTextCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        cell.praiseBtn.userInteractionEnabled = NO;
        if (cell.praiseBtn.selected == NO) {
            // 进行喜欢数据请求
            [http PostAddLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"喜欢帖子失败");
                }else {
                    NSLog(@"喜欢帖子成功");
                    model.isLike = @"YES";
                    
                    // 做一个单例 喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"LoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"LoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }else {
            // 进行喜欢数据请求
            [http PostDelLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"删除喜欢帖子失败");
                }else {
                    NSLog(@"删除喜欢帖子成功");
                    model.isLike = @"NO";
                    
                    // 做一个单例 取消喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }
        cell.praiseBtn.selected = !cell.praiseBtn.selected;
    }else {
        HomeVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        cell.praiseBtn.userInteractionEnabled = NO;
        if (cell.praiseBtn.selected == NO) {
            // 进行喜欢数据请求
            [http PostAddLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"喜欢帖子失败");
                }else {
                    NSLog(@"喜欢帖子成功");
                    model.isLike = @"YES";
                    
                    // 做一个单例 喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"LoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"LoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }else {
            // 进行喜欢数据请求
            [http PostDelLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"删除喜欢帖子失败");
                }else {
                    NSLog(@"删除喜欢帖子成功");
                    model.isLike = @"NO";
                    
                    // 做一个单例 取消喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }
        cell.praiseBtn.selected = !cell.praiseBtn.selected;
    }
}

-(void)playAnimation:(NSIndexPath *)indexpath{
    
    UserLikeTieZiListModel *model = _tableViewArr[indexpath.row];
    
    // 原始的动态数
    NSInteger activeNum = [model.active_num integerValue];

    
    if ([model.type isEqualToString:@"1"]) {
        HomeImgTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section]];
        if (!cell.praiseBtn.selected) {
            cell.coverBtn.alpha = 1;
            [UIView animateWithDuration:1.0f animations:^{
                cell.coverBtn.frame = CGRectMake(cell.praiseBtn.frame.origin.x, cell.praiseBtn.frame.origin.y-70, KPraiseBtnWH*2, KPraiseBtnWH*2);
                
                CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
                NSValue *value1 = [NSNumber numberWithFloat:-M_PI/180*5];
                NSValue *value2 = [NSNumber numberWithFloat:M_PI/180*5];
                NSValue *value3 = [NSNumber numberWithFloat:-M_PI/180*5];
                anima.values = @[value1,value2,value3];
                anima.repeatCount = MAXFLOAT;
                [cell.coverBtn.layer addAnimation:anima forKey:nil];
                
                cell.coverBtn.alpha = 0;
                cell.coverBtn.centerX = cell.praiseBtn.centerX;
            } completion:^(BOOL finished) {
                cell.coverBtn.frame = cell.praiseBtn.frame;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
            
            // 改变数据模型
            [model setValue:[NSString stringWithFormat:@"%ld",activeNum+1] forKey:@"active_num"];
            // 刷新某一行
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
            
            
        } else {
            cell.cancelPraiseImg.hidden = NO;
            NSArray *imgArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"icon_like_broken1"],[UIImage imageNamed:@"icon_like_broken2"],[UIImage imageNamed:@"icon_like_broken3"],[UIImage imageNamed:@"icon_like_broken4"], nil];
            cell.cancelPraiseImg.animationImages = imgArr;
            cell.cancelPraiseImg.animationDuration = KBorkenTime;
            cell.cancelPraiseImg.animationRepeatCount = 1;
            [cell.cancelPraiseImg startAnimating];
            
            [UIView animateWithDuration:KBorkenTime animations:^{
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 0;
            }completion:^(BOOL finished) {
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y-40, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 1;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
            
            // 改变数据模型
            [model setValue:[NSString stringWithFormat:@"%ld",activeNum-1] forKey:@"active_num"];
            // 刷新某一行
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
            
        }
    }else if ([model.type isEqualToString:@"0"]) {
        HomeTextCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section]];
        if (!cell.praiseBtn.selected) {
            cell.coverBtn.alpha = 1;
            [UIView animateWithDuration:1.0f animations:^{
                cell.coverBtn.frame = CGRectMake(cell.praiseBtn.frame.origin.x, cell.praiseBtn.frame.origin.y-70, KPraiseBtnWH*2, KPraiseBtnWH*2);
                
                CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
                NSValue *value1 = [NSNumber numberWithFloat:-M_PI/180*5];
                NSValue *value2 = [NSNumber numberWithFloat:M_PI/180*5];
                NSValue *value3 = [NSNumber numberWithFloat:-M_PI/180*5];
                anima.values = @[value1,value2,value3];
                anima.repeatCount = MAXFLOAT;
                [cell.coverBtn.layer addAnimation:anima forKey:nil];
                
                cell.coverBtn.alpha = 0;
                cell.coverBtn.centerX = cell.praiseBtn.centerX;
            } completion:^(BOOL finished) {
                cell.coverBtn.frame = cell.praiseBtn.frame;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
            // 改变数据模型
//            [model setValue:[NSString stringWithFormat:@"%ld",activeNum+1] forKey:@"active_num"];
//            // 刷新某一行
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
            
        } else {
            cell.cancelPraiseImg.hidden = NO;
            NSArray *imgArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"icon_like_broken1"],[UIImage imageNamed:@"icon_like_broken2"],[UIImage imageNamed:@"icon_like_broken3"],[UIImage imageNamed:@"icon_like_broken4"], nil];
            cell.cancelPraiseImg.animationImages = imgArr;
            cell.cancelPraiseImg.animationDuration = KBorkenTime;
            cell.cancelPraiseImg.animationRepeatCount = 1;
            [cell.cancelPraiseImg startAnimating];
            
            [UIView animateWithDuration:KBorkenTime animations:^{
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 0;
            }completion:^(BOOL finished) {
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y-40, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 1;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
            
            // 改变数据模型
//            [model setValue:[NSString stringWithFormat:@"%ld",activeNum-1] forKey:@"active_num"];
//            // 刷新某一行
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else {
        
        HomeVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section]];
        if (!cell.praiseBtn.selected) {
            cell.coverBtn.alpha = 1;
            [UIView animateWithDuration:1.0f animations:^{
                cell.coverBtn.frame = CGRectMake(cell.praiseBtn.frame.origin.x, cell.praiseBtn.frame.origin.y-70, KPraiseBtnWH*2, KPraiseBtnWH*2);
                
                CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
                NSValue *value1 = [NSNumber numberWithFloat:-M_PI/180*5];
                NSValue *value2 = [NSNumber numberWithFloat:M_PI/180*5];
                NSValue *value3 = [NSNumber numberWithFloat:-M_PI/180*5];
                anima.values = @[value1,value2,value3];
                anima.repeatCount = MAXFLOAT;
                [cell.coverBtn.layer addAnimation:anima forKey:nil];
                
                cell.coverBtn.alpha = 0;
                cell.coverBtn.centerX = cell.praiseBtn.centerX;
            } completion:^(BOOL finished) {
                cell.coverBtn.frame = cell.praiseBtn.frame;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
            // 未选中状态
            // 改变数据模型
            [model setValue:[NSString stringWithFormat:@"%ld",activeNum+1] forKey:@"active_num"];
            // 刷新某一行
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
            
            
        } else {
            cell.cancelPraiseImg.hidden = NO;
            NSArray *imgArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"icon_like_broken1"],[UIImage imageNamed:@"icon_like_broken2"],[UIImage imageNamed:@"icon_like_broken3"],[UIImage imageNamed:@"icon_like_broken4"], nil];
            cell.cancelPraiseImg.animationImages = imgArr;
            cell.cancelPraiseImg.animationDuration = KBorkenTime;
            cell.cancelPraiseImg.animationRepeatCount = 1;
            [cell.cancelPraiseImg startAnimating];
            
            [UIView animateWithDuration:KBorkenTime animations:^{
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 0;
            }completion:^(BOOL finished) {
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y-40, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 1;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
            
            // 未选中状态
            // 改变数据模型
            [model setValue:[NSString stringWithFormat:@"%ld",activeNum-1] forKey:@"active_num"];
            // 刷新某一行
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

//  一个string转换成AttributedString的方法
-(NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace; // 调整行间距
    NSRange range = NSMakeRange(0, [string length]);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attributedString;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath---%zd",indexPath.row);
}


- (ZFPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [ZFPlayerView sharedPlayerView];
        _playerView.delegate = self;
        
        // 当cell播放视频由全屏变为小屏时候，不回到中间位置
        _playerView.cellPlayerOnCenter = NO;
        // 当cell划出屏幕的时候停止播放
         _playerView.stopPlayWhileCellNotVisable = YES;
        //（可选设置）可以设置视频的填充模式，默认为（等比例填充，直到一个维度到达区域边界）
//         _playerView.playerLayerGravity = ZFPlayerLayerGravityResizeAspect;
        // 静音
         _playerView.mute = NO;
    }
    
    return _playerView;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [[ZFPlayerControlView alloc] init];
    }
    return _controlView;
}

#pragma mark - ZFPlayerDelegate

//- (void)zf_playerDownload:(NSString *)url {
//    // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
//    NSString *name = [url lastPathComponent];
//    [[ZFDownloadManager sharedDownloadManager] downFileUrl:url filename:name fileimage:nil];
//    // 设置最多同时下载个数（默认是3）
//    [ZFDownloadManager sharedDownloadManager].maxCount = 4;
//}


// 监听处理事件
- (void)listen:(NSNotification *)noti {
    
    NSString *strNoti = noti.object;

    
    // 登录成功
    if ([strNoti isEqualToString:@"1"]) {
        
        // 重新获取用户资料数据
        [self downRefresh];
        
        // 销毁用户登录成功的通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginSuccessForShouye" object:@"1"];
    }
    
    
    // 修改成功
    if ([strNoti isEqualToString:@"6666"]) {
        
        NSDictionary *dicForAfter = noti.userInfo;
        
        for (int i = 0; i < _tableViewArr.count; i++) {
            UserLikeTieZiListModel *tempModel = _tableViewArr[i];
            if ([tempModel.id1 isEqualToString:[dicForAfter valueForKey:@"id"]]) {
                
                tempModel.content = [dicForAfter valueForKey:@"content"];
                tempModel.private_flag = [dicForAfter valueForKey:@"privateFlag"];
                tempModel.kwList = [dicForAfter valueForKey:@"keywords"];
            }
        }
        
        [self.tableView reloadData];
    }
    
//    // 用户资料修改了，在此修改头像和昵称
//    if ([strNoti isEqualToString:@"20"]) {
//        
//        NSLog(@"_tableViewArr%@",_tableViewArr);
//        
//        // 重新获取用户资料数据
//        [self.tableView reloadData];
//    }
    
}


// 页面消失时候
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.playerView resetPlayer];
    
    // 删除单例
    [UserDefaults removeObjectForKey:@"LoveTieZiForReviseHome"];
    [UserDefaults removeObjectForKey:@"DelLoveTieZiForReviseHome"];
    [UserDefaults removeObjectForKey:@"DelTieZiForShouYe"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reviseTieZiSuccess" object:@"666"];
}


- (void)dealloc {
    
    /*
     *移除指定通知
     */
}


// 页面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    // 不隐藏导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // 设置导航栏背景色
    [self.navigationController.navigationBar setBarTintColor:FUIColorFromRGB(0x151515)];
    
    //这个接口可以动画的改变statusBar的前景色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    
    // 接收消息
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    
    
    // 登录成功
    [notiCenter addObserver:self selector:@selector(listen:) name:@"loginSuccessForShouye" object:@"1"];
    
    // 修改成功
    [notiCenter addObserver:self selector:@selector(listen:) name:@"reviseTieZiSuccess" object:@"6666"];
//    // 发帖成功
//    [notiCenter addObserver:self selector:@selector(listen:) name:@"fatieChengGong" object:@"20"];
    
    
    
    // 取出单例,判断是否需要删除当前数据
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelTieZiForShouYe"]];
    NSMutableArray *DelTieZiForShouYeArr = [[NSMutableArray alloc]init];
    for (NSString *str in tempArr) {
        if (![DelTieZiForShouYeArr containsObject:str]) {
            [DelTieZiForShouYeArr addObject:str];
        }
    }
    if (_tableViewArr.count > 0) {
        for (int i = 0; i < DelTieZiForShouYeArr.count; i++) {
            
            for (int j = 0; j < _tableViewArr.count; j++) {
                
                UserLikeTieZiListModel *tempModel = _tableViewArr[j];
                if ([tempModel.id1 isEqualToString:DelTieZiForShouYeArr[i]]) {
                    [_tableViewArr removeObject:tempModel];
                }
            }
            
            if (i == DelTieZiForShouYeArr.count - 1) {
                
                if (_tableViewArr == 0) {
                    // 下拉刷新
                    [self downRefresh];
                }else {
                    
                    // 刷新当前tableView
                    [self.tableView reloadData];
                }
            }
        }
    }
    
    
    // 取出单例 用于判断喜欢状态是否需要更新
    // 其他喜欢帖子临时数组
    NSMutableArray *tempArr1 = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"LoveTieZiForReviseHome"]];
    NSMutableArray *LoveTieZiForReviseHomeArr = [[NSMutableArray alloc]init];
    for (NSString *str in tempArr1) {
        if (![LoveTieZiForReviseHomeArr containsObject:str]) {
            [LoveTieZiForReviseHomeArr addObject:str];
        }
    }
    // 其他取消喜欢帖子临时数组
    NSMutableArray *tempArr2 = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelLoveTieZiForReviseHome"]];
    NSMutableArray *DelLoveTieZiForReviseHomeArr = [[NSMutableArray alloc]init];
    for (NSString *str in tempArr2) {
        if (![DelLoveTieZiForReviseHomeArr containsObject:str]) {
            [DelLoveTieZiForReviseHomeArr addObject:str];
        }
    }
    
    NSArray *arrTemp = [NSArray arrayWithArray:DelLoveTieZiForReviseHomeArr];
    for (NSString *str in arrTemp) {
        
        if ([LoveTieZiForReviseHomeArr containsObject:str]) {
            [LoveTieZiForReviseHomeArr removeObject:str];
            [DelLoveTieZiForReviseHomeArr removeObject:str];
        }
    }
    
    NSLog(@"*******%@,,,%@",LoveTieZiForReviseHomeArr,DelLoveTieZiForReviseHomeArr);
    
    // 拿到实际操作了的喜欢不喜欢临时数组
    if (_tableViewArr.count > 0) {
        for (int i = 0; i < LoveTieZiForReviseHomeArr.count; i++) {
            
            for (int j = 0; j < _tableViewArr.count; j++) {
                
                UserLikeTieZiListModel *tempModel = _tableViewArr[j];
                
                if ([tempModel.id1 isEqualToString:LoveTieZiForReviseHomeArr[i]]) {
                    
                    UserLikeTieZiListModel *model = _tableViewArr[j];
                    model.isLike = @"YES";
                }
            }
            
            if (i == LoveTieZiForReviseHomeArr.count - 1) {
                [self.tableView reloadData];
            }
        }
        for (int i = 0; i < DelLoveTieZiForReviseHomeArr.count; i++) {
            
            
            for (int j = 0; j < _tableViewArr.count; j++) {
                
                UserLikeTieZiListModel *tempModel = _tableViewArr[j];
                
                if ([tempModel.id1 isEqualToString:DelLoveTieZiForReviseHomeArr[i]]) {
                    
                    UserLikeTieZiListModel *model = _tableViewArr[j];
                    model.isLike = @"NO";
                }
            }
            
            if (i == DelLoveTieZiForReviseHomeArr.count - 1) {
                [self.tableView reloadData];
            }
        }
    }
    
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
