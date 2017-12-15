//
//  MineFlagViewController.m
//  ChinaTumblr
//
//  Created by 张志鹏 on 2017/9/11.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "MineFlagViewController.h"
#import "FJTagCollectionLayout.h"
#import "CollectionViewCell.h"
#import "CollectionHeadOrFooterView.h"
#import "AllTieZiLingYuModel.h" // model
#import "SearchLabelDeatilViewController.h" // 搜索标签页面

@interface MineFlagViewController ()<FJTagCollectionLayoutDelegate,UICollectionViewDataSource> {
    
    NSMutableArray *_dataArray;
}
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation MineFlagViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_currnetSelectedIndex) {
        _currnetSelectedIndex(_currentIndex);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    // 假数据
//    NSArray *array = @[@"招行",@"农行基金",@"挖财",@"支付宝理财",@"银行理财",@"现金巴士",@"招行",@"农行基金",@"挖财",@"支付宝理财",@"银行理财",@"现金巴士",@"体育杂志",@"本地",@"财经",@"暴雪游戏帖",@"图片",@"轻松一刻",@"LOL",@"段子手",@"军事",@"房产",@"English"];
//    dataArray = [NSMutableArray array];
//    for (NSString *string in array) {
//        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
//        [dataDic setValue:string forKey:@"text"];
//        [dataDic setValue:@"0" forKey:@"isSelected"];
//        [dataArray addObject:dataDic];
//    }
    
    // 初始化数据源
    [self initArr];
    
    //配置collectionView
    [self configCollectionView];
    
    // 获取数据
    [self initData];
    
}

// 初始化数据源
- (void) initArr {
    
    _dataArray = [NSMutableArray array];
}


// 获取数据
- (void) initData {
    
    // 网络请求
    HttpRequest *http = [[HttpRequest alloc] init];
    
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2]};
    NSLog(@"dicData:%@",dicData);
    
    // 请求用户所有订阅关键词
    [http PostGetAllFollowKeywordListWithDic:dicData Success:^(id userInfo) {
        
        if ([userInfo isKindOfClass:[NSString class]]) {
            
        }else {
            // 更新数据源
            _dataArray = userInfo;
        }
        
        // 刷新列表
        [_collectionView reloadData];
        
    } failure:^(NSError *error) {
        
        // 请求失败
    }];
}


// 配置collectionView
- (void)configCollectionView
{
    // 例子 - 可根据自己的需求来变
    FJTagCollectionLayout *tagLayout = [[FJTagCollectionLayout alloc] init];
    
    //section inset
    tagLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    // 行间距
    tagLayout.lineSpacing = 15;
    
    // item间距
    tagLayout.itemSpacing = 10;
    
    // item高度
    tagLayout.itemHeigh = 26;
    
    // 对齐形式
    tagLayout.layoutAligned = FJTagLayoutAlignedMiddle;
    
    tagLayout.delegate = self;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64 - 44) collectionViewLayout:tagLayout];
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionHeadOrFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionHeadOrFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    
    [self.view addSubview:self.collectionView];
//    [self.collectionView reloadData];
}

#pragma mark  ------- UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dataArray[indexPath.row]];
    
    AllTieZiLingYuModel *model = _dataArray[indexPath.row];
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    cell.contentLabel.text = model.title;
    cell.indexPath = indexPath;
    if (_isEdit) {
        cell.cancelButton.hidden = NO;
        cell.backGroupView.layer.borderColor = [UIColor colorWithRed:249/255.0 green:155/255.0 blue:14/255.0 alpha:1.0].CGColor;
        cell.backGroupView.layer.cornerRadius = 13;
        cell.backGroupView.backgroundColor = [UIColor whiteColor];
        cell.contentLabel.textColor = [UIColor colorWithRed:249/255.0 green:155/255.0 blue:14/255.0 alpha:1.0];
        cell.cancelItem = ^{
            NSLog(@"点击删除操作");
            
            NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
            NSDictionary *dic = @{@"kwdIds":model.id1};
            NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            // 发起请求
            HttpRequest *http = [[HttpRequest alloc] init];
            [http PostRemoveFollowKeywordWithDic:dicData Success:^(id userInfo) {
                // 成功
                
                if ([userInfo isEqualToString:@"0"]) {
                    
                }else {
                    [_dataArray removeObject:model];
                    [_collectionView reloadData];
                    
                    // 从单利中移除
                    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                    NSArray *tempArr = [user valueForKey:@"AllFollowKeyWordId"];
                    NSMutableArray *NewIdsArr = [NSMutableArray arrayWithArray:tempArr];
                    [NewIdsArr removeObject:model.id1];
                    [user setValue:NewIdsArr forKey:@"AllFollowKeyWordId"];
                    
                    // 发送消息通知
                    // 创建消息中心
                    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
                    // 在消息中心发布自己的消息
                    [notiCenter postNotificationName:@"reviseBiaoQian" object:nil];
                }
            } failure:^(NSError *error) {
                // 网络失败
            }];
        };
    }else {
        //未选中
        cell.cancelButton.hidden = YES;
        cell.backGroupView.layer.borderColor = [UIColor grayColor].CGColor;
        cell.backGroupView.layer.cornerRadius = 13;
        cell.backGroupView.backgroundColor = [UIColor whiteColor];
        cell.contentLabel.textColor = [UIColor grayColor];
        cell.selectOrCancelSelect = ^{
            NSLog(@"点击跳转");
            SearchLabelDeatilViewController *vc = [[SearchLabelDeatilViewController alloc] init];
            vc.strDeatil = model.title;
            [self.navigationController pushViewController:vc animated:YES];
        };
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CollectionHeadOrFooterView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        return headerView;
    } else {
        CollectionHeadOrFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        return footerView;
    }
}

#pragma mark  ------- FJTagCollectionLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FJTagCollectionLayout*)collectionViewLayout widthAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;
    size.height = 10;
    //计算字的width 这里主要font 是字体的大小
    
    NSMutableArray *sectionArray = [NSMutableArray array];
    for (AllTieZiLingYuModel *model in _dataArray) {
        [sectionArray addObject:model.title];
    }
    CGSize temSize = [self sizeWithString:sectionArray[indexPath.item] fontSize:14];
    size.width = temSize.width + 24 + 1; //20为左右空10
    
    return size.width;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(FJTagCollectionLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    return CGSizeMake(CGRectGetWidth(self.view.frame), 0.34375 * W);
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(FJTagCollectionLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
//{
//    return CGSizeMake(CGRectGetWidth(self.view.frame), 40.f);
//}

#pragma mark - uuuuu
- (CGSize)sizeWithString:(NSString *)str fontSize:(float)fontSize
{
    CGSize constraint = CGSizeMake(self.view.frame.size.width - 40, fontSize + 1);
    
    CGSize tempSize;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize retSize = [str boundingRectWithSize:constraint
                                       options:
                      NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attribute
                                       context:nil].size;
    tempSize = retSize;
    
    return tempSize ;
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
