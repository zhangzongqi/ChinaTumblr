//
//  FindFenLeiTableViewCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/16.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "FindFenLeiTableViewCell.h"
#import "FindFenleiImgCell.h" 
#import "DetailImgViewController.h"
#import "AppDelegate.h"

@implementation FindFenLeiTableViewCell {
    
    NSMutableArray *_arrForList;
    
    NSInteger pageStart;
    NSString *pageSize;
    
    NSInteger _count;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _count = 0;
    
    pageStart = 0;
    pageSize = @"10";
    
    _arrForList = [NSMutableArray array];
    
    // 布局页面
    [self layoutViews];
    
}

// 布局页面
- (void) layoutViews {
    
    _collectionView.backgroundColor = [UIColor clearColor];
    // 代理
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    // collectionView始终可以横向滑动
    _collectionView.alwaysBounceHorizontal = YES;
    // collectionview的注册
    [_collectionView registerClass:[FindFenleiImgCell class] forCellWithReuseIdentifier:@"collection"];
    
    
    // 横向刷新
    [_collectionView addRefreshHeaderWithClosure:^{
        
        pageStart = arc4random()%(_count+1);
        // 刷新操作
        [self initData];
        
    } addRefreshFooterWithClosure:^{
        
        pageStart = arc4random()%(_count+1);
        // 加载操作
        [self initData];
    }];
}

// set方法
- (void)setDataSource:(NSDictionary *)dataSource {
    
    _dataSource = [NSDictionary dictionary];
    
    _dataSource = dataSource;
    
    _arrForList = [[dataSource valueForKey:@"noteListInfo"] valueForKey:@"noteList"];
    
    [_collectionView reloadData];
    
    _count = [[dataSource valueForKey:@"count"] integerValue];
    
//    // 去请求数据
//    [self initData];
}

// 请求数据
- (void) initData {
    
    HttpRequest *http = [[HttpRequest alloc] init];
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    NSLog(@"*******%ld",pageStart);
    
    // 创建用于请求的字典
    NSLog(@"_dataSourceKey::::%@",[_dataSource valueForKey:@"title"]);
    
    NSDictionary *dic = @{@"keyword":[_dataSource valueForKey:@"title"],@"orderBy":@"2",@"pageStart":[NSString stringWithFormat:@"%ld",pageStart],@"pageSize":pageSize};
    NSString *strDic = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicForData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strDic};
    
    
    [http PostGetNoteListByKeywordRecommendWithDic:dicForData Success:^(id userInfo) {
        
        // count
        _count = [[userInfo valueForKey:@"count"] integerValue];
        
        NSLog(@"count:::%ld",_count);
        
        if ([[userInfo valueForKey:@"kwId"] isEqualToString:@"flase"]) {
            // 没拿到数据
//            [_arrForList removeAllObjects];
//            [_collectionView reloadData];
            NSLog(@"呵呵呵呵呵或😁");
            [_collectionView endRefreshing];
        }else {
            // 拿到数据了
            _arrForList = [userInfo valueForKey:@"noteList"];
            NSLog(@":::::::::::::::::%@",_arrForList);
            
            NSLog(@"呵呵呵呵呵或");
            [_collectionView reloadData];
            [_collectionView endRefreshing];
        }
        
    } failure:^(NSError *error) {
        
        // 请求失败
        NSLog(@"呵呵呵呵呵或😁哈哈");
        [_collectionView endRefreshing];
    }];
}


#pragma mark ---UICollectionViewDelegate,UICollectionViewDataSource ---
// 返回的行数
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _arrForList.count;
}
// 绑定数据
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FindFenleiImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collection" forIndexPath:indexPath];
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary *dic = _arrForList[indexPath.row];
    
    
    if ([[dic valueForKey:@"type"] isEqualToString:@"0"]) {
        // 文字
        cell.videoImgView.hidden = YES;
        cell.backImgView.hidden = YES;
        cell.lbBack.hidden = NO;
        cell.lbBack.text = [dic valueForKey:@"content"];
    }else if([[dic valueForKey:@"type"] isEqualToString:@"1"]){
        // 图片
        cell.videoImgView.hidden = YES;
        cell.backImgView.hidden = NO;
        [cell.backImgView sd_setImageWithURL:[NSURL URLWithString:[[dic valueForKey:@"files"][0] valueForKey:@"path"]] placeholderImage:[UIImage imageNamed:@""]];
        cell.lbBack.hidden = YES;
    }else {
        // 视频
        cell.videoImgView.hidden = NO;
        cell.backImgView.hidden = NO;
        [cell.backImgView sd_setImageWithURL:[NSURL URLWithString:[[dic valueForKey:@"files"][0] valueForKey:@"path_cover"]] placeholderImage:[UIImage imageNamed:@""]];
        cell.lbBack.hidden = YES;
    }
    
    
    return cell;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 220*220
    
//    return CGSizeMake(CellH * 11 / 12, CellH * 11 / 12);
    return CGSizeMake(CellH, CellH);
}

// 点击事件
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = _arrForList[indexPath.row];
    
    // 获取delegate
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 详情页
    DetailImgViewController *vc = [[DetailImgViewController alloc] init];
    vc.strId = [dic valueForKey:@"id"];
    [vc setHidesBottomBarWhenPushed:YES];
    // 跳转
    [tempAppDelegate.mainTabbarController.viewControllers[1] pushViewController:vc animated:YES];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
