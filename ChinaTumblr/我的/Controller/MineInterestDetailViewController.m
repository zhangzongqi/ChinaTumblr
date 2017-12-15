//
//  MineInterestDetailViewController.m
//  ChinaTumblr
//
//  Created by 张志鹏 on 2017/9/11.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "MineInterestDetailViewController.h"
#import "FJTagCollectionLayout.h"
#import "CollectionViewCell.h"
#import "CollectionHeadOrFooterView.h"
#import "AllTieZiLingYuModel.h" // 所有领域数据模型


@interface MineInterestDetailViewController ()<FJTagCollectionLayoutDelegate,UICollectionViewDataSource> {
    
    NSMutableArray *_dataArray;
    
    // 用于保存所有订阅领域Id
    NSArray *_allDingYueLingYuId;
    
    // 用于保存当前所有已选中的领域，用于定于的提交
    NSMutableArray *_currentDingyueIdArr;
    
    BOOL _isFirstLayOut;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) UIButton *baocunBtn; // 保存按钮
@end

@implementation MineInterestDetailViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_currnetSelectedIndex) {
        _currnetSelectedIndex(_currentIndex);
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 初始化数组
    [self initArray];
    
    //配置collectionView
    [self configCollectionView];
    
    // 获取数据
    [self initDataSource];
    
    
//    // 假数据
//    NSArray *array = @[@"哈哈哈",@"呵呵呵呵",@"挖财",@"余额宝理财",@"银行理财",@"现金巴士",@"招行",@"农行基金",@"挖财",@"支付宝理财",@"银行理财",@"现金巴士",@"体育杂志",@"本地",@"财经",@"暴雪游戏帖",@"图片",@"轻松一刻",@"LOL",@"段子手",@"军事",@"房产",@"English"];
//    dataArray = [NSMutableArray array];
//    for (NSString *string in array) {
//        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
//        [dataDic setValue:string forKey:@"text"];
//        [dataDic setValue:@"0" forKey:@"isSelected"];
//        [dataArray addObject:dataDic];
//    }
    
}

// 创建保存按钮
- (void) createBaoCunBtn {
    
    _baocunBtn = [[UIButton alloc] init];
    [self.view addSubview:_baocunBtn];
    [_baocunBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(- 50);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@(34));
        make.width.equalTo(@(100));
    }];
    _baocunBtn.layer.cornerRadius = 17;
    _baocunBtn.layer.borderColor = FUIColorFromRGB(0xfeaa0a).CGColor;
    _baocunBtn.layer.borderWidth = 1.f;
    [_baocunBtn setTitle:@"保存" forState:UIControlStateNormal];
    [_baocunBtn setTitleColor:FUIColorFromRGB(0xfeaa0a) forState:UIControlStateNormal];
    _baocunBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _baocunBtn.hidden = YES;
    // 保存按钮点击事件
    [_baocunBtn addTarget:self action:@selector(baocunClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

// 保存按钮点击事件
- (void) baocunClick:(UIButton *)baocunBtn {
    
    _baocunBtn.userInteractionEnabled = NO;
    
    // 去请求保存接口,绑定用户喜欢领域
    
    HttpRequest *http = [[HttpRequest alloc] init];
    
    NSArray *userJiami = [GetUserJiaMi getUserTokenAndCgAndKey];
    NSString *strIds = [NSString string];
    for (int i = 0; i < _currentDingyueIdArr.count; i++) {
        if (i == 0) {
            strIds = _currentDingyueIdArr[i];
        }else {
            strIds = [NSString stringWithFormat:@"%@,%@",strIds,_currentDingyueIdArr[i]];
        }
    }
    
    NSDictionary *dicdic = @{@"fieldIds":strIds};
    NSString *strDicData = [[MakeJson createJson:dicdic] AES128EncryptWithKey:userJiami[3]];
    NSDictionary *dic111 = @{@"tk":userJiami[0],@"key":userJiami[1],@"cg":userJiami[2],@"data":strDicData};
    NSLog(@"dic111:%@",dic111);
    // 绑定用户喜欢领域
    [http PostBindFieldWithDic:dic111 Success:^(id userInfo) {

        if ([userInfo isEqualToString:@"1"]) {
            
            // 网络请求失败
            [MBHUDView hudWithBody:@"订阅成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
            
            _baocunBtn.hidden = YES;
            _baocunBtn.userInteractionEnabled = YES;
        }else {
            
            _baocunBtn.userInteractionEnabled = YES;
        }

    } failure:^(NSError *error) {
        
        _baocunBtn.userInteractionEnabled = YES;
    }];
}

// 初始化数组
- (void) initArray {
    
    _dataArray = [NSMutableArray array];
    
    _allDingYueLingYuId = [NSArray array];
    
    _currentDingyueIdArr = [NSMutableArray array];
    
    _isFirstLayOut = YES;
}

// 获取数据
- (void) initDataSource {
    
    
    // 初始化请求类
    HttpRequest *http = [[HttpRequest alloc] init];
    
    // 获取所有帖子领域列表
    [http GetFieldListSuccess:^(id fieldList) {
        
        if ([fieldList isKindOfClass:[NSString class]]) {
            
            NSLog(@"%@",@"请求失败了");
            // 创建保存按钮
            [self createBaoCunBtn];
            
        }else {
            
            // 拿到数据源
            _dataArray = fieldList;
            
            
            // 用户加密信息
            NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
            // 需要用于请求的Dic
            NSDictionary *dic = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2]};
            // 获取用户所订阅的所有领域的编号
            [http PostGetAllFollowFieldIdListWithDic:dic Success:^(id userInfo) {
                
                if ([userInfo isEqualToString:@"false"]) {
                    
                    // 去刷新collectionView
                    [_collectionView reloadData];
                    // 创建保存按钮
                    [self createBaoCunBtn];
                }else {
                    
                    // 用于保存所有订阅领域Id
                    _allDingYueLingYuId = [userInfo componentsSeparatedByString:@","];
                    
                    // 修改按钮状态
                    for (int i = 0; i < _dataArray.count; i++) {
                        
                        AllTieZiLingYuModel *model = _dataArray[i];
                        
                        if ([_allDingYueLingYuId containsObject:model.id1]) {
                            
                            model.isSelected = @"1";
                        }
                    }
                    
                    // 去刷新collectionView
                    [_collectionView reloadData];
                    // 创建保存按钮
                    [self createBaoCunBtn];
                }
                
                NSLog(@"userInfo==========%@",userInfo);
                
            } failure:^(NSError *error) {
                
                // 请求失败
                // 创建保存按钮
                [self createBaoCunBtn];
                
            }];
    
        }
        
    } failure:^(NSError *error) {
        
        NSLog(@"网络请求失败");
        // 创建保存按钮
        [self createBaoCunBtn];
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
    tagLayout.itemHeigh = 28;
    
    // 对齐形式
    tagLayout.layoutAligned = FJTagLayoutAlignedMiddle;
    
    tagLayout.delegate = self;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64 - 100) collectionViewLayout:tagLayout];
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionHeadOrFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionHeadOrFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    
    [self.view addSubview:self.collectionView];
//    [self.collectionView reloadData];
}

#pragma mark  ------- UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 拿到数据
    AllTieZiLingYuModel *model = _dataArray[indexPath.row];
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    cell.contentLabel.text = [NSString stringWithFormat:@"%@",model.title];
    cell.indexPath = indexPath;
    cell.cancelButton.hidden = YES;
    if ([model.isSelected integerValue] == 1) {
        //选中
        cell.backGroupView.layer.borderColor = FUIColorFromRGB(0xfeaa0a).CGColor;
        cell.backGroupView.layer.cornerRadius = 14;
        cell.backGroupView.backgroundColor = FUIColorFromRGB(0xfeaa0a);
        cell.contentLabel.textColor = FUIColorFromRGB(0xffffff);
    }else {
        //未选中
        cell.backGroupView.layer.borderColor = [UIColor colorWithRed:186/255.0 green:187/255.0 blue:188/255.0 alpha:1.0].CGColor;
        cell.backGroupView.layer.cornerRadius = 14;
        cell.backGroupView.backgroundColor = [UIColor clearColor];
        cell.contentLabel.textColor = [UIColor colorWithRed:118/255.0 green:119/255.0 blue:120/255.0 alpha:1.f];
    }
    
    cell.selectOrCancelSelect = ^{
        NSLog(@"点击选中或是取消选中操作");
        
        // 保存按钮显示
        if (_baocunBtn.hidden == YES) {
            _baocunBtn.hidden = NO;
        }
        
        if ([model.isSelected isEqualToString:@"1"]) {
            //处于选中状态  取消选中
            model.isSelected = @"";
        }else {
            //处于未选中状态  选中
            model.isSelected = @"1";
        }
        [_dataArray replaceObjectAtIndex:indexPath.row withObject:model];
        [_collectionView reloadData];
    };
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CollectionHeadOrFooterView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        headerView.titleLabel.text = @"选择领域";
        headerView.titleLabel.textColor = [UIColor colorWithRed:186/255.0 green:187/255.0 blue:188/255.0 alpha:1.f];
        headerView.backgroundColor = [UIColor clearColor];
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
    
    [_currentDingyueIdArr removeAllObjects];
    
    for (int i = 0; i < _dataArray.count; i++) {
        
        AllTieZiLingYuModel *model = _dataArray[i];
        
        if ([model.isSelected isEqualToString:@"1"]) {
            
            [_currentDingyueIdArr addObject:model.id1];
        }
    }
    
    
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
    return CGSizeMake(CGRectGetWidth(self.view.frame), 0.375 * W);
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
