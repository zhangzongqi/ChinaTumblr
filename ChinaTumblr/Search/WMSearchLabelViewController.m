//
//  WMSearchViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/14.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "WMSearchLabelViewController.h"
#import "SearchLabelCell.h" // cell
#import "SearchViewController.h"
#import "SearchLabelDeatilViewController.h" // 搜索详情页
#import "SearchBiaoQianModel.h" // 标签模型

#import "SearchDBManage.h" // 数据库

// 最大存储的搜索历史 条数
#define MAX_COUNT 4


@interface WMSearchLabelViewController ()<UITableViewDelegate,UITableViewDataSource> {
    
    NSMutableArray *_dataArr; // 数据数组
    
    NSMutableArray *_dataArrForTuiJian;
}

@end

@implementation WMSearchLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 背景色
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 分隔线
    UILabel *lbFenge = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, W, 1)];
    [self.view addSubview:lbFenge];
    lbFenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
    
    // 初始化数组
    [self initArr];
    
    // 创建tableView
    [self createTableView];
    
    // 获取数据
    [self initData];
    
}

// 初始化数组
- (void) initArr {
    
    _dataArr = [NSMutableArray array];
    
    _dataArrForTuiJian = [NSMutableArray array];
    
}

// 获取数据
- (void) initData {
    
    // 网络请求
    HttpRequest *http = [[HttpRequest alloc] init];
    
    // 获取检索相关关键词结果请求
    [http GetKeyWordListLikeWithKeyword:_str andPageStart:@"0" andPageSize:@"8" Success:^(id userListInfo) {
        
        // 更换数据
        _dataArr = userListInfo;
        
        // 刷新列表
        [_tableView reloadData];
        
    } failure:^(NSError *error) {
        
        // 请求失败
    }];
    
    
    
    NSArray *arrForUserJiaMi = [GetUserJiaMi getUserTokenAndCgAndKey];
    NSDictionary *dic = @{@"pageStart":@"0",@"pageSize":@"6"};
    NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:arrForUserJiaMi[3]];
    NSDictionary *dicData = @{@"tk":arrForUserJiaMi[0],@"key":arrForUserJiaMi[1],@"cg":arrForUserJiaMi[2],@"data":strData};
    // 发起请求
    [http PostgetKeywordListRecommendForSearchWithDic:dicData Success:^(id userInfo) {
        
        if ([userInfo isKindOfClass:[NSString class]]) {
            [_dataArrForTuiJian removeAllObjects];
        }else {
            [_dataArrForTuiJian removeAllObjects];
            _dataArrForTuiJian = [userInfo valueForKey:@"keywordList"];
        }
        
        // 刷新列表
        [_tableView reloadData];
        
    } failure:^(NSError *error) {
        
        
    }];
    
}

// 创建tableView
- (void) createTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, W, H - 64 - 1 - 32)];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[SearchLabelCell class] forCellReuseIdentifier:@"cell"];
    // 隐藏多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}



#pragma mark ---UITableViewDelegate,UITableViewDataSource---
// 返回的分区数
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

// 每个分区返回的行数
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return _dataArr.count;
        
    }else {
        
        return _dataArrForTuiJian.count;
    }
}

// 数据绑定
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        //数据模型
        SearchBiaoQianModel *model = _dataArr[indexPath.row];
        
        SearchLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        cell.titleLb.text = model.title;
        cell.NumLb.text = [NSString stringWithFormat:@"%@篇帖子",model.note_num];
        
        return cell;
        
    }else {
        
        SearchLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        cell.titleLb.text = [_dataArrForTuiJian[indexPath.row] valueForKey:@"title"];
        cell.NumLb.text = [NSString stringWithFormat:@"%@篇帖子",[_dataArrForTuiJian[indexPath.row] valueForKey:@"note_num"]];
        
        return cell;
    }
    
}

// 行高
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 反选
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        SearchBiaoQianModel *model = _dataArr[indexPath.row];
        
        // 点击搜索时, 历史记录插入数据库
        // 插入数据库
        [self insterDBData:model.title];
        
        // 跳转到详情页
        SearchLabelDeatilViewController *vc = [[SearchLabelDeatilViewController alloc] init];
        vc.strDeatil = model.title;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        
        // 插入数据库
        [self insterDBData:[_dataArrForTuiJian[indexPath.row] valueForKey:@"title"]];
        
        // 跳转到详情页
        SearchLabelDeatilViewController *vc = [[SearchLabelDeatilViewController alloc] init];
        vc.strDeatil = [_dataArrForTuiJian[indexPath.row] valueForKey:@"title"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    
}

// 插入数据库
- (BOOL)insterDBData:(NSString *)keyword{
    if (keyword.length == 0) {
        return NO;
    }
    else{//搜索历史插入数据库
        //先删除数据库中相同的数据
        [self removeSameData:keyword];
        //再插入数据库
        [self moreThan20Data:keyword];
        
        return YES;
    }
}

/**
 *  去除数据库中已有的相同的关键词
 *
 *  @param keyword 关键词
 */
- (void)removeSameData:(NSString *)keyword{
    NSMutableArray *array = [[SearchDBManage shareSearchDBManage] selectAllSearchModel];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SearchModel *model = (SearchModel *)obj;
        if ([model.keyWord isEqualToString:keyword]) {
            [[SearchDBManage shareSearchDBManage] deleteSearchModelByKeyword:keyword];
        }
    }];
}

/**
 *  多余20条数据就把第0条去除
 *
 *  @param keyword 插入数据库的模型需要的关键字
 */
- (void)moreThan20Data:(NSString *)keyword{
    // 读取数据库里面的数据
    NSMutableArray *array = [[SearchDBManage shareSearchDBManage] selectAllSearchModel];
    
    if (array.count > MAX_COUNT - 1) {
        NSMutableArray *temp = [self moveArrayToLeft:array keyword:keyword]; // 数组左移
        [[SearchDBManage shareSearchDBManage] deleteAllSearchModel]; //清空数据库
        [temp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SearchModel *model = (SearchModel *)obj; // 取出 数组里面的搜索模型
            [[SearchDBManage shareSearchDBManage] insterSearchModel:model]; // 插入数据库
        }];
    }
    else if (array.count <= MAX_COUNT - 1){ // 小于等于19 就把第20条插入数据库
        [[SearchDBManage shareSearchDBManage] insterSearchModel:[SearchModel creatSearchModel:keyword currentTime:[self getCurrentTime]]];
    }
}

/**
 *  数组左移
 *
 *  @param array   需要左移的数组
 *  @param keyword 搜索关键字
 *
 *  @return 返回新的数组
 */
- (NSMutableArray *)moveArrayToLeft:(NSMutableArray *)array keyword:(NSString *)keyword{
    [array addObject:[SearchModel creatSearchModel:keyword currentTime:[self getCurrentTime]]];
    [array removeObjectAtIndex:0];
    return array;
}

/**
 *  获取当前时间
 *
 *  @return 当前时间
 */
- (NSString *)getCurrentTime{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY年MM月dd日HH:mm:ss"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

// 自定义分区表头和表尾
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, 0)];
    uv.backgroundColor = [UIColor whiteColor];
    
        
    if (section == 1) {
        
        // 文字
        UILabel *lbCls = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 120, 35)];
        lbCls.textColor = [UIColor colorWithRed:249/255.0 green:170/255.0 blue:49/255.0 alpha:1.0];
        lbCls.text = @"推荐";
        lbCls.font = [UIFont systemFontOfSize:15];
        [uv addSubview:lbCls];
        
        // 分割线
        UILabel *lbFenge = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, W - 20, 1)];
        lbFenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
        [uv addSubview:lbFenge];
    }
    
    return uv;
}

// 表头高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0;
    }else {
        return 35;
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
