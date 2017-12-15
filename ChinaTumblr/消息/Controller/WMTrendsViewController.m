//
//  WMTrendsViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/1.
//  Copyright © 2017年 张宗琦. All rights reserved.
//  动态

#import "WMTrendsViewController.h"
#import "WMTrendsLikeCell.h" // 喜欢动态cell
#import "WMTrendsLikeUserTableViewCell.h" // 喜欢人cell
#import "TrendsModel.h" // 动态模型
#import "UIView+Gone.h"


@interface WMTrendsViewController ()<UITableViewDelegate,UITableViewDataSource> {
    
    NSInteger pageStart; // 请求数据开始位置
    NSInteger pageSize; // 一页的数量
}

@property (nonatomic ,copy) UITableView *tableView; // 列表

@property (nonatomic, strong) NSMutableArray *tableViewArr; // tableView数据数组

// 动画
@property (nonatomic, copy) MBProgressHUD *HUD;

@end

@implementation WMTrendsViewController

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
    pageSize = 20;
    
    // tableViewArr
    _tableViewArr = [NSMutableArray array];
    
}


// 请求数据
- (void) initData {
    
    // 数据请求
    HttpRequest *http = [[HttpRequest alloc] init];
    // 用户加密相关
    NSArray * userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    // 分页Dic
    NSDictionary *dic = @{@"pageStart":[NSString stringWithFormat:@"%ld",pageStart],@"pageSize":[NSString stringWithFormat:@"%ld",pageSize]};
    NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
    // 最终请求数据需要的data
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
    
    NSLog(@"+++++++++%@",dicData);
    
    NSLog(@"pageStart:::::::%ld",pageStart);
    
    
    // 第0页
    if (pageStart == 0) {
        
        [http PostGetFollowUserActivityWithDic:dicData Success:^(id userInfo) {
            
            
            NSLog(@"nsdajkfnkasdnfkjadsfnkjas::::::%@",_tableViewArr);
            
            // 得到下次请求时的pageStart
//            for (int i = 0; i < _tableViewArr.count; i++) {
//                
//                TrendsModel *model = _tableViewArr[i];
//                
//                pageStart = pageStart + [model.actionTargetList count];
//            }
            
            
            if ([userInfo isEqualToString:@"0"]) {
                
                // 后台没给数据,不处理
                // 隐藏动画
                [_HUD hide:YES];
                
                // 先清空再更换数据
                [_tableViewArr removeAllObjects];
                [_tableView reloadData];
                
                // 表格刷新完毕,结束上下刷新视图
                [self.tableView.mj_footer endRefreshing];
                [self.tableView.mj_header endRefreshing];
                
            }else {
                
                // 拿到后台给的字典
                NSDictionary *UserListDic = [MakeJson createDictionaryWithJsonString:userInfo];
                
                // 后台给的下次请求时需要的pageStart
                pageStart = [[UserListDic valueForKey:@"pageStart"] integerValue];
                // 拿到的数据数组
                NSArray *arr = [UserListDic valueForKey:@"dataList"];
                // 转换成model数组
                NSMutableArray *arrSearchUserInfoList = [TrendsModel arrayOfModelsFromDictionaries:arr error:nil];
                // 先清空再更换数据
                [_tableViewArr removeAllObjects];
                // 更换数据
                [_tableViewArr addObjectsFromArray:arrSearchUserInfoList];
                
                
                // 隐藏动画
                [_HUD hide:YES];
                // 表格刷新完毕,结束上下刷新视图
                [self.tableView.mj_footer resetNoMoreData];
                [self.tableView.mj_header endRefreshing];
                // 刷新列表
                [self.tableView reloadData];
            }
            
            NSLog(@"::::::::::::::%ld",pageStart);
            
            
            
            
        } failure:^(NSError *error) {
            
            NSLog(@"请求失败");
            [_tableViewArr removeAllObjects];
            // 隐藏动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            // 刷新列表
            [self.tableView reloadData];
            
        }];
        
    }else {
        
        [http PostGetFollowUserActivityWithDic:dicData Success:^(id userInfo) {
            
            if ([userInfo isEqualToString:@"0"]) {

                // 后台未返回数据,不作处理
                // 隐藏动画
                [_HUD hide:YES];
                // 表格刷新完毕,结束上下刷新视图
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                [self.tableView.mj_header endRefreshing];
                
            }else {
                
                // 拿到后台给的字典
                NSDictionary *UserListDic = [MakeJson createDictionaryWithJsonString:userInfo];
                
                // 后台给的下次请求时需要的pageStart
                pageStart = [[UserListDic valueForKey:@"pageStart"] integerValue];
                // 拿到的数据数组
                NSArray *arr = [UserListDic valueForKey:@"dataList"];
                // 转换成model数组
                NSMutableArray *arrSearchUserInfoList = [TrendsModel arrayOfModelsFromDictionaries:arr error:nil];
                // 更换数据
                [_tableViewArr addObjectsFromArray:arrSearchUserInfoList];
                
                // 隐藏动画
                [_HUD hide:YES];
                // 表格刷新完毕,结束上下刷新视图
                [self.tableView.mj_footer endRefreshing];
                [self.tableView.mj_header endRefreshing];
                // 刷新列表
                [self.tableView reloadData];
            }
            
        } failure:^(NSError *error) {
            
            NSLog(@"请求失败");
            // 隐藏动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            // 刷新列表
            [self.tableView reloadData];
            
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
    [self.tableView registerClass:[WMTrendsLikeCell class] forCellReuseIdentifier:@"Cell111"];
    [self.tableView registerClass:[WMTrendsLikeUserTableViewCell class] forCellReuseIdentifier:@"Cell222"];
    
    
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
    
    [_tableViewArr removeAllObjects];
    [self.tableView reloadData];
    
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
    
    TrendsModel *model = _tableViewArr[indexPath.row];
    
    if ([model.activityType isEqualToString:@"0"] || [model.activityType isEqualToString:@"2"] || [model.activityType isEqualToString:@"5"]) {
        
        // 发表、喜欢、分享帖子
        
        // 使用同一种Cell
        static NSString *CellIdentifier = @"Cell111";
        WMTrendsLikeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath]; //改为以下的方法
//        WMTrendsLikeCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
//        if (cell == nil) {
//            cell = [[WMTrendsLikeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
        
        // 选中无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        // 头像
        [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        // 昵称
        cell.nickNameLb.text = model.nickname;
        
        // 动态
        if ([model.activityType isEqualToString:@"0"]) {
            
            cell.noticeTipLb.text = [NSString stringWithFormat:@"发表了 %ld 篇",[model.actionTargetList count]];
            
        }else if ([model.activityType isEqualToString:@"2"]) {
            cell.noticeTipLb.text = [NSString stringWithFormat:@"喜欢了 %ld 篇",[model.actionTargetList count]];
        }else {
            cell.noticeTipLb.text = [NSString stringWithFormat:@"分享了 %ld 篇",[model.actionTargetList count]];
        }
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
        
        NSLog(@"%ld",cell.backView.subviews.count);
        
        // 判断当前需要的视图是否大于当前有的视图
        if (model.actionTargetList.count > (cell.backView.subviews.count - 4)) {
            
            for (int i = 4; i < cell.backView.subviews.count; i++) {
                
                // 打开
                cell.backView.subviews[i].hidden = NO;
            }
            
            NSLog(@"%ld",model.actionTargetList.count);
            
            // 创建视图
            [cell createNewViewWithStartNum:(int)cell.backView.subviews.count - 4 andAllNum:(int)model.actionTargetList.count];
        }else {
            
            for (int i = 0; i < (cell.backView.subviews.count-4) - model.actionTargetList.count; i++) {
                
                // 隐藏掉
                cell.backView.subviews[cell.backView.subviews.count-1-i].hidden = YES;
            }
            for (int i = 0; i < model.actionTargetList.count; i++) {
                // 打开
                cell.backView.subviews[i + 4].hidden = NO;
            }
        }
        
        // 给视图赋值
        [cell giveArrForAlreadyHaveView:model.actionTargetList];
        
        
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:model];
        };
        
        
        return cell;
        
        
    }else {
        
        // 关注用户
        
        // 使用同一种Cell
        static NSString *CellIdentifier = @"Cell222";
        WMTrendsLikeUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath]; //改为以下的方法
//        WMTrendsLikeUserTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
//        if (cell == nil) {
//            cell = [[WMTrendsLikeUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
        
        // 选中无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 头像
        [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        // 昵称
        cell.nickNameLb.text = model.nickname;
        // 喜欢的人数
        cell.noticeTipLb.text = [NSString stringWithFormat:@"关注了 %ld 人",[model.actionTargetList count]];
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
        
        // 创建视图
//        [cell giveArrForLike:model.actionTargetList];
        
        // 判断当前需要的视图是否大于当前有的视图
        if (model.actionTargetList.count > (cell.backView.subviews.count - 4)) {
            
            for (int i = 4; i < cell.backView.subviews.count; i++) {
                
                // 打开
                cell.backView.subviews[i].hidden = NO;
            }

            
            // 创建视图
            [cell createNewViewWithStartNum:(int)cell.backView.subviews.count - 4 andAllNum:(int)model.actionTargetList.count];
        }else {
            
            for (int i = 0; i < (cell.backView.subviews.count-4) - model.actionTargetList.count; i++) {
                
                // 隐藏掉
                cell.backView.subviews[cell.backView.subviews.count-1-i].hidden = YES;
            }
            for (int i = 0; i < model.actionTargetList.count; i++) {
                // 打开
                cell.backView.subviews[i + 4].hidden = NO;
            }
        }
        
        // 给视图赋值
        [cell giveArrForAlreadyHaveView:model.actionTargetList];
        
        
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:model];
        };
        
        return cell;
        
    }
}


// 头像点击block触发事件
- (void) iconImgViewBy:(TrendsModel *)model {
    
    // 跳转到他人主页
    OtherMineViewController *vc = [[OtherMineViewController alloc] init];
    [vc setHidesBottomBarWhenPushed:YES];
    vc.userId = model.uid;
    [self.navigationController pushViewController:vc animated:YES];
}

// tableView的点击事件
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 反选
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 数据模型
    TrendsModel *model = _tableViewArr[indexPath.row];
    
    if ([model.activityType isEqualToString:@"0"] || [model.activityType isEqualToString:@"2"] || [model.activityType isEqualToString:@"5"]) {
        
        NSInteger count = (model.actionTargetList.count-1) / 4;
        
        return 44 + 6*(count+1) + (W-78-0.0234375*W)/4*(count+1) + 12;
        
    }else {
        
        NSInteger count = (model.actionTargetList.count-1) / 5;
        
        return 44 + 6*(count+1) + (W-80-0.0234375*W)/5*(count+1) + 12;
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
