//
//  DongTaiViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/17.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "DongTaiViewController.h"
#import "DongTaiCell.h" // 动态cell
#import "OtherMineViewController.h"

@interface DongTaiViewController () <UITableViewDelegate,UITableViewDataSource> {
    
    NSInteger pageStart; // 请求数据开始位置
    NSInteger pageSize; // 一页的数量
}

@property (nonatomic, copy) MBProgressHUD *HUD; // 动画


// tableView的数据
@property (nonatomic ,copy) NSMutableArray *tableViewArr;
// tableView
@property (nonatomic, copy)UITableView *tableView;

@end

@implementation DongTaiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置导航栏标题
    UILabel *lbItemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    lbItemTitle.text = @"动态";
    lbItemTitle.textColor = FUIColorFromRGB(0x212121);
    lbItemTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = lbItemTitle;
    
    // 初始化数组
    [self initArr];
    
    // 布局TableView
    [self createTbv];
    
    // 请求数据
    [self initData];
}

// 请求数据
- (void) initData {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 获取用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    
    NSDictionary *dic = @{@"noteId":_noteId,@"pageStart":[NSString stringWithFormat:@"%ld",pageStart],@"pageSize":[NSString stringWithFormat:@"%ld",pageSize]};
    NSString *strDataJiaMi = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
    // 用于请求的dic
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strDataJiaMi};
    
    // 第0页
    if (pageStart == 0) {
        
        
        [http PostGetUserActivityByNoteWithDic:dicData Success:^(id userInfo) {
            
            
            if ([userInfo isEqualToString:@"0"]) {
                
                // 没拿到数据,不操作
                
            }else {
                // 拿到数组
                NSDictionary *UserListDic = [MakeJson createDictionaryWithJsonString:userInfo];
                // 用于下次请求
                pageStart = [[UserListDic valueForKey:@"pageStart"] integerValue];
                NSArray *arr = [UserListDic valueForKey:@"dataList"];
                
                NSMutableArray *arrSearchUserInfoList = [DongTaiModel arrayOfModelsFromDictionaries:arr error:nil];
                
                // 清空数组
                [_tableViewArr removeAllObjects];
                
                NSInteger count = [arrSearchUserInfoList count] - 1;
                
                for (int i = 0; i < [arrSearchUserInfoList count]; i++) {
                    
                    [_tableViewArr addObject:arrSearchUserInfoList[count]];
                    
                    count -- ;
                }
                
                // 刷新列表
                [self.tableView reloadData];
                // 让tableView滚动到最后一行
                [self scrollToTableBottom];
            }
            
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            
            
        } failure:^(NSError *error) {
            
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
        }];
        
    }else {
        
        
        [http PostGetUserActivityByNoteWithDic:dicData Success:^(id userInfo) {
            
            if ([userInfo isEqualToString:@"0"]) {
                
                
                
            }else {
                
                // 拿到数组
                NSDictionary *UserListDic = [MakeJson createDictionaryWithJsonString:userInfo];
                // 用于下次请求
                pageStart = [[UserListDic valueForKey:@"pageStart"] integerValue];
                NSArray *arr = [UserListDic valueForKey:@"dataList"];
                NSMutableArray *arrSearchUserInfoList = [DongTaiModel arrayOfModelsFromDictionaries:arr error:nil];
                
                // 成功
                for (int i = 0; i < [arrSearchUserInfoList count]; i++) {
                    
                    [_tableViewArr insertObject:arrSearchUserInfoList[i] atIndex:0];
                }
                // 刷新列表
                [self.tableView reloadData];
                
                
                if ([arrSearchUserInfoList count] == 0) {
                    
                    // 没有拿到更多数据
                    
                }else {
                    
                    // 拿到了更多数据,滚动到拿到的数据那一行
                    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:[arrSearchUserInfoList count] inSection:0];
                    [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            }
            
            
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            
        } failure:^(NSError *error) {
            
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
        }];
        
    }
}

// 初始化数组
- (void) initArr {
    
    // 初始化
    pageStart = 0;
    pageSize = 10;
    
    // 列表数组
    _tableViewArr = [NSMutableArray array];
}

// 滚动到最后一行
- (void)scrollToTableBottom {
    
    NSInteger lastRow = self.tableViewArr.count - 1;
    
    if (lastRow < 0) return;
    
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// 布局tableView
- (void) createTbv {
    
    // 导航栏分隔线
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, W, 0.5)];
    [self.view addSubview:lb];
    lb.backgroundColor = FUIColorFromRGB(0xeeeeee);
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0.5, W, H - 64.5) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    
    // 继续配置_tableView;
    // 创建一个下拉刷新的头
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 调用下拉刷新方法
        [self downRefresh];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    // 设置_tableView的顶头
    self.tableView.mj_header = header;
    
    
    // 隐藏掉分隔线
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 隐藏多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_tableView registerClass:[DongTaiCell class] forCellReuseIdentifier:@"cell"];
}


// 下拉刷新方法
- (void)downRefresh {
    
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

#pragma mark --- UITableViewDelegate,UITableViewDataSource ---
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _tableViewArr.count;
}

// 绑定数据
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DongTaiModel *model = _tableViewArr[indexPath.row];
    
    DongTaiCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // 选中无效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
    cell.nickNameLb.text = model.nickname;
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 拿到用户id
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([model.uid isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        
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
    
//    ACTION_TYPE_ADD_NOTE = 0;// 发表帖子
//    ACTION_TYPE_FOLLOW_USER = 1;// 关注用户
//    ACTION_TYPE_LOVE_NOTE = 2;// 喜欢帖子
//    ACTION_TYPE_COMMENT = 3;// 评论帖子
//    ACTION_TYPE_COMMENT_REPLY = 4;// 回复评论
//    ACTION_TYPE_SHARE_NOTE = 5;// 分享了帖子
//    ACTION_TYPE_SYSTEM_NOTIFY = 6;// 系统通知
    
    switch ([model.activityType integerValue]) {
        case 2:
        {
            cell.noticeTipLb.text = @"喜欢了这篇帖子";
        }
            break;
        case 3: {
            cell.noticeTipLb.text = @"评论了这篇帖子";
        }
            break;
        case 5: {
            cell.noticeTipLb.text = @"分享了这篇帖子";
        }
            break;
            
        default:
            break;
    }
    
    // 时间label
    cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
    
    return cell;
}

// 头像点击block触发事件
- (void) iconImgViewBy:(DongTaiModel *)model {
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 拿到用户id
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([model.uid isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        
        // 是自己
        [TipIsYourSelf tipIsYourSelf];
        
    }else {
    
        // 跳转到他人主页
        OtherMineViewController *vc = [[OtherMineViewController alloc] init];
        [vc setHidesBottomBarWhenPushed:YES];
        vc.userId = model.uid;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

// 返回的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 71;
}

// tableview的点击
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 反选
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
