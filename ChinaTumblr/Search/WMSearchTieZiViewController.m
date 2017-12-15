//
//  WMSearchTieZiViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/14.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "WMSearchTieZiViewController.h"
#import "SearchTextTieZiCell.h" // cell
#import "SearchImgVedioTieZiCell.h" // 图片视频cell
#import "SearchTieZiModel.h" // 模型

#import "SearchDBManage.h" // 数据库

#import "DetailImgViewController.h" // 帖子详情

// 最大存储的搜索历史 条数
#define MAX_COUNT 4

@interface WMSearchTieZiViewController ()<UITableViewDelegate, UITableViewDataSource> {
    
    NSArray *_tbvDataArr; // tableView的数据
}


@property (nonatomic, copy) UITableView *tableView;

@end

@implementation WMSearchTieZiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 背景色
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 分隔线
    UILabel *lbFenge = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, W, 1)];
    [self.view addSubview:lbFenge];
    lbFenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
    
    // 初始化数据
    [self initDataSource];
    
    // 创建TableView
    [self createTableView];
    
    // 请求数据
    [self initData];
}

// 初始化数据
- (void) initDataSource {
    
    // tableView的数据
    _tbvDataArr = [NSArray array];
}

// 创建TableView
- (void) createTableView {
    
    // tableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, W, H - 64 - 1 - 32)];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 隐藏多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.estimatedRowHeight = 379.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

// 获取数据
- (void) initData {
    
    
    // 获取用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    // 数据请求
    HttpRequest *http = [[HttpRequest alloc] init];
    
    
    // 需要的参数
    NSDictionary *dataDic = @{@"keyword":_str,@"orderBy":@"0",@"pageStart":@"0",@"pageSize":@"10"};
    NSString *strData = [[MakeJson createJson:dataDic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicDataJiaMi = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
    
    
    // (获取搜索帖子列表)
    [http PostGetNoteListLikeWithdicData:dicDataJiaMi Success:^(id userInfo) {
        
        _tbvDataArr = userInfo;
        
        [_tableView reloadData];
        
    } failure:^(NSError *error) {
        
        NSLog(@"失败");
    }];
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
    
        
    SearchTieZiModel *model = _tbvDataArr[indexPath.row];
    
    if ([model.type isEqualToString:@"0"]) {
        
        // 纯文字cell
        
        static NSString *CellIdentifier = @"Cell";
        // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
        SearchTextTieZiCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
        if (cell == nil) {
            cell = [[SearchTextTieZiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.tieziLb.text = model.content;
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
        return cell;
        
    }else {
        
        // 图片或者视频cell
        static NSString *CellIdentifier = @"Cell";
        // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
        SearchImgVedioTieZiCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
        if (cell == nil) {
            cell = [[SearchImgVedioTieZiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.tieziLb.text = model.content;
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
        
        if ([model.type isEqualToString:@"1"]) {
            [cell.showImgView sd_setImageWithURL:[NSURL URLWithString:model.files] placeholderImage:[UIImage imageNamed:@""]];
            // 图片
            cell.playImgView.hidden = YES;
        }else {
            [cell.showImgView sd_setImageWithURL:[NSURL URLWithString:model.files] placeholderImage:[UIImage imageNamed:@""]];
            cell.playImgView.hidden = NO;
        }
        
        return cell;
        
    }
    
}

// tableView的点击事件
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self insterDBData:_str];
    
    // 反选
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    SearchTieZiModel *model = _tbvDataArr[indexPath.row];
    
    DetailImgViewController *vc = [[DetailImgViewController alloc] init];
    vc.strId = model.id1;
    [self.navigationController pushViewController:vc animated:YES];
    
}

// 自定义分区表头和表尾
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, 0)];
//    uv.backgroundColor = [UIColor whiteColor];
//    
//    
//    if (section == 1) {
//        
//        // 文字
//        UILabel *lbCls = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 120, 35)];
//        lbCls.textColor = [UIColor colorWithRed:249/255.0 green:170/255.0 blue:49/255.0 alpha:1.0];
//        lbCls.text = @"推荐";
//        lbCls.font = [UIFont systemFontOfSize:15];
//        [uv addSubview:lbCls];
//        
//        // 分割线
//        UILabel *lbFenge = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, W - 20, 1)];
//        lbFenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
//        [uv addSubview:lbFenge];
//    }
//    
//    return uv;
//}
//
//// 表头高度
//- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    
//    if (section == 0) {
//        return 0;
//    }else {
//        return 35;
//    }
//}


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
