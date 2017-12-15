//
//  SheZhiViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/15.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "SheZhiViewController.h"
#import "GetAndClearCacheSize.h" // 获取和清空缓存
#import "SheZhiCell.h" // 设置cell
#import "AccountManagerViewController.h" // 账户管理
#import "KeJianViewController.h" // 可见页面
#import "AboutUsViewController.h" // 关于我们
#import "MineInterestViewController.h" // 我的兴趣
#import "FeedbackViewController.h" // 意见反馈
#import "MineFansViewController.h" // 粉丝
#import "MineDisLikeViewController.h" // 讨厌的人


@interface SheZhiViewController ()<UITableViewDelegate,UITableViewDataSource> {
    
    NSArray *_titleArr;
}

// tableView
@property (nonatomic, copy)UITableView *tableView;

@end

@implementation SheZhiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置导航栏标题
    UILabel *lbItemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    lbItemTitle.text = @"设置";
    lbItemTitle.textColor = FUIColorFromRGB(0x212121);
    lbItemTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = lbItemTitle;
    
    // 初始化数组
    [self initArr];
    
    // 布局Tbv
    [self createTbv];
}

// 初始化数组
- (void) initArr {
    
    _titleArr = @[@"账户管理",@"可见页面",@"我的兴趣",@"我的粉丝",@"讨厌的人",@"清空缓存",@"意见反馈",@"关于我们"];
}

// 布局Tbv
- (void) createTbv {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, W, H - 64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;

    // 隐藏多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_tableView registerClass:[SheZhiCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark ---UITableViewDelegate,UITableViewDataSource---
// 返回的行数
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 8;
}

// 绑定数据
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SheZhiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.titleLb.text = _titleArr[indexPath.row];
    
    if (indexPath.row == 5) {
        
        // 获取缓存类库
        GetAndClearCacheSize *CacheSize = [[GetAndClearCacheSize alloc] init];
        
        cell.huancunLb.text = [NSString stringWithFormat:@"%.2fM",[CacheSize readCacheSize]];
    }
    
    // 又箭头
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    return cell;
}



// tableView点击事件
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            // 账户管理
            AccountManagerViewController *vc = [[AccountManagerViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            // 可见页面
            KeJianViewController *vc = [[KeJianViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            // 我的兴趣
            MineInterestViewController *vc = [[MineInterestViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            MineFansViewController *vc = [[MineFansViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            MineDisLikeViewController *vc = [[MineDisLikeViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 6:
        {
            // 意见反馈
            FeedbackViewController * vc = [[FeedbackViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 7:
        {
            // 关于我们
            AboutUsViewController * vc = [[AboutUsViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
    
    
    if (indexPath.row == 5) {
        // 清除缓存
        
        GetAndClearCacheSize *clearCache = [[GetAndClearCacheSize alloc] init];
        // 清除缓存
        [clearCache clearFile];
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
        // 清除缓存成功
        [MBHUDView hudWithBody:@"清除缓存成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
    }
}

// 每行高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 0.128125 * W;
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
