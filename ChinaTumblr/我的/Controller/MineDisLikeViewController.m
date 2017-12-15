//
//  MineDisLikeViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/25.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "MineDisLikeViewController.h"
#import "SearchUserCell.h"
#import "OtherMineViewController.h" 

@interface MineDisLikeViewController ()<UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *_tbvDataArr; // tableView的数据
    
    NSInteger pageStart; // 开始值
    NSInteger pageSize; // 分页大小
}

@property (nonatomic, copy) UITableView *tableView;

@property (nonatomic, copy) MBProgressHUD *HUD;



@end

@implementation MineDisLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 背景色
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 设置导航栏标题
    UILabel *lbItemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    lbItemTitle.text = @"讨厌的人";
    lbItemTitle.textColor = FUIColorFromRGB(0x212121);
    lbItemTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = lbItemTitle;
    
    // 动画
    [self createLoadingForBtnClick];
    
    // 初始化数据
    [self initDataSource];
    
    // 创建TableView
    [self createTableView];
    
    // 请求数据
    [self initData];
}

// 初始化数据
- (void) initDataSource {
    
    pageStart = 0;
    pageSize = 10;
    
    _tbvDataArr = [NSMutableArray array];
}

// 请求数据
- (void) initData {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    NSDictionary *idDic = @{@"uid":@"",@"pageStart":[NSString stringWithFormat:@"%ld",pageStart],@"pageSize":[NSString stringWithFormat:@"%ld",pageSize]};
    NSString *dataStr = [[MakeJson createJson:idDic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStr};
    
    
    if (pageStart == 0) {
        // 下拉刷新
        // 获取粉丝
        [http PostGetDislikeUserInfoListWithDic:dicData Success:^(id userInfo) {
            
            if ([userInfo isEqualToString:@"0"]) {
                
                // 结束下拉刷新
                [self.tableView.mj_header endRefreshing];
                // 恢复上拉刷新
                [self.tableView.mj_footer resetNoMoreData];
                
            }else {
                
                [_tbvDataArr removeAllObjects];
                [_tbvDataArr addObjectsFromArray:[MakeJson createArrWithJsonString:userInfo]];
                // 刷新数据
                [self.tableView reloadData];
                // 结束下拉刷新
                [self.tableView.mj_header endRefreshing];
                // 恢复上拉刷新
                [self.tableView.mj_footer resetNoMoreData];
            }
            
            [_HUD hide:YES];
            
        } failure:^(NSError *error) {
            
            // 结束下拉刷新
            [self.tableView.mj_header endRefreshing];
            // 恢复上拉刷新
            [self.tableView.mj_footer resetNoMoreData];
            [_HUD hide:YES];
        }];
        
    }else {
        
        // 上拉加载
        [http PostGetDislikeUserInfoListWithDic:dicData Success:^(id userInfo) {
            
            if ([userInfo isEqualToString:@"0"]) {
                
                // 已全部加载
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                
            }else {
                
                // 改变数据源
                [_tbvDataArr addObjectsFromArray:[MakeJson createArrWithJsonString:userInfo]];
                
                // 表格刷新完毕,结束上下刷新视图
                [self.tableView.mj_footer endRefreshing];
                [self.tableView.mj_header endRefreshing];
                
                // 刷新数据
                [self.tableView reloadData];
            }
            
            [_HUD hide:YES];
            
        } failure:^(NSError *error) {
            
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
        }];
    }
}

// 创建TableView
- (void) createTableView {
    
    // tableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, W, H - 64)];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[SearchUserCell class] forCellReuseIdentifier:@"cell"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 隐藏多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // 创建一个下拉刷新的头
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 调用下拉刷新方法
        [self downRefresh];
    }];
    // 设置_tableView的顶头
    self.tableView.mj_header = header;
    
    // 设置_tableView的底部
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
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
    
    // 动画
    _HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 展示
    [_HUD show:YES];
}


// 上拉刷新方法
- (void)upRefresh {
    
    
    pageStart = _tbvDataArr.count;
    // 请求数据
    [self initData];
}


#pragma mark ---UITableViewDelegate,UITableViewDataSource---
// 返回的分区数
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

// 每个分区返回的行数
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _tbvDataArr.count;
}

// 数据绑定
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.nickName.text = [_tbvDataArr[indexPath.row] valueForKey:@"nickname"];
    
    if ([[_tbvDataArr[indexPath.row] valueForKey:@"img"] isKindOfClass:[NSString class]]) {
        cell.iconImgView.image = [UIImage imageNamed:@"账户管理_默认头像"];
    }else {
        [cell.iconImgView sd_setImageWithURL:[[_tbvDataArr[indexPath.row] valueForKey:@"img"] valueForKey:@"icon"] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
    }
    
    cell.signLb.text = [_tbvDataArr[indexPath.row] valueForKey:@"sign"];
    cell.followNumLb.text = [NSString stringWithFormat:@"%@ 人关注",[_tbvDataArr[indexPath.row] valueForKey:@"followNum"]];
    
    return cell;
}

// 行高
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 72;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 反选
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OtherMineViewController *vc = [[OtherMineViewController alloc] init];
    vc.userId = [_tbvDataArr[indexPath.row] valueForKey:@"id"];
    [self.navigationController pushViewController:vc animated:YES];
}

//
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"移除";
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    HttpRequest *http = [[HttpRequest alloc] init];
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    NSDictionary *dic = @{@"uid":[_tbvDataArr[indexPath.row] valueForKey:@"id"]};
    NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // 动画
        [self createLoadingForBtnClick];
        
        [http PostDelDislikeUserWithDic:dicData Success:^(id userInfo) {
            if ([userInfo isEqualToString:@"0"]) {
                [_HUD hide:YES];
                // 失败
            }else {
                
                // 做一个单例 用于修改发现页面的推荐用户
                if ([UserDefaults valueForKey:@"RemoveDisLikeUser"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:[_tbvDataArr[indexPath.row] valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"RemoveDisLikeUser"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"RemoveDisLikeUser"]];
                    [tempArr addObject:[_tbvDataArr[indexPath.row] valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"RemoveDisLikeUser"];
                }
                
                [_HUD hide:YES];
                [_tbvDataArr removeObjectAtIndex:indexPath.row];
                [self.tableView reloadData];
            }
        } failure:^(NSError *error) {
            [_HUD hide:YES];
        }];
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
