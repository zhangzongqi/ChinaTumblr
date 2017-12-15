//
//  FindTuijianTableViewCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/16.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "FindTuiJianTableViewCell.h"
#import "FindTuijianCollectionCell.h" // collectionView推荐cell

#import "UIView+LPFExtension.h"
#import "OtherMineViewController.h"
#import "AppDelegate.h"
#import "DetailImgViewController.h"
#import "SmallTableViewCell.h"
#import "FindTuiJianUserModel.h" // 是否喜欢模型

#define LPFWeak(type) __weak typeof(type) weakType = type;

@implementation FindTuiJianTableViewCell {
    
    NSMutableArray * _smallTableViewArr;
    
    NSMutableArray *_userLikeModelArr;
    
    NSMutableArray *_collectionViewArr;
    
    NSInteger _count;
    NSInteger _pageStart;
    NSInteger _pageSize;
    
    
}

static NSString *cellReuseIdentifier = @"collection";

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _count = 0;
    _pageSize = 10;
    _pageStart = 0;
    
    _smallTableViewArr = [NSMutableArray array];
    
    _userLikeModelArr = [NSMutableArray array];
    
    _collectionViewArr = [NSMutableArray array];
    
    // 布局页面
    [self layoutViews];
    
}

// 布局页面
- (void) layoutViews {
    
    
    _collectionView.backgroundColor = [UIColor clearColor];
    // 代理
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    
    // collectionview的注册
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FindTuijianCollectionCell class]) bundle:nil] forCellWithReuseIdentifier:cellReuseIdentifier];
    
    _collectionView.alwaysBounceHorizontal = YES;
    
    // 横向刷新
    [_collectionView addRefreshHeaderWithClosure:^{
        
        _pageStart =  arc4random()%(_count+1);
        // 刷新操作
        [self requestData];
        
    } addRefreshFooterWithClosure:^{
        
        _pageStart =  arc4random()%(_count+1);
        // 加载操作
        [self requestData];
    }];
}


// set方法
- (void)setDataSource:(NSArray *)dataSource {
    
    _dataSource = dataSource;
    NSLog(@"_dataSource::::::::::%@",_dataSource);
    
    
    [_userLikeModelArr removeAllObjects];
    for (int i = 0; i < dataSource.count; i++) {
        FindTuiJianUserModel *model =  [[FindTuiJianUserModel alloc] init];
        model.isLike = @"NO";
        [_userLikeModelArr addObject:model];
    }
    
    [_collectionViewArr removeAllObjects];
    [_collectionViewArr addObjectsFromArray:_dataSource];
    
    [_collectionView reloadData];
}


// 请求数据
- (void) requestData {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 获取用户加密相关信息
    NSArray *jiamiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    // 用于获取推荐用户列表
    NSDictionary *dicDataForUser = @{@"pageSize":[NSString stringWithFormat:@"%ld",_pageSize],@"pageStart":[NSString stringWithFormat:@"%ld",_pageStart]};
    NSString *dataJiaMiForUser = [[MakeJson createJson:dicDataForUser] AES128EncryptWithKey:jiamiArr[3]];
    NSDictionary *dataDicJiaMiForUser = @{@"tk":jiamiArr[0],@"key":jiamiArr[1],@"cg":jiamiArr[2],@"data":dataJiaMiForUser};
    NSLog(@"::::::%@",dataDicJiaMiForUser);
    // (获取推荐用户列表)
    [http PostGetUserListRecommendWithDic:dataDicJiaMiForUser Success:^(id userListInfo) {
        
        NSLog(@"userListInfo::::::::::%@",userListInfo);
        
        [_collectionView endRefreshing];
        
        if ([userListInfo isKindOfClass:[NSString class]]) {
            
            _count = 0;
            
//            [_collectionViewArr removeAllObjects];
//            NSLog(@"获取失败了");
            // 去请求下面的数据
//            [self.collectionView reloadData];
            
        }else {
            
            // count
            _count = [[userListInfo valueForKey:@"count"] integerValue];
            
            // 清空数组
            [_collectionViewArr removeAllObjects];
            // 给推荐数组赋值
            _collectionViewArr = [NSMutableArray arrayWithArray:[userListInfo valueForKey:@"userList"]];
            
            [_userLikeModelArr removeAllObjects];
            for (int i = 0; i < _collectionViewArr.count; i++) {
                FindTuiJianUserModel *model =  [[FindTuiJianUserModel alloc] init];
                model.isLike = @"NO";
                [_userLikeModelArr addObject:model];
            }
            
            // 刷新列表
            [self.collectionView reloadData];
        }
        
    } failure:^(NSError *error) {
        // 清空数组
//        [_collectionViewArr removeAllObjects];
        // 刷新列表
//        [self.collectionView reloadData];
        
        [_collectionView endRefreshing];
    }];
}


#pragma mark ---UICollectionViewDelegate,UICollectionViewDataSource ---
// 返回的行数
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    return _collectionViewArr.count;
}
// 绑定数据
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FindTuiJianUserModel *model = _userLikeModelArr[indexPath.row];
    
    FindTuijianCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    if ([model.isLike isEqualToString:@"NO"]) {
        cell.followButton.selected = NO;
    }else {
        cell.followButton.selected = YES;
    }
    
    cell.firstBgView.hidden = NO;
    
    
    cell.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    
    
    if ([[_collectionViewArr[indexPath.row] valueForKey:@"img"] isKindOfClass:[NSArray class]]) {
        // 为空数组
    }else {
        [cell.bgImageView sd_setImageWithURL:[[_collectionViewArr[indexPath.row] valueForKey:@"img"] valueForKey:@"background"] placeholderImage:[UIImage imageNamed:@""]];
        
        [cell.headPortraitImageView sd_setImageWithURL:[[_collectionViewArr[indexPath.row] valueForKey:@"img"] valueForKey:@"icon"] placeholderImage:[UIImage imageNamed:@""]];
    }
    // 签名
    cell.signLb.text = [_collectionViewArr[indexPath.row] valueForKey:@"sign"];
    
    cell.signatureLabel.text = [_collectionViewArr[indexPath.row] valueForKey:@"nickname"];
    
    
    if ([[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][0] valueForKey:@"type"] isEqualToString:@"0"]) {
        // 纯文字
        cell.lb0 = [[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][0] valueForKey:@"content"];
        cell.imgvideo0.hidden = YES;
        
    }else if([[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][0] valueForKey:@"type"] isEqualToString:@"1"]) {
        // 图片
        [cell.tieziImgView0 sd_setImageWithURL:[NSURL URLWithString:[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][0] valueForKey:@"files"]]];
        cell.imgvideo0.hidden = YES;
        cell.lb0.hidden = YES;
        
    }else {
        // 视频
        [cell.tieziImgView0 sd_setImageWithURL:[NSURL URLWithString:[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][0] valueForKey:@"files"]]] ;
        cell.lb0.hidden = YES;
    }
    
    if ([[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][1] valueForKey:@"type"] isEqualToString:@"0"]) {
        // 纯文字
        cell.lb1 = [[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][1] valueForKey:@"content"];
        cell.imgvideo1.hidden = YES;
    }else if([[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][1] valueForKey:@"type"] isEqualToString:@"1"]) {
        // 图片
        [cell.tieziImgView1 sd_setImageWithURL:[NSURL URLWithString:[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][1] valueForKey:@"files"]]];
        cell.imgvideo1.hidden = YES;
        cell.lb1.hidden = YES;
    }else {
        // 视频
        [cell.tieziImgView1 sd_setImageWithURL:[NSURL URLWithString:[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][1] valueForKey:@"files"]]] ;
        cell.lb1.hidden = YES;
    }
    
    if ([[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][2] valueForKey:@"type"] isEqualToString:@"0"]) {
        // 纯文字
        cell.lb2 = [[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][2] valueForKey:@"content"];
        cell.imgvideo2.hidden = YES;
        
    }else if([[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][2] valueForKey:@"type"] isEqualToString:@"1"]) {
        // 图片
        [cell.tieziImgView2 sd_setImageWithURL:[NSURL URLWithString:[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][2] valueForKey:@"files"]]];
        cell.imgvideo2.hidden = YES;
        cell.lb2.hidden = YES;
        
    }else {
        // 视频
        [cell.tieziImgView2 sd_setImageWithURL:[NSURL URLWithString:[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][2] valueForKey:@"files"]]] ;
        cell.lb2.hidden = YES;
    }
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 拿到用户id
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([[_collectionViewArr[indexPath.row] valueForKey:@"id"] isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:[_collectionViewArr[indexPath.row] valueForKey:@"id"]];
        };
        
    }else {
        
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:[_collectionViewArr[indexPath.row] valueForKey:@"id"]];
        };
    }
    
    
    cell.tieziViewClick1 = ^{
        [self tieziClickBy1:[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][0] valueForKey:@"id"]];
    };
    cell.tieziViewClick2 = ^{
        [self tieziClickBy2:[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][1] valueForKey:@"id"]];
    };
    cell.tieziViewClick3 = ^{
        [self tieziClickBy3:[[_collectionViewArr[indexPath.row] valueForKey:@"topNotes"][2] valueForKey:@"id"]];
    };
    cell.followBlock = ^{
        [self followClickBy:indexPath];
    };
    
    
    // 设置tableView的代理
    cell.followListTableView.delegate = self;
    cell.followListTableView.dataSource = self;
    [cell.followListTableView registerClass:[SmallTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    
    return cell;
}


// 第一个帖子
- (void) tieziClickBy1:(NSString *)strTieZiId {
    // 获取delegate
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 详情页
    DetailImgViewController *vc = [[DetailImgViewController alloc] init];
    vc.strId = strTieZiId;
    [vc setHidesBottomBarWhenPushed:YES];
    // 跳转
    [tempAppDelegate.mainTabbarController.viewControllers[1] pushViewController:vc animated:YES];
}
// 第二个帖子
- (void) tieziClickBy2:(NSString *)strTieZiId {
    // 获取delegate
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 详情页
    DetailImgViewController *vc = [[DetailImgViewController alloc] init];
    vc.strId = strTieZiId;
    [vc setHidesBottomBarWhenPushed:YES];
    // 跳转
    [tempAppDelegate.mainTabbarController.viewControllers[1] pushViewController:vc animated:YES];
}
// 第三个帖子
- (void) tieziClickBy3:(NSString *)strTieZiId {
    // 获取delegate
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 详情页
    DetailImgViewController *vc = [[DetailImgViewController alloc] init];
    vc.strId = strTieZiId;
    [vc setHidesBottomBarWhenPushed:YES];
    // 跳转
    [tempAppDelegate.mainTabbarController.viewControllers[1] pushViewController:vc animated:YES];
}

// 关注点击
- (void) followClickBy:(NSIndexPath *)indexPath {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    NSDictionary *idDic = @{@"uid":[_collectionViewArr[indexPath.row] valueForKey:@"id"],@"pageSize":@"15"};
    NSString *dataStr = [[MakeJson createJson:idDic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStr};

    // 拿到cell
    FindTuijianCollectionCell *cell = (FindTuijianCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    // 禁用用户交互
    cell.followButton.userInteractionEnabled = NO;
    if (cell.followButton.selected == NO) {
        // 进行关注数据请求
        [http PostAddFollowUserWithDic:dicData Success:^(id userInfo) {
            // 打开用户交互
            cell.followButton.userInteractionEnabled = YES;
            // 数据请求成功
            if ([userInfo isEqualToString:@"0"]) {
                NSLog(@"关注用户失败");
            }else {
                // 关注成功
                cell.followButton.selected = !cell.followButton.selected;
                [MBHUDView hudWithBody:@"关注用户成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                
                FindTuiJianUserModel *model = _userLikeModelArr[indexPath.row];
                model.isLike = @"YES";
                
                
                // 做一个单例 用于修改发现页面的推荐用户
                if ([UserDefaults valueForKey:@"FollowUserForNews"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:[_collectionViewArr[indexPath.row] valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserForNews"]];
                    [tempArr addObject:[_collectionViewArr[indexPath.row] valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                }
                
                
                // 获取粉丝
                [http PostGetFollowerUserInfoListWithDic:dicData Success:^(id userInfo) {
                    //
                    if ([userInfo isEqualToString:@"0"]) {
                        [_smallTableViewArr removeAllObjects];
                        [cell.followListTableView reloadData];
                        
                    }else {
                        [_smallTableViewArr removeAllObjects];
                        [_smallTableViewArr addObjectsFromArray:[MakeJson createArrWithJsonString:userInfo]];
                        [cell.followListTableView reloadData];
                    }
                    
                } failure:^(NSError *error) {
                    [_smallTableViewArr removeAllObjects];
                    [cell.followListTableView reloadData];
                }];
                
                // 跳转
                [UIView animateWithDuration:0.5f animations:^{
                    
                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[self.collectionView cellForItemAtIndexPath:indexPath] cache:YES];
                    cell.firstBgView.hidden = YES;
                    
                    
                    for (int i = 0; i < _collectionViewArr.count; i++) {
                        
                        if (i == indexPath.row) {
                            
                        }else {
                            // 拿到cell
                            FindTuijianCollectionCell *cell111 = (FindTuijianCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                            
                            if (cell111.firstBgView.hidden == YES) {
                                [UIView animateWithDuration:0.5f animations:^{
                                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:cell111 cache:YES];
                                    cell111.firstBgView.hidden = NO;
                                }];
                            }
                        }
                        
                    }
                    
                }];
            }
        } failure:^(NSError *error) {
            // 数据请求失败
            // 打开用户交互
            cell.followButton.userInteractionEnabled = YES;
        }];
    }else {
        
        // 进行删除关注数据请求
        [http PostDelFollowUserWithDic:dicData Success:^(id userInfo) {
            // 打开用户交互
            cell.followButton.userInteractionEnabled = YES;
            // 数据请求成功
            if ([userInfo isEqualToString:@"0"]) {
                NSLog(@"关注用户失败");
            }else {
                // 关注成功
                cell.followButton.selected = !cell.followButton.selected;
                [MBHUDView hudWithBody:@"取消关注成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                FindTuiJianUserModel *model = _userLikeModelArr[indexPath.row];
                model.isLike = @"NO";
                
                // 做一个单例 用于修改消息页面的用户关注状态
                if ([UserDefaults valueForKey:@"CancleFollowUserForNews"] == nil) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    [tempArr addObject:[_collectionViewArr[indexPath.row] valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUserForNews"];
                }else {
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"CancleFollowUserForNews"]];
                    [tempArr addObject:[_collectionViewArr[indexPath.row] valueForKey:@"id"]];
                    [UserDefaults setValue:tempArr forKey:@"CancleFollowUserForNews"];
                }
            }
        } failure:^(NSError *error) {
            // 数据请求失败
            // 打开用户交互
            cell.followButton.userInteractionEnabled = YES;
        }];
    }
}
// 头像点击block触发事件
- (void) iconImgViewBy:(NSString *)strUserId {
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 拿到用户id
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([strUserId isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        
        [TipIsYourSelf tipIsYourSelf];
        
    }else {
        
        // 获取delegate
        AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        // 跳转到他人主页
        OtherMineViewController *vc = [[OtherMineViewController alloc] init];
        [vc setHidesBottomBarWhenPushed:YES];
        vc.userId = strUserId;
        // 跳转
        [tempAppDelegate.mainTabbarController.viewControllers[1] pushViewController:vc animated:YES];
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 365*316
    
    return CGSizeMake(CellH * 365 / 316, CellH);
}

// 点击事件
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%ld",indexPath.row);
}

// 返回的行数
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _smallTableViewArr.count;
}
// 返回的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SmallTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if ([[_smallTableViewArr[indexPath.row] valueForKey:@"img"] isKindOfClass:[NSArray class]]) {
        cell.iconImgView.image = [UIImage imageNamed:@"账户管理_默认头像"];
    }else {
        [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:[[_smallTableViewArr[indexPath.row] valueForKey:@"img"] valueForKey:@"icon"]]];
    }
    cell.nickNameLb.text = [_smallTableViewArr[indexPath.row] valueForKey:@"nickname"];
    cell.signLb.text = [_smallTableViewArr[indexPath.row] valueForKey:@"sign"];
    
    // 选中无效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 拿到用户id
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([[_smallTableViewArr[indexPath.row] valueForKey:@"id"] isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:[_collectionViewArr[indexPath.row] valueForKey:@"id"]];
        };
        
    }else {
        
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:[_smallTableViewArr[indexPath.row] valueForKey:@"id"]];
        };
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 40;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 获取delegate
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 跳转到他人主页
    OtherMineViewController *vc = [[OtherMineViewController alloc] init];
    [vc setHidesBottomBarWhenPushed:YES];
    vc.userId = [_smallTableViewArr[indexPath.row] valueForKey:@"id"];
    // 跳转
    [tempAppDelegate.mainTabbarController.viewControllers[1] pushViewController:vc animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

