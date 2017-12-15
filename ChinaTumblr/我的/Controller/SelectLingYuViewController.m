//
//  SelectLingYuViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/12.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "SelectLingYuViewController.h"
#import "FJTagCollectionLayout.h"
#import "CollectionViewCell.h"
#import "CollectionHeadOrFooterView.h"
#import "AllTieZiLingYuModel.h" // 数据模型

@interface SelectLingYuViewController ()<FJTagCollectionLayoutDelegate,UICollectionViewDataSource,CAAnimationDelegate> {
    
    NSMutableArray *_dataArray;
    
    // 用于保存当前所有已选中的领域，用于定于的提交
    NSMutableArray *_currentDingyueIdArr;
    
}

@property (nonatomic, strong) UICollectionView *collectionView;


@end

@implementation SelectLingYuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 初始化数组
    [self initArray];
    
    // 布局页面
    [self layoutViews];
    
    // 获取数据
    [self initDataSource];
}

// 初始化数组
- (void) initArray {
    
    _currentDingyueIdArr = [NSMutableArray array];
    
    _dataArray = [NSMutableArray array];
}

// 获取数据
- (void) initDataSource {
    
    // 假数据
    
    
    HttpRequest *http = [[HttpRequest alloc] init];
    // 获取所有帖子领域列表
    [http GetFieldListSuccess:^(id fieldList) {
        
        
        if ([fieldList isKindOfClass:[NSString class]]) {
            
            NSLog(@"%@",@"请求失败了");
            
        }else {
            
            _dataArray = fieldList;
            
            [_collectionView reloadData];
        }
        
    } failure:^(NSError *error) {
        
        NSLog(@"网络请求失败");
    }];
    
}

// 布局页面
- (void) layoutViews {
    
    // 背景图
    UIImageView *backImgView = [[UIImageView alloc] init];
    [self.view addSubview:backImgView];
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        make.height.equalTo(@(H));
    }];
    backImgView.image = [UIImage imageNamed:@"login_bg"];
    backImgView.userInteractionEnabled = YES;
    
    
    // 跳过按钮
    UIButton *skipBtn = [[UIButton alloc] init];
    [backImgView addSubview:skipBtn];
    [skipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backImgView).with.offset(35);
        make.right.equalTo(backImgView).with.offset(-25);
    }];
    [skipBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [skipBtn setTitleColor:FUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    skipBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [skipBtn addTarget:self action:@selector(skipBtnClick) forControlEvents:UIControlEventTouchUpInside];
    skipBtn.hidden = YES;
    
    // 标题
    UILabel *titleLb = [[UILabel alloc] init];
    [backImgView addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(skipBtn);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@(17));
    }];
    titleLb.font = [UIFont systemFontOfSize:17];
    titleLb.text = @"选择你感兴趣的";
    titleLb.textColor = FUIColorFromRGB(0xffffff);
    
    // 开启你的APP
    UIButton *StartYourAppBtn = [[UIButton alloc] init];
    [backImgView addSubview:StartYourAppBtn];
    [StartYourAppBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgView);
        make.bottom.equalTo(backImgView).with.offset(- 0.158 * W);
        make.width.equalTo(@(0.5625 * W));
        make.height.equalTo(@(0.15 * 0.5625 * W));
    }];
    StartYourAppBtn.layer.cornerRadius = 0.15 * 0.5625 * W / 2;
    StartYourAppBtn.layer.borderColor = FUIColorFromRGB(0xfeaa0a).CGColor;
    StartYourAppBtn.layer.borderWidth = 1.0;
    [StartYourAppBtn addTarget:self action:@selector(StartYourAppBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [StartYourAppBtn setTitle:@"开启你的APP" forState:UIControlStateNormal];
    [StartYourAppBtn setTitleColor:FUIColorFromRGB(0xfeaa0a) forState:UIControlStateNormal];
    StartYourAppBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    
    
    //配置collectionView
    [self configCollectionView];
}




// 开启点击事件
- (void) StartYourAppBtnClick:(UIButton *)StartYourAppBtn {
    
    
    StartYourAppBtn.userInteractionEnabled = NO;
    
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
            StartYourAppBtn.userInteractionEnabled = YES;
            
            
            // 创建消息中心
            NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
            // 在消息中心发布自己的消息
            [notiCenter postNotificationName:@"registerSuccess" object:@"4"];
            // 用于首页刷新
            [notiCenter postNotificationName:@"loginSuccessForShouye" object:@"1"];
            // 用于修改发现页
            [notiCenter postNotificationName:@"loginSuccessForFind" object:@"90"];
            // 用于修改消息页面
            [notiCenter postNotificationName:@"loginSuccessForXiaoXi" object:@"91"];
            
            
            // 设置跳转的样式
            CATransition *transition = [CATransition animation];
            transition.duration = 1.2f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            //    transition.subtype = kCATransitionFromRight;
            transition.delegate = self;
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            
            // 跳转到个人主页
            [self.navigationController popToRootViewControllerAnimated:NO];
            
        }else {
            
            StartYourAppBtn.userInteractionEnabled = YES;
        }
        
    } failure:^(NSError *error) {
        
        StartYourAppBtn.userInteractionEnabled = YES;
    }];
    
}

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
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64 - 0.15 * 0.5625 * W - 0.158*W) collectionViewLayout:tagLayout];
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
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
        cell.contentLabel.textColor = FUIColorFromRGB(0x151515);
    }else {
        //未选中
        cell.backGroupView.layer.borderColor = [UIColor colorWithRed:84/255.0 green:85/255.0 blue:86/255.0 alpha:1.0].CGColor;
        cell.backGroupView.layer.cornerRadius = 14;
        cell.backGroupView.backgroundColor = [UIColor clearColor];
        cell.contentLabel.textColor = [UIColor colorWithRed:186/255.0 green:187/255.0 blue:188/255.0 alpha:1.f];
    }
    
    cell.selectOrCancelSelect = ^{
        NSLog(@"点击选中或是取消选中操作");
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
    
    
    
    NSLog(@"hhhhhhhhh%@",_dataArray);
    
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


// 跳过按钮点击事件
- (void)skipBtnClick {
    
    
    // 创建消息中心
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    // 在消息中心发布自己的消息
    [notiCenter postNotificationName:@"registerSuccess" object:@"4"];
    // 用于首页刷新
    [notiCenter postNotificationName:@"loginSuccessForShouye" object:@"1"];
    // 用于修改发现页
    [notiCenter postNotificationName:@"loginSuccessForFind" object:@"90"];
    // 用于修改消息页面
    [notiCenter postNotificationName:@"loginSuccessForXiaoXi" object:@"91"];
    
    
    // 设置跳转的样式
    CATransition *transition = [CATransition animation];
    transition.duration = 1.2f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
//    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    // 跳转到个人主页
    [self.navigationController popToRootViewControllerAnimated:NO];
}

// 页面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // 关闭手势返回
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
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
