//
//  MineFocusViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/7/28.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "MineFocusViewController.h"
#import "MineFocusCell.h"
#import "FollowUserInfoListModel.h" // 关注用户信息列表Model
#import "OtherMineViewController.h" // 他人个人中心

// 单例
#define USER [NSUserDefaults standardUserDefaults]

@interface MineFocusViewController () <UITableViewDelegate, UITableViewDataSource> {
        
    BOOL _canScroll; // 是否可滚动
    
    NSInteger pageStart; // 请求数据开始位置
    NSInteger pageSize; // 一页的数量
    
    NSArray *_arrForAllLikeUserId; // 所有喜欢的人的id
    
}

@property (nonatomic,copy) NSMutableArray *tableViewArr;
@property (nonatomic,copy) UITableView *tableView;

@end

@implementation MineFocusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    
    if ([[USER valueForKey:@"_tableViewCanScroll"] isEqualToString:@"NO"]) {
        
        _canScroll = NO;
    }else {
        
        _canScroll = YES;
    }
    
    // 初始化数组
    [self initArr];
    
    // 创建tbv
    [self createTableView];
    
    // 获取数据
    [self initDataSource];
    
}

// 初始化数组
- (void) initArr {
    
    // 初始化
    pageStart = 0;
    pageSize = 10;
    
    // 初始化数组
    _tableViewArr = [NSMutableArray array];
    
    _arrForAllLikeUserId = [NSMutableArray array];
}

// 请求
- (void) initDataSource {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 用户加密数组
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    
    if (pageStart == 0) {
        
        NSDictionary *dicdata = @{@"pageSize":[NSString stringWithFormat:@"%ld",pageSize]};
        NSString *strData = [[MakeJson createJson:dicdata] AES128EncryptWithKey:userJiaMiArr[3]];
        NSDictionary *dicForData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
        // 测试获取关注用户的信息
        [http PostGetFollowUserInfoListForUcenterWithDic:dicForData Success:^(id userInfo) {
            
            // 请求成功
            [_tableViewArr removeAllObjects];
            _tableViewArr = [NSMutableArray arrayWithArray:userInfo];
            
            
            // 表格刷新完毕,结束上下刷新视图
            [_tableView.mj_footer resetNoMoreData];
            
            
            NSDictionary *dicLikeAllList = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2]};
            // 获取用户所有关注的人的ID
            [http PostGetAllFollowUserIdListWithDic:dicLikeAllList Success:^(id userInfo) {
                
                if ([userInfo isEqualToString:@"error"]) {
                    
                    NSLog(@"FNJKDSAFNKDANFJKASNFJKADJFKAS");
                    // 刷新列表
                    [self.tableView reloadData];
                    // 表格刷新完毕,结束上下刷新视图
                    [_tableView.mj_footer endRefreshing];
                    
                }else {
                    
                    // 拿到了
                    _arrForAllLikeUserId = [userInfo componentsSeparatedByString:@","];
                    
                    for (int i = 0; i < _tableViewArr.count; i++) {
                        
                        FollowUserInfoListModel *model = _tableViewArr[i];
                        // 判断是否已经喜欢
                        if ([_arrForAllLikeUserId containsObject:model.id1]) {
                            model.isfollowUser = @"YES";
                        }else {
                            model.isfollowUser = @"NO";
                        }
                    }
                }
                // 刷新列表
                [self.tableView reloadData];
                // 表格刷新完毕,结束上下刷新视图
                [_tableView.mj_footer endRefreshing];
                
            } failure:^(NSError *error) {
                
                // 刷新列表
                [self.tableView reloadData];
                // 表格刷新完毕,结束上下刷新视图
                [_tableView.mj_footer endRefreshing];
            }];
            
            
        } failure:^(NSError *error) {
            
            // 刷新列表
            [self.tableView reloadData];
            // 表格刷新完毕,结束上下刷新视图
            [_tableView.mj_footer endRefreshing];
        }];
        
    }else {
        
        FollowUserInfoListModel *model = [_tableViewArr lastObject];
        
        NSDictionary *dicdata = @{@"pageSize":[NSString stringWithFormat:@"%ld",pageSize],@"startTime":model.followTime,@"lastUserId":model.id1};
        NSString *strData = [[MakeJson createJson:dicdata] AES128EncryptWithKey:userJiaMiArr[3]];
        NSDictionary *dicForData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
        // 测试获取关注用户的信息
        [http PostGetFollowUserInfoListForUcenterWithDic:dicForData Success:^(id userInfo) {
            
            // 请求成功
            [_tableViewArr addObjectsFromArray:userInfo];
            
            if ([userInfo count] == 0) {
                // 显示没有更多数据
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                // 有数据
                NSDictionary *dicLikeAllList = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2]};
                // 获取用户所有关注的人的ID
                [http PostGetAllFollowUserIdListWithDic:dicLikeAllList Success:^(id userInfo) {
                    
                    if ([userInfo isEqualToString:@"error"]) {
                        
                        NSLog(@"FNJKDSAFNKDANFJKASNFJKADJFKAS");
                        // 刷新列表
                        [self.tableView reloadData];
                        // 表格刷新完毕,结束上下刷新视图
                        [_tableView.mj_footer endRefreshing];
                        
                    }else {
                        
                        // 拿到了
                        _arrForAllLikeUserId = [userInfo componentsSeparatedByString:@","];
                        
                        for (int i = 0; i < _tableViewArr.count; i++) {
                            
                            FollowUserInfoListModel *model = _tableViewArr[i];
                            // 判断是否已经喜欢
                            if ([_arrForAllLikeUserId containsObject:model.id1]) {
                                model.isfollowUser = @"YES";
                            }else {
                                model.isfollowUser = @"NO";
                            }
                        }
                    }
                    // 刷新列表
                    [self.tableView reloadData];
                    // 表格刷新完毕,结束上下刷新视图
                    [_tableView.mj_footer endRefreshing];
                    
                } failure:^(NSError *error) {
                    
                    // 刷新列表
                    [self.tableView reloadData];
                    // 表格刷新完毕,结束上下刷新视图
                    [_tableView.mj_footer endRefreshing];
                }];
            }
            
        } failure:^(NSError *error) {
            
            // 刷新列表
            [self.tableView reloadData];
            // 表格刷新完毕,结束上下刷新视图
            [_tableView.mj_footer endRefreshing];
        }];
    }
}

// 创建TableView
- (void) createTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, W,  H - 5 - 20 - W * 0.78125 * 0.13 - 49) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = _canScroll;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 继续配置_tableView;
    // 设置_tableView的底部
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 调用上拉刷新方法
        [self upRefresh];
    }];
    
    [_tableView registerClass:[MineFocusCell class] forCellReuseIdentifier:@"cell"];
    
}

// 上拉刷新方法
- (void)upRefresh {
    
    // 起始位置
    pageStart = _tableViewArr.count;
    
    // 请求数据
    [self initDataSource];
}

#pragma mark ---- UITableViewDelegate,UITableViewDataSource ---
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _tableViewArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"Cell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
    MineFocusCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
    if (cell == nil) {
        cell = [[MineFocusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // 数据模型
    FollowUserInfoListModel *model = _tableViewArr[indexPath.row];
    
    // 用户单利
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    
    [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:[model.img valueForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
    cell.nickNameLb.text = model.nickname;
    cell.focusNumLb.text = [NSString stringWithFormat:@"%@人关注",model.followNum];
    cell.signLb.text = model.sign;
    if ([model.isfollowUser isEqualToString:@"YES"]) {
        cell.focusBtn.selected = YES;
        cell.focusBtn.backgroundColor = FUIColorFromRGB(0xffffff);
    }else {
        cell.focusBtn.selected = NO;
        cell.focusBtn.backgroundColor = [UIColor colorWithRed:250/255.0 green:170/255.0 blue:44/255.0 alpha:1.0];
    }
    
    
    // 拿到用户id
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([model.id1 isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:model];
        };
    }else {
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:model];
        };
    }
    
    
    // 右侧按钮Blokc
    cell.focusBtnViewClick = ^{
        [self focusBtnBy:indexPath];
    };
    
    
    return cell;
}

// 头像点击block触发事件
- (void) iconImgViewBy:(FollowUserInfoListModel *)model {
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 拿到用户id
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([model.id1 isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        
        [TipIsYourSelf tipIsYourSelf];
        
    }else {
        
        // 跳转到他人主页
        OtherMineViewController *vc = [[OtherMineViewController alloc] init];
        [vc setHidesBottomBarWhenPushed:YES];
        vc.userId = model.id1;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

// 关注按钮的点击事件
- (void) focusBtnBy:(NSIndexPath *)indexPath {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    // 数据模型
    FollowUserInfoListModel *model = _tableViewArr[indexPath.row];
    
    NSDictionary *idDic = @{@"uid":model.id1};
    NSString *dataStr = [[MakeJson createJson:idDic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStr};
    
    
    MineFocusCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    cell.focusBtn.userInteractionEnabled = NO;
    if (cell.focusBtn.selected == NO) {
        // 进行关注数据请求
        [http PostAddFollowUserWithDic:dicData Success:^(id userInfo) {
            // 打开用户交互
            cell.focusBtn.userInteractionEnabled = YES;
            // 数据请求成功
            if ([userInfo isEqualToString:@"0"]) {
                NSLog(@"关注用户失败");
            }else {
                // 关注成功
                cell.focusBtn.selected = !cell.focusBtn.selected;
//                [MBHUDView hudWithBody:@"关注用户成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                [http GetHttpDefeatAlert:@"关注用户成功"];
                model.isfollowUser = @"YES";
                [self.tableView reloadData];
                
                
                // 做一个单例 用于修改发现页面的推荐用户
                if ([UserDefaults valueForKey:@"FollowUserOrBlacklistUser"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:model.id1];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserOrBlacklistUser"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserOrBlacklistUser"]];
                    [tempArr addObject:model.id1];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserOrBlacklistUser"];
                }
                
                // 做一个单例 用于修改发现页面的推荐用户
                if ([UserDefaults valueForKey:@"FollowUserForNews"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:model.id1];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserForNews"]];
                    [tempArr addObject:model.id1];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                }
                
            }
        } failure:^(NSError *error) {
            // 数据请求失败
            // 打开用户交互
            cell.focusBtn.userInteractionEnabled = YES;
        }];
    }else {
        
        // 进行删除关注数据请求
        [http PostDelFollowUserWithDic:dicData Success:^(id userInfo) {
            // 打开用户交互
            cell.focusBtn.userInteractionEnabled = YES;
            // 数据请求成功
            if ([userInfo isEqualToString:@"0"]) {
                NSLog(@"关注用户失败");
            }else {
                // 取消关注成功
                cell.focusBtn.selected = !cell.focusBtn.selected;
//                [MBHUDView hudWithBody:@"取消关注成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                [http GetHttpDefeatAlert:@"取消关注成功"];
                model.isfollowUser = @"NO";
                [self.tableView reloadData];
                
                // 做一个单例 用于修改发现页面的推荐用户
                if ([UserDefaults valueForKey:@"CancleFollowUser"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:model.id1];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUser"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"CancleFollowUser"]];
                    [tempArr addObject:model.id1];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUser"];
                }
                
                // 做一个单例 用于修改消息页面的用户关注状态
                if ([UserDefaults valueForKey:@"CancleFollowUserForNews"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:model.id1];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUserForNews"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"CancleFollowUserForNews"]];
                    [tempArr addObject:model.id1];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUserForNews"];
                }
            }
        } failure:^(NSError *error) {
            // 数据请求失败
            // 打开用户交互
            cell.focusBtn.userInteractionEnabled = YES;
        }];
    }
}

// tableview的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// 没行的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //    NSIndexPath *path =  [_tableView indexPathForRowAtPoint:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y)];
    
    //    NSLog(@"这是第%ld行",path.row);
    
    if (scrollView.contentOffset.y < 0) {
        
        _canScroll = NO;
        
        _tableView.scrollEnabled = _canScroll;
        
        // 发送通知,用于修改资料
        // 创建消息中心
        NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
        // 在消息中心发布自己的消息
        [notiCenter postNotificationName:@"xiugaiScrollMine" object:@"14"];
        
        
        // 在消息中心发布自己的消息
        [notiCenter postNotificationName:@"xiugaitableViewScrollForOther1" object:@"17"];
    }
}


// 监听处理事件
- (void)listen:(NSNotification *)noti {
    
    NSString *strNoti = noti.object;
    
    
    // 用户资料修改了，在此修改头像和昵称
    if ([strNoti isEqualToString:@"11"]) {
        
        _canScroll = YES;
        
        // 重新获取用户资料数据
        _tableView.scrollEnabled = _canScroll;
        
        
        // 创建消息中心
        NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
        // 在消息中心发布自己的消息
        [notiCenter postNotificationName:@"xiugaiScrollMineNo" object:@"15"];
        
        // 销毁用户修改了资料的通知
        //        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"xiugaiScroll1" object:@"11"];
    }
    
    if ([strNoti isEqualToString:@"16"]) {
        
        _canScroll = NO;
        
        [_tableView setContentOffset:CGPointMake(0,0) animated:NO];
        
        // 重新获取用户资料数据
        _tableView.scrollEnabled = _canScroll;
        
    }
    
    if ([strNoti isEqualToString:@"18"]) {
        
        _canScroll = NO;
        
        [_tableView setContentOffset:CGPointMake(0,0) animated:NO];
        
        // 重新获取用户资料数据
        _tableView.scrollEnabled = _canScroll;
        
    }
}

- (void) viewDidAppear:(BOOL)animated {
    
    self.tableView.contentOffset = CGPointMake(0, -1);
}

// 页面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    // 接收消息
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    // 修改滚动
    [notiCenter addObserver:self selector:@selector(listen:) name:@"xiugaiScroll1" object:@"11"];
    // 修改滚动
    [notiCenter addObserver:self selector:@selector(listen:) name:@"xiugaitableViewScrollForOther" object:@"16"];
    // 修改滚动
    [notiCenter addObserver:self selector:@selector(listen:) name:@"xiugaitableViewScrollForOther2" object:@"18"];
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
