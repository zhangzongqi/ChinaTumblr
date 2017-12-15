//
//  WMNoticeViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/1.
//  Copyright © 2017年 张宗琦. All rights reserved.
//  消息

#import "WMNoticeViewController.h"
#import "WMNoticeTextCell.h" // 消息里面的文字Cell
#import "WMNoticePhotoCell.h" // 消息里面的配图Cell
#import "WMNoticeFocusOnCell.h" // 消息里面的关注Cell
#import "DongTaiModel.h" // 动态模型
#import "OtherMineViewController.h" // 他人主页
#import "DetailImgViewController.h"
#import "PingLunViewController.h" // 评论页面

#import "JPUSHService.h" 
#import "UITabBarItem+WZLBadge.h"

@interface WMNoticeViewController ()<UITableViewDelegate,UITableViewDataSource> {
    
    NSInteger pageStart; // 请求数据开始位置
    NSInteger pageSize; // 一页的数量
    
    NSArray *_arrForAllLikeUserId; // 所有关注的人的id
    
}

// tableView
@property (nonatomic ,copy) UITableView *tableView;

// tableView数据数组
@property (nonatomic, strong) NSMutableArray *tableViewArr;

// 动画
@property (nonatomic, copy) MBProgressHUD *HUD;


@end

@implementation WMNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 背景色
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 初始化数组
    [self initArr];
    
    // 布局页面
    [self layoutViews];
    
    // 动画
    [self createLoadingForBtnClick];
    
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
    
    // 所有关注的人的id
    _arrForAllLikeUserId = [NSArray array];
}

// 请求数据
- (void) initData {
    
    // 数据请求
    HttpRequest *http = [[HttpRequest alloc] init];
    // 用户加密相关
    NSArray * userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    // 第0页
    if (pageStart == 0) {
        
        // 设置图标上的推送消息个数
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        [JPUSHService resetBadge];
        
        [self.tabBarController.tabBar.items[3] clearBadge];
        
        // 分页Dic
        NSDictionary *dic = @{@"pageSize":[NSString stringWithFormat:@"%ld",pageSize]};
        NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
        // 最终请求数据需要的data
        NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
        
        NSDictionary *dicDataForUserLike = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2]};
        
        NSLog(@"***********%@",dicData);
        
        // 获取通知消息
        [http PostGetMessageForPageWithDic:dicData Success:^(id userInfo) {
            
            // 清空数据
            [_tableViewArr removeAllObjects];
            
            NSLog(@"userInfo:::%@",userInfo);
            
            if ([userInfo isEqualToString:@"0"]) {
                
                // 没拿到后台的数据
                // 隐藏动画
                [_HUD hide:YES];
                
                // 更换数据
                [_tableView reloadData];
                
                [self.tableView.mj_header endRefreshing];
                // 表格刷新完毕,结束上下刷新视图
                [self.tableView.mj_footer resetNoMoreData];
                
            }else {
                
                NSDictionary *UserListDic = [MakeJson createDictionaryWithJsonString:userInfo];
                
                // 拿到数组
                NSArray *UserListArr = [UserListDic valueForKey:@"dataList"];
                // 通过模型存入数组
                NSMutableArray *arrSearchUserInfoList = [DongTaiModel arrayOfModelsFromDictionaries:UserListArr error:nil];
                // 更换数据
                [_tableViewArr addObjectsFromArray:arrSearchUserInfoList];
                
                // 获取用户所有关注的人的ID
                [http PostGetAllFollowUserIdListWithDic:dicDataForUserLike Success:^(id userInfo) {
                    
                    if ([userInfo isEqualToString:@"error"]) {
                        
                        NSLog(@"FNJKDSAFNKDANFJKASNFJKADJFKAS");
                        
                    }else {
                        
                        // 拿到了
                        _arrForAllLikeUserId = [userInfo componentsSeparatedByString:@","];
                        
                        NSLog(@"FNJKDSAFNKDANFJKASNFJKADJFKAS:::%@",_arrForAllLikeUserId);
                        
                        for (int i = 0; i < _tableViewArr.count; i++) {
                            
                            DongTaiModel *model = _tableViewArr[i];
                            // 判断是否已经喜欢
                            if ([_arrForAllLikeUserId containsObject:model.uid]) {
                                model.isFocus = @"YES";
                            }else {
                                model.isFocus = @"NO";
                            }
                        }
                    }
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    // 表格刷新完毕,结束上下刷新视图
                    [self.tableView.mj_footer resetNoMoreData];
                    [self.tableView.mj_header endRefreshing];
                    // 刷新列表
                    [self.tableView reloadData];
                    
                } failure:^(NSError *error) {
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    // 表格刷新完毕,结束上下刷新视图
                    [self.tableView.mj_footer resetNoMoreData];
                    [self.tableView.mj_header endRefreshing];
                    // 刷新列表
                    [self.tableView reloadData];
                }];
            }
            
        } failure:^(NSError *error) {
            
            // 隐藏动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer resetNoMoreData];
            [self.tableView.mj_header endRefreshing];
        }];
        
    }else {
        
        // 数据模型
        DongTaiModel *model = [_tableViewArr lastObject];
        
        // 分页Dic
        NSDictionary *dic = @{@"startTime":model.create_time,@"lastMsgId":model.msgId,@"pageSize":[NSString stringWithFormat:@"%ld",pageSize]};
        NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
        // 最终请求数据需要的data
        NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
        
        NSDictionary *dicDataForUserLike = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2]};
        
        
        // 获取通知消息
        [http PostGetMessageForPageWithDic:dicData Success:^(id userInfo) {
            
            if ([userInfo isEqualToString:@"0"]) {
                // 隐藏动画
                [_HUD hide:YES];
                // 已全部加载
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                
            }else {
                
                // 拿到字典
                NSDictionary *UserListDic = [MakeJson createDictionaryWithJsonString:userInfo];
                // 拿到数据
                NSArray *UserListArr = [UserListDic valueForKey:@"dataList"];
                // 拿到数据模型
                NSMutableArray *arrSearchUserInfoList = [DongTaiModel arrayOfModelsFromDictionaries:UserListArr error:nil];
                
                // 更换数据
                [_tableViewArr addObjectsFromArray:arrSearchUserInfoList];
                
                
                // 获取用户所有关注的人的ID
                [http PostGetAllFollowUserIdListWithDic:dicDataForUserLike Success:^(id userInfo) {
                    
                    if ([userInfo isEqualToString:@"error"]) {
                        
                        NSLog(@"FNJKDSAFNKDANFJKASNFJKADJFKAS");
                        
                    }else {
                        
                        // 拿到了
                        _arrForAllLikeUserId = [userInfo componentsSeparatedByString:@","];
                        
                        NSLog(@"FNJKDSAFNKDANFJKASNFJKADJFKAS:::%@",_arrForAllLikeUserId);
                        
                        for (int i = 0; i < _tableViewArr.count; i++) {
                            
                            DongTaiModel *model = _tableViewArr[i];
                            // 判断是否已经喜欢
                            if ([_arrForAllLikeUserId containsObject:model.uid]) {
                                model.isFocus = @"YES";
                            }else {
                                model.isFocus = @"NO";
                            }
                        }
                    }
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    // 表格刷新完毕,结束上下刷新视图
                    [self.tableView.mj_footer endRefreshing];
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

// 布局页面
- (void) layoutViews {
    
    // 初始化TableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, W, H - 64 - 49) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    
    // 隐藏tableview自带的分割线
    _tableView.separatorStyle = NO;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    
    // 继续配置_tableView;
    // 创建一个下拉刷新的头
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 调用下拉刷新方法
        [self downRefresh];
    }];
    // 设置_tableView的顶头
    self.tableView.mj_header = header;
    // 设置_tableView的底部
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 调用上拉刷新方法
        [self upRefresh];
    }];
    
}

// 下拉刷新方法
- (void)downRefresh {
    
    [_tableViewArr removeAllObjects];
    [_tableView reloadData];
    
    // 起始位置
    pageStart = 0;
    
    // 动画
    [self createLoadingForBtnClick];
    
    // 请求数据
    [self initData];
}

// 上拉下拉刷新动画
- (void) createLoadingForBtnClick {
    
    // 动画
    _HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 展示
    [_HUD show:YES];
}


// 上拉刷新方法
- (void)upRefresh {
    
    pageStart = _tableViewArr.count;
    
    // 请求数据
    [self initData];
}

#pragma mark ----UITableViewDelegate,UITableViewDataSource----
// 返回的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _tableViewArr.count;
}
// 绑定数据
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 数据模型
    DongTaiModel *model = _tableViewArr[indexPath.row];
    
    // 关注用户
    if ([model.activityType isEqualToString:@"1"]) {
        
        static NSString *CellIdentifier = @"Cell";
        // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
        WMNoticeFocusOnCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
        if (cell == nil) {
            cell = [[WMNoticeFocusOnCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        // 选中无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 头像
        [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        cell.nickNameLb.text = model.nickname;
        cell.noticeTipLb.text = @"关注了你";
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
        
        if ([model.isFocus isEqualToString:@"YES"]) {
            // 已关注
            cell.focusOnBtn.selected = YES;
            cell.focusOnBtn.layer.borderColor = [FUIColorFromRGB(0x999999) CGColor];
        }else {
            // 未关注
            cell.focusOnBtn.layer.borderColor = [[UIColor colorWithRed:251/255.0 green:193/255.0 blue:85/255.0 alpha:1.0] CGColor];
            cell.focusOnBtn.selected = NO;
        }
        
        // 动态
        cell.guanzhuBtnClick = ^{
            [self guanzhuBtnBy:indexPath];
        };
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:model];
        };
        
        return cell;
        
    }else if([model.activityType isEqualToString:@"2"] || [model.activityType isEqualToString:@"3"] || [model.activityType isEqualToString:@"5"]){
        
        // 喜欢帖子评论帖子分享帖子
        
        // 纯文本
        if ([model.noteType isEqualToString:@"0"]) {
            // 纯文字
            
            // 纯文本样式
            static NSString *CellIdentifier = @"Cell";
            // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
            WMNoticeTextCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
            if (cell == nil) {
                cell = [[WMNoticeTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            // 选中无效果
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
            cell.nickNameLb.text = model.nickname;
            // 时间label
            cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
            if ([model.activityType isEqualToString:@"2"]) {
                 cell.noticeTipLb.text = [NSString stringWithFormat:@"喜欢了你的帖子:%@",model.noteContent];
            }else if ([model.activityType isEqualToString:@"3"]) {
                cell.noticeTipLb.text = [NSString stringWithFormat:@"评论了你的帖子:%@",model.noteContent];
            }else {
                cell.noticeTipLb.text = [NSString stringWithFormat:@"分享了你的帖子:%@",model.noteContent];
            }
            
            // 头像点击block
            cell.iconImgViewClick = ^{
                [self iconImgViewBy:model];
            };
            
            return cell;
            
            
        }else {
            
            // 带图片
            static NSString *CellIdentifier = @"Cell";
            // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
            WMNoticePhotoCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
            if (cell == nil) {
                cell = [[WMNoticePhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            // 选中无效果
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
            cell.nickNameLb.text = model.nickname;
            // 时间label
            cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
            if ([model.activityType isEqualToString:@"2"]) {
                if ([model.noteType isEqualToString:@"1"]) {
                    // 图片
                    cell.noticeTipLb.text = [NSString stringWithFormat:@"喜欢了你的帖子:%@",model.noteContent];
                    [cell.peituImgView sd_setImageWithURL:[NSURL URLWithString:model.noteFile] placeholderImage:[UIImage imageNamed:@""]];
                    cell.playImgView.hidden = YES;
                }else {
                    // 视频
                    cell.noticeTipLb.text = [NSString stringWithFormat:@"喜欢了你的帖子:%@",model.noteContent];
                    [cell.peituImgView sd_setImageWithURL:[NSURL URLWithString:model.noteFile] placeholderImage:[UIImage imageNamed:@""]];
                    cell.playImgView.hidden = NO;
                }
                
            }else if ([model.activityType isEqualToString:@"3"]) {
                if ([model.noteType isEqualToString:@"1"]) {
                    // 图片
                    cell.noticeTipLb.text = [NSString stringWithFormat:@"评论了你的帖子:%@",model.noteContent];
                    [cell.peituImgView sd_setImageWithURL:[NSURL URLWithString:model.noteFile] placeholderImage:[UIImage imageNamed:@""]];
                    cell.playImgView.hidden = YES;
                }else {
                    // 视频
                    cell.noticeTipLb.text = [NSString stringWithFormat:@"评论了你的帖子:%@",model.noteContent];
                    [cell.peituImgView sd_setImageWithURL:[NSURL URLWithString:model.noteFile] placeholderImage:[UIImage imageNamed:@""]];
                    cell.playImgView.hidden = NO;
                }
            }else {
                if ([model.noteType isEqualToString:@"1"]) {
                    // 图片
                    cell.noticeTipLb.text = [NSString stringWithFormat:@"分享了你的帖子:%@",model.noteContent];
                    [cell.peituImgView sd_setImageWithURL:[NSURL URLWithString:model.noteFile] placeholderImage:[UIImage imageNamed:@""]];
                    cell.playImgView.hidden = YES;
                }else {
                    // 视频
                    cell.noticeTipLb.text = [NSString stringWithFormat:@"分享了你的帖子:%@",model.noteContent];
                    [cell.peituImgView sd_setImageWithURL:[NSURL URLWithString:model.noteFile] placeholderImage:[UIImage imageNamed:@""]];
                    cell.playImgView.hidden = NO;
                }
            }
            
            // 头像点击block
            cell.iconImgViewClick = ^{
                [self iconImgViewBy:model];
            };
            // 帖子
            cell.tieziViewClick = ^{
                [self tieziImgBy:model];
            };
            
            return cell;
        }
        
    }else {
        
        // 回复评论和系统通知
        
        // 纯文本样式
        static NSString *CellIdentifier = @"Cell";
        // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
        WMNoticeTextCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
        if (cell == nil) {
            cell = [[WMNoticeTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        // 选中无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        cell.nickNameLb.text = model.nickname;
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
        cell.noticeTipLb.text = [NSString stringWithFormat:@"回复了你的评论:%@",model.commentContent];
        
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:model];
        };
        
        return cell;
    }
}

// 帖子
-(void) tieziImgBy:(DongTaiModel *)model {
    // 获取delegate
    DetailImgViewController *vc = [[DetailImgViewController alloc] init];
    vc.strId = model.noteId;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

// 头像点击block触发事件
- (void) iconImgViewBy:(DongTaiModel *)model {
    // 跳转到他人主页
    OtherMineViewController *vc = [[OtherMineViewController alloc] init];
    [vc setHidesBottomBarWhenPushed:YES];
    vc.userId = model.uid;
    [self.navigationController pushViewController:vc animated:YES];
}
// 关注按钮的Block触发的事件
- (void) guanzhuBtnBy:(NSIndexPath *)indexPath {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    // 数据模型
    DongTaiModel *model = _tableViewArr[indexPath.row];
    
    NSDictionary *idDic = @{@"uid":model.uid};
    NSString *dataStr = [[MakeJson createJson:idDic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStr};
    
    
    WMNoticeFocusOnCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    cell.focusOnBtn.userInteractionEnabled = NO;
    if (cell.focusOnBtn.selected == NO) {
        // 进行关注数据请求
        [http PostAddFollowUserWithDic:dicData Success:^(id userInfo) {
            // 打开用户交互
            cell.focusOnBtn.userInteractionEnabled = YES;
            // 数据请求成功
            if ([userInfo isEqualToString:@"0"]) {
                NSLog(@"关注用户失败");
            }else {
                // 关注成功
                cell.focusOnBtn.selected = !cell.focusOnBtn.selected;
                [MBHUDView hudWithBody:@"关注用户成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                cell.focusOnBtn.layer.borderColor = [FUIColorFromRGB(0x999999) CGColor];
                model.isFocus = @"YES";
                [_tableView reloadData];
                
                // 做一个单例 用于修改发现页面的推荐用户
                if ([UserDefaults valueForKey:@"FollowUserOrBlacklistUser"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:model.uid];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserOrBlacklistUser"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserOrBlacklistUser"]];
                    [tempArr addObject:model.uid];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserOrBlacklistUser"];
                }
                
                
            }
        } failure:^(NSError *error) {
            // 数据请求失败
            // 打开用户交互
            cell.focusOnBtn.userInteractionEnabled = YES;
        }];
    }else {
        
        // 进行删除关注数据请求
        [http PostDelFollowUserWithDic:dicData Success:^(id userInfo) {
            // 打开用户交互
            cell.focusOnBtn.userInteractionEnabled = YES;
            // 数据请求成功
            if ([userInfo isEqualToString:@"0"]) {
                NSLog(@"关注用户失败");
            }else {
                // 取消关注成功
                cell.focusOnBtn.selected = !cell.focusOnBtn.selected;
                [MBHUDView hudWithBody:@"取消关注成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                cell.focusOnBtn.layer.borderColor = [[UIColor colorWithRed:251/255.0 green:193/255.0 blue:85/255.0 alpha:1.0] CGColor];
                model.isFocus = @"NO";
                [_tableView reloadData];
                
                // 做一个单例 用于修改发现页面的推荐用户
                if ([UserDefaults valueForKey:@"CancleFollowUser"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:model.uid];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUser"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"CancleFollowUser"]];
                    [tempArr addObject:model.uid];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUser"];
                }
            }
        } failure:^(NSError *error) {
            // 数据请求失败
            // 打开用户交互
            cell.focusOnBtn.userInteractionEnabled = YES;
        }];
    }

}


// 返回的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 95;
}

// tableView的点击事件
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 反选
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    DongTaiModel *model = _tableViewArr[indexPath.row];
    
    if([model.activityType isEqualToString:@"2"]) {
        
        // 喜欢了帖子
        // 获取delegate
        DetailImgViewController *vc = [[DetailImgViewController alloc] init];
        vc.strId = model.noteId;
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([model.activityType isEqualToString:@"4"]) {
        
        // 回复了评论
        // 评论了你的帖子
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        // 拿到用户id
        NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
        PingLunViewController *vc = [[PingLunViewController alloc] init];
        vc.noteId = model.noteId;
        vc.targetUid = [dicForUserInfo valueForKey:@"id"];
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([model.activityType isEqualToString:@"5"]) {
        // 分享了帖子
        // 获取delegate
        DetailImgViewController *vc = [[DetailImgViewController alloc] init];
        vc.strId = model.noteId;
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if(([model.activityType isEqualToString:@"3"])) {
        // 评论了你的帖子
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        // 拿到用户id
        NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
        PingLunViewController *vc = [[PingLunViewController alloc] init];
        vc.noteId = model.noteId;
        vc.targetUid = [dicForUserInfo valueForKey:@"id"];
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


// 页面将要消失
- (void) viewWillDisappear:(BOOL)animated {
    
    [UserDefaults removeObjectForKey:@"FollowUserForNews"];
    [UserDefaults removeObjectForKey:@"CancleFollowUserForNews"];
}


// 页面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    // 取出单例 用于判断关注状态是否需要更新
    // 其他喜欢帖子临时数组
    NSMutableArray *tempArr1 = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserForNews"]];
    NSMutableArray *FollowUserForNewsArr = [[NSMutableArray alloc]init];
    for (NSString *str in tempArr1) {
        if (![FollowUserForNewsArr containsObject:str]) {
            [FollowUserForNewsArr addObject:str];
        }
    }
    // 其他取消喜欢帖子临时数组
    NSMutableArray *tempArr2 = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"CancleFollowUserForNews"]];
    NSMutableArray *CancleFollowUserForNewsArr = [[NSMutableArray alloc]init];
    for (NSString *str in tempArr2) {
        if (![CancleFollowUserForNewsArr containsObject:str]) {
            [CancleFollowUserForNewsArr addObject:str];
        }
    }
    
    NSArray *tempArr = [NSArray arrayWithArray:FollowUserForNewsArr];
    for (NSString *str in tempArr) {
        
        if ([CancleFollowUserForNewsArr containsObject:str]) {
            [CancleFollowUserForNewsArr removeObject:str];
            [FollowUserForNewsArr removeObject:str];
        }
    }
    
    
    // 拿到实际操作了的喜欢不喜欢临时数组
    if (_tableViewArr.count > 0) {
        for (int i = 0; i < FollowUserForNewsArr.count; i++) {
            
            for (int j = 0; j < _tableViewArr.count; j++) {
                
                DongTaiModel *tempModel = _tableViewArr[j];
                
                if ([tempModel.uid isEqualToString:FollowUserForNewsArr[i]]) {
                    
                    DongTaiModel *model = _tableViewArr[j];
                    model.isFocus = @"YES";
                }
            }
            
            if (i == FollowUserForNewsArr.count - 1) {
                [self.tableView reloadData];
            }
        }
        
        for (int i = 0; i < CancleFollowUserForNewsArr.count; i++) {
            
            
            for (int j = 0; j < _tableViewArr.count; j++) {
                
                DongTaiModel *tempModel = _tableViewArr[j];
                
                if ([tempModel.uid isEqualToString:CancleFollowUserForNewsArr[i]]) {
                    
                    DongTaiModel *model = _tableViewArr[j];
                    model.isFocus = @"NO";
                }
            }
            
            if (i == CancleFollowUserForNewsArr.count - 1) {
                [self.tableView reloadData];
            }
        }
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
