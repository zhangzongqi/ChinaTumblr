//
//  SystemNoticeViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/10/26.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "WMSystemNoticeViewController.h"
#import "WMSystemNoticeCell.h" // cell
#import "DeatalSystemNoticeViewController.h" // 详情页

#import "JPUSHService.h" 
#import "UITabBarItem+WZLBadge.h"

@interface WMSystemNoticeViewController ()<UITableViewDelegate,UITableViewDataSource> {
    
    NSInteger pageStart;
    NSInteger pageSize;
    NSMutableArray *_tableViewArr;
}

@property (nonatomic, copy) UITableView *tableView; // 专题列表
@property (nonatomic, copy) MBProgressHUD *HUD; // 动画

@end

@implementation WMSystemNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    GetSpecialEventListWithpageStart
    
    // 背景色
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 初始化数组
    [self initArr];
    
    // 布局页面
    [self layoutViews];
    
    // 获取数据
    [self initData];
}

// 初始化数组
- (void) initArr {
    
    pageStart = 0;
    pageSize = 0;
    
    // 初始化数组
    _tableViewArr = [NSMutableArray array];
}


// 获取数据
- (void) initData {
    
    // 创建数据请求对象
    HttpRequest *http = [[HttpRequest alloc] init];
    
    if (pageStart == 0) {
        
        // 设置图标上的推送消息个数
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        [JPUSHService resetBadge];
        [self.tabBarController.tabBar.items[3] clearBadge];
        
        // 下拉刷新
        [http GetSpecialEventListWithpageStart:[NSString stringWithFormat:@"%ld",pageStart]  andpageSize:[NSString stringWithFormat:@"%ld",pageSize] Success:^(id arrForDetail) {
            
            // 结束动画
            [_HUD hide:YES];
            // 结束下拉刷新
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer resetNoMoreData];
            
            if ([arrForDetail isKindOfClass:[NSString class]]) {
                
                NSLog(@"没有拿到数据");
                [_tableViewArr removeAllObjects];
                [_tableView reloadData];
                
            }else {
                
                // 清空数据
                [_tableViewArr removeAllObjects];
                // 换成新的数据
                _tableViewArr = arrForDetail;
                [_tableView reloadData];
            }
            
        } failure:^(NSError *error) {
            
            // 结束动画
            [_HUD hide:YES];
            // 结束下拉刷新
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer resetNoMoreData];
            
            // 请求失败
            NSLog(@"网络有问题或接口无法访问");
        }];
        
    }else {
        
        // 创建数据请求对象
        HttpRequest *http = [[HttpRequest alloc] init];
        
        [http GetSpecialEventListWithpageStart:[NSString stringWithFormat:@"%ld",pageStart]  andpageSize:[NSString stringWithFormat:@"%ld",pageSize] Success:^(id arrForDetail) {
            
            if ([arrForDetail isKindOfClass:[NSString class]]) {
                
                NSLog(@"没有拿到数据");
                // 结束动画
                [_HUD hide:YES];
                // 结束下拉刷新
                [self.tableView.mj_header endRefreshing];
                // 没有更多数据
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                
            }else {
                
                // 结束动画
                [_HUD hide:YES];
                // 结束上下拉刷新
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                
                // 往里面添加数据
                [_tableViewArr addObjectsFromArray:arrForDetail];
                [_tableView reloadData];
            }
            
        } failure:^(NSError *error) {
            
            // 结束动画
            [_HUD hide:YES];
            // 结束上下拉刷新
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
            // 请求失败
            NSLog(@"网络有问题或接口无法访问");
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
    
    // 自适应和隐藏分隔线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    self.tableView.estimatedRowHeight = 200.0f;
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // 绑定cell
    [self.tableView registerClass:[WMSystemNoticeCell class] forCellReuseIdentifier:@"Cell111"];
    
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
    
    // 起始位置
    pageStart = 0;
    
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
}


// 上拉刷新方法
- (void)upRefresh {
    
    // 起始位置
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
    
    ZhuanTiModel *model = _tableViewArr[indexPath.row];
    
    // 使用同一种Cell
    static NSString *CellIdentifier = @"Cell111";
    WMSystemNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath]; //改为以下的方法
    
    // 专题图片
    [cell.backImgView sd_setImageWithURL:[NSURL URLWithString:model.img]];;
    
    // 专题标题
    cell.lbTitle.text = model.title;
    
    return cell;
        
}

// 每行高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return H * 0.25;
}

// 点击事件
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZhuanTiModel *model = _tableViewArr[indexPath.row];
    
    DeatalSystemNoticeViewController *vc = [[DeatalSystemNoticeViewController alloc] init];
    vc.idStr = model.id1;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
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
