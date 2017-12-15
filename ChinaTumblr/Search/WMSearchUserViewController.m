//
//  WMSearchUserViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/14.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "WMSearchUserViewController.h"
#import "SearchUserCell.h" // cell
#import "SearchUserModel.h" // 搜索用户模型

#import "SearchDBManage.h" // 数据库

#import "OtherMineViewController.h" // 别人的详情页

// 最大存储的搜索历史 条数
#define MAX_COUNT 4

@interface WMSearchUserViewController ()<UITableViewDelegate, UITableViewDataSource> {
    
    NSArray *_tbvDataArr; // tableView的数据
    
    NSArray *_tbvTuijianDataArr; // 推荐的数据
}


@property (nonatomic, copy) UITableView *tableView;

@end

@implementation WMSearchUserViewController

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
    
    _tbvDataArr = [NSArray array];
    _tbvTuijianDataArr = [NSArray array];
}

// 请求数据
- (void) initData {
    
    // 数据请求
    HttpRequest *http = [[HttpRequest alloc] init];
    // (获取搜索用户列表)
    [http PostSearchUserWithKeyword:_str andPageStart:@"0" andPageSize:@"5" Success:^(id userListInfo) {
        
        NSLog(@"userListInfo:%@",userListInfo);
        
        _tbvDataArr = userListInfo;
        
        [_tableView reloadData];
        
    } failure:^(NSError *error) {
        
        NSLog(@"请求失败");
    }];
    
    
    // 获取用户加密相关信息
    NSArray *jiamiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    NSDictionary *dicData = @{@"pageSize":@"5",@"pageStart":[NSString stringWithFormat:@"%d",arc4random()%60]};
    NSString *dataJiaMi = [[MakeJson createJson:dicData] AES128EncryptWithKey:jiamiArr[3]];
    NSDictionary *dataDicJiaMi = @{@"tk":jiamiArr[0],@"key":jiamiArr[1],@"cg":jiamiArr[2],@"data":dataJiaMi};
    NSLog(@"dataDicJiaMi:%@",dataDicJiaMi);

    // (获取推荐用户列表)
    [http PostGetUserListRecommendForSearchWithDic:dataDicJiaMi Success:^(id userListInfo) {
        
        NSLog(@"userListInfo:%@",userListInfo);
        
        if ([userListInfo isKindOfClass:[NSString class]]) {
            
            NSLog(@"获取失败了");
            
        }else {
            
            // 刷新列表
            _tbvTuijianDataArr = userListInfo;
            
            [_tableView reloadData];
        }
        
    } failure:^(NSError *error) {
        
        NSLog(@"请求失败");
    }];
}

// 创建TableView
- (void) createTableView {
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, W, H - 64 - 1 - 32)];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[SearchUserCell class] forCellReuseIdentifier:@"cell"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        
        return _tbvDataArr.count;
        
    }else {
        
        if (_tbvTuijianDataArr.count == 0) {
            return 1;
        }else {
            return _tbvTuijianDataArr.count;
        }
        
    }
    
    
}

// 数据绑定
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        SearchUserModel *model = _tbvDataArr[indexPath.row];
        SearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        cell.nickName.text = model.nickname;
        [cell.iconImgView sd_setImageWithURL:[model.img objectForKey:@"icon"] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        cell.signLb.text = model.sign;
        cell.followNumLb.text = [NSString stringWithFormat:@"%@ 人关注",model.followNum];
        
        return cell;
        
    }else {
        
        if (_tbvTuijianDataArr.count == 0) {

            SearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            
            cell.nickName.text = @"无更多推荐用户";
            
            return cell;
        }else {
            SearchUserModel *model1 = _tbvTuijianDataArr[indexPath.row];
            SearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            
            cell.nickName.text = model1.nickname;
            [cell.iconImgView sd_setImageWithURL:[model1.img objectForKey:@"icon"] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
            cell.signLb.text = model1.sign;
            cell.followNumLb.text = [NSString stringWithFormat:@"%@ 人关注",model1.followNum];
            
            return cell;
        }
        
        
    }
}

// 行高
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 72;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 反选
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 用户单利
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if (indexPath.section == 0) {
        // 添加搜索历史
        SearchUserModel *model = _tbvDataArr[indexPath.row];
        [self insterDBData:model.nickname];
        
        //
        NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
        if ([model.id1 isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
            [TipIsYourSelf tipIsYourSelf];
        }else {
            //
            OtherMineViewController *vc = [[OtherMineViewController alloc] init];
            vc.userId = model.id1;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else {
        
        
        if (_tbvTuijianDataArr.count == 0) {
            
        }else {
            // 添加搜索历史
            SearchUserModel *model = _tbvTuijianDataArr[indexPath.row];
            [self insterDBData:model.nickname];
            NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
            if ([model.id1 isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
                [TipIsYourSelf tipIsYourSelf];
            }else {
                //
                OtherMineViewController *vc = [[OtherMineViewController alloc] init];
                vc.userId = model.id1;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    
    
    
    
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
