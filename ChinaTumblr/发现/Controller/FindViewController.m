//
//  FindViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/7/26.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "FindViewController.h"
#import "MineFocusOnLabel.h" // 我关注的标签视图
#import "FindTuiJianTableViewCell.h" // 发现tableView的推荐Cell
#import "FindFenLeiTableViewCell.h" // 发现tableView的分类cell
#import "OtherMineViewController.h" // 他人页面
#import "DetailImgViewController.h"
#import "SearchLabelDeatilViewController.h" // 关键词搜索页面

#import <TTGTagCollectionView/TTGTextTagCollectionView.h>


// 距离上端的距离
#define topOut 0.1434 * H
#define topCenter 0.1285 * H
#define topBack 0.1285 * H - (0.1434 * H - 0.1285 * H)
#define OutAlpha 1
#define CenterAlpha 0.2
#define BackAlpha 0.3

@interface FindViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,TTGTextTagCollectionViewDelegate> {
    
    NSInteger _count; // 计次
    
    
    NSMutableArray *_allUserGuanJianCiArr; // 所有用户订阅的关键词
    NSMutableArray *_allUserGuanJianCiNameArr; // 所有用户订阅的关键词名字
    
    
//    UILabel *lbTipupLoad; // 上拉提示
    
    UIView *navView; // 模拟导航栏
    
    // 继续下拉提示
    UILabel *jixuXiaLaLb;
    
    
    // 是否执行当前页面的刷新
    BOOL isDoThisViewRefrensh;
    // 是否触发卡片了页面出现
    BOOL isAppearCardView;
    
    
    UIButton *backBtn;
    
    // 4个视图
    UIView *_vc1;
    UIView *_vc2;
    UIView *_vc3;
    UIView *_vc4;
    
    // 4个视图上的图片
    UIImageView *_imgView1_1;
    UIImageView *_imgView1_2;
    UIImageView *_imgView1_3;
    UIImageView *_imgView2_1;
    UIImageView *_imgView2_2;
    UIImageView *_imgView2_3;
    UIImageView *_imgView3_1;
    UIImageView *_imgView3_2;
    UIImageView *_imgView3_3;
    UIImageView *_imgView4_1;
    UIImageView *_imgView4_2;
    UIImageView *_imgView4_3;
    
    // 头像
    UIImageView *_iconImgView1;
    UIImageView *_iconImgView2;
    UIImageView *_iconImgView3;
    UIImageView *_iconImgView4;
    
    // 4个视图上的昵称
    UILabel *_nickNameLb1;
    UILabel *_nickNameLb2;
    UILabel *_nickNameLb3;
    UILabel *_nickNameLb4;
    
    // 个性签名
    UILabel *_signLb1;
    UILabel *_signLb2;
    UILabel *_signLb3;
    UILabel *_signLb4;
    
    // 帖子数量按钮
    UIButton *_btnTieZiNum1;
    UIButton *_btnTieZiNum2;
    UIButton *_btnTieZiNum3;
    UIButton *_btnTieZiNum4;
    
    // 关注人数按钮
    UIButton *_followOnNum1;
    UIButton *_followOnNum2;
    UIButton *_followOnNum3;
    UIButton *_followOnNum4;
    
    
    // 显示出来的三个视图的宽度
    CGFloat _outW;
    CGFloat _centerW;
    CGFloat _backW;
    
    // 显示出来的三个视图的高度
    CGFloat _outH;
    CGFloat _centerH;
    CGFloat _backH;
    
    // 显示出来的三个视图的中心点
    CGPoint _ptOut;
    CGPoint _ptCenter;
    CGPoint _ptBack;
    
    
    // 推荐用户的起始值
    NSInteger pageStartForUser;
    // 推荐用户卡片起始值
    NSInteger pageStartForUserCard;
    
    // 发现页推荐用户数组
    NSMutableArray *_tbvTuijianUserDataArr;
    // 发现页面推荐用户卡片数组
    NSMutableArray *_tbvTuijianUserForCardDataArr;
    
    // 关键词数组
    NSMutableArray *_tbvGuanJianCiArr;
    // 关键词下的小分类对应的帖子
    NSMutableArray *_tbvGuanJianCiTieZiArr;
    
    // pageStart
    NSInteger pageStart;
    // pageSizr
    NSInteger pageSize;
    
    // countForXiaoBiaoTi;
    NSInteger countForXiaoBiaoTi;
    
    
    // 拿到数据后给的数据
    NSInteger cardCount;
    
    // 请求失败标识
    BOOL isFalseforCardRefrensh;
    // 去重标识
    BOOL isDidFilterForResponseDataList;
    
    BOOL isSlideCard; // 是否滑动过卡片
}

@property (nonatomic, copy) UIScrollView *bigScrollView; // 底层滚动图

@property (nonatomic, copy) UIView *moreFriendView; // 更多好友推荐
@property (nonatomic, copy) MineFocusOnLabel *mineFocusLb; // 我关注的标签视图

@property (nonatomic, copy) UITableView *tableView; // 列表

@property (nonatomic, copy) MBProgressHUD *HUD; // 动画

// 两行的collectionView热门标签
@property (copy, nonatomic) TTGTextTagCollectionView *twoLineTagView;

@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    
    // 背景色
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    

    // 初始化数组
    [self initArr];
    
    // 动画
    [self createLoadingForBtnClick];
    
    // 布局页面
    [self layoutViews];
    
    // 获取全部已关注标签
    [self getAllBiaoQian];
    
    // 先请求推荐用户接口,看是否有推荐用户
    [self initDataForTuiJianUser];
    
}

// 获取发现页面卡片推荐数据
- (void) initDataForCard {

    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 获取用户加密相关信息
    NSArray *jiamiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    // 用于获取推荐用户列表
    NSDictionary *dicDataForUser = @{@"pageSize":[NSString stringWithFormat:@"%ld",pageSize],@"pageStart":[NSString stringWithFormat:@"%ld",pageStartForUserCard]};
    NSString *dataJiaMiForUser = [[MakeJson createJson:dicDataForUser] AES128EncryptWithKey:jiamiArr[3]];
    NSDictionary *dataDicJiaMiForUser = @{@"tk":jiamiArr[0],@"key":jiamiArr[1],@"cg":jiamiArr[2],@"data":dataJiaMiForUser};
    // (获取推荐用户列表)
    [http PostGetUserListRecommendWithDic:dataDicJiaMiForUser Success:^(id userListInfo) {
        
        if ([userListInfo isKindOfClass:[NSString class]]) {
            cardCount = 0;
            // 清空数组
            [_tbvTuijianUserForCardDataArr removeAllObjects];
            NSLog(@"获取失败了");
            // 更多好友推荐页布局
            [self layoutMoreFriendView];
            
        }else {
            
            cardCount = [[userListInfo valueForKey:@"count"] integerValue];
            // 清空数组
            [_tbvTuijianUserForCardDataArr removeAllObjects];
            // 给推荐数组赋值
            _tbvTuijianUserForCardDataArr = [NSMutableArray arrayWithArray:[userListInfo valueForKey:@"userList"]];
            // 更多好友推荐页布局
            [self layoutMoreFriendView];
        }
        
        [_HUD hide:YES];
        
    } failure:^(NSError *error) {
        
        cardCount = 0;
        // 清空数组
        [_tbvTuijianUserForCardDataArr removeAllObjects];
        NSLog(@"请求失败");
        // 更多好友推荐页布局
        [self layoutMoreFriendView];
        
        [_HUD hide:YES];
    }];
}

// 获取发现页面卡片推荐数据刷新
- (void) initDataForCardRefrensh {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 获取用户加密相关信息
    NSArray *jiamiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    // 用于获取推荐用户列表
    NSDictionary *dicDataForUser = @{@"pageSize":[NSString stringWithFormat:@"%ld",pageSize],@"pageStart":[NSString stringWithFormat:@"%ld",pageStartForUserCard]};
    NSString *dataJiaMiForUser = [[MakeJson createJson:dicDataForUser] AES128EncryptWithKey:jiamiArr[3]];
    NSDictionary *dataDicJiaMiForUser = @{@"tk":jiamiArr[0],@"key":jiamiArr[1],@"cg":jiamiArr[2],@"data":dataJiaMiForUser};
    // (获取推荐用户列表)
    [http PostGetUserListRecommendWithDic:dataDicJiaMiForUser Success:^(id userListInfo) {
        
        isFalseforCardRefrensh = NO;
        
        if ([userListInfo isKindOfClass:[NSString class]]) {
            
            cardCount = 0;
            NSLog(@"获取失败了");
            
        }else {
            
            // 去重操作
            NSMutableArray *arr = [self filterResponseDataList:[userListInfo valueForKey:@"userList"]];
            
            // 检查剩余数组数量
            if(_tbvTuijianUserForCardDataArr.count > 0){
                // 给推荐数组赋值
                [_tbvTuijianUserForCardDataArr addObjectsFromArray:arr];
                // 去赋值
                cardCount = [[userListInfo valueForKey:@"count"] integerValue];
            }
        }
        
    } failure:^(NSError *error) {
        
        isFalseforCardRefrensh = YES;
        cardCount = 0;
        NSLog(@"请求失败");
    }];
}

// 过滤请求到的数据(去重复)
- (NSMutableArray *) filterResponseDataList:(NSArray *)arrForDataList {
    
    // 最终要得到的数组
    NSMutableArray *endArr = [NSMutableArray array];
    
    //
    NSMutableArray *arr =  [NSMutableArray array];
    [arr removeAllObjects];
    
    for (int i = 0; i < _tbvTuijianUserForCardDataArr.count; i++) {
        
        [arr addObject:[_tbvTuijianUserForCardDataArr[i] valueForKey:@"id"]];
    }
    
    
    for (int j = 0; j < arrForDataList.count; j++) {
        
        if ([arr containsObject:[arrForDataList[j] valueForKey:@"id"]]) {
            // 之前有
        }else {
            // 之前没有
            [endArr addObject:arrForDataList[j]];
        }
    }
    
    // 传出去的数据
    return endArr;
}


// 仅用于推荐用户部分的刷新
- (void) JustinitDataForTuiJianUser {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 获取用户加密相关信息
    NSArray *jiamiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    // 用于获取推荐用户列表
    NSDictionary *dicDataForUser = @{@"pageSize":[NSString stringWithFormat:@"%ld",pageSize],@"pageStart":[NSString stringWithFormat:@"%ld",pageStartForUser]};
    NSString *dataJiaMiForUser = [[MakeJson createJson:dicDataForUser] AES128EncryptWithKey:jiamiArr[3]];
    NSDictionary *dataDicJiaMiForUser = @{@"tk":jiamiArr[0],@"key":jiamiArr[1],@"cg":jiamiArr[2],@"data":dataJiaMiForUser};
    NSLog(@"::::::%@",dataDicJiaMiForUser);
    // (获取推荐用户列表)
    [http PostGetUserListRecommendWithDic:dataDicJiaMiForUser Success:^(id userListInfo) {
        
        if ([userListInfo isKindOfClass:[NSString class]]) {
            [_tbvTuijianUserDataArr removeAllObjects];
            NSLog(@"获取失败了");
            
            for (int i = 0; i< 3; i++) {
                UIImageView *imgView = [self.view viewWithTag:500 + i];
                imgView.image = [UIImage imageNamed:@"账户管理_默认头像"];
            }
            
            // 拿数据失败了
            [self.tableView reloadData];
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            
        }else {
            
            // 清空数组
            [_tbvTuijianUserDataArr removeAllObjects];
            // 给推荐数组赋值
            _tbvTuijianUserDataArr = [NSMutableArray arrayWithArray:[userListInfo valueForKey:@"userList"]];
            
            NSLog(@"_tbvTuijianUserDataArr::%@",_tbvTuijianUserDataArr);
            
            for (int i = 0; i< 3; i++) {
                UIImageView *imgView = [self.view viewWithTag:500 + i];
                imgView.image = [UIImage imageNamed:@"账户管理_默认头像"];
            }
            
            // 设置顶部推荐人头像
            for (int i = 0; i < _tbvTuijianUserDataArr.count; i++) {
                
                UIImageView *imgView = [self.view viewWithTag:500 + (3-i-1)];
                
                [imgView sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserDataArr[i] objectForKey:@"img"] valueForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
                
                if (i == 2) {
                    break;
                }
            }
            
            
            // 拿数据失败了
            [self.tableView reloadData];
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
        }
        
    } failure:^(NSError *error) {
        [_tbvTuijianUserDataArr removeAllObjects];
        // 拿数据失败了
        [self.tableView reloadData];
        // 结束动画
        [_HUD hide:YES];
        // 表格刷新完毕,结束上下刷新视图
        [self.tableView.mj_footer endRefreshing];
        NSLog(@"请求失败");
    }];
}


// 获取推荐用户和我关注的标签
- (void) initDataForTuiJianUser {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 获取用户加密相关信息
    NSArray *jiamiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    // 用于获取推荐用户列表
    NSDictionary *dicDataForUser = @{@"pageSize":[NSString stringWithFormat:@"%ld",pageSize],@"pageStart":[NSString stringWithFormat:@"%ld",pageStartForUser]};
    NSString *dataJiaMiForUser = [[MakeJson createJson:dicDataForUser] AES128EncryptWithKey:jiamiArr[3]];
    NSDictionary *dataDicJiaMiForUser = @{@"tk":jiamiArr[0],@"key":jiamiArr[1],@"cg":jiamiArr[2],@"data":dataJiaMiForUser};
    NSLog(@"::::::%@",dataDicJiaMiForUser);
    // (获取推荐用户列表)
    [http PostGetUserListRecommendWithDic:dataDicJiaMiForUser Success:^(id userListInfo) {
        
        if ([userListInfo isKindOfClass:[NSString class]]) {
            [_tbvTuijianUserDataArr removeAllObjects];
            NSLog(@"获取失败了");
            
            for (int i = 0; i< 3; i++) {
                UIImageView *imgView = [self.view viewWithTag:500 + i];
                imgView.image = [UIImage imageNamed:@"账户管理_默认头像"];
            }
            
            // 去请求下面的数据
            [self initData];
            
        }else {
            
            // 清空数组
            [_tbvTuijianUserDataArr removeAllObjects];
            // 给推荐数组赋值
            _tbvTuijianUserDataArr = [NSMutableArray arrayWithArray:[userListInfo valueForKey:@"userList"]];
            
            NSLog(@"_tbvTuijianUserDataArr::%@",_tbvTuijianUserDataArr);
            
            for (int i = 0; i< 3; i++) {
                UIImageView *imgView = [self.view viewWithTag:500 + i];
                imgView.image = [UIImage imageNamed:@"账户管理_默认头像"];
            }
            
            // 设置顶部推荐人头像
            for (int i = 0; i < _tbvTuijianUserDataArr.count; i++) {
                
                UIImageView *imgView = [self.view viewWithTag:500 + (3-i-1)];
                
                [imgView sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserDataArr[i] objectForKey:@"img"] valueForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
                
                if (i == 2) {
                    break;
                }
            }
            
            
            // 去请求下面的数据
            [self initData];
        }
        
    } failure:^(NSError *error) {
        [_tbvTuijianUserDataArr removeAllObjects];
        // 去请求下面的数据
        [self initData];
        NSLog(@"请求失败");
    }];
}

// 获取所有已关注标签
- (void) getAllBiaoQian {
    
    // 网络请求
    HttpRequest *http = [[HttpRequest alloc] init];
    
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2]};
    NSLog(@"dicData:%@",dicData);
    
    // 请求用户所有订阅关键词
    [http PostGetAllFollowKeywordListWithDic:dicData Success:^(id userInfo) {
        
        
        if ([userInfo isKindOfClass:[NSString class]]) {
            // 失败
            // 先去掉，再添加
            [_twoLineTagView removeAllTags];
            TTGTextTagConfig *config = _twoLineTagView.defaultConfig;
            config.tagTextFont = [UIFont systemFontOfSize:15.0f];
            config.tagExtraSpace = CGSizeMake(10, 10);
            config.tagTextColor = FUIColorFromRGB(0xffffff);
            config.tagSelectedTextColor = [UIColor whiteColor];
            config.tagBackgroundColor = [UIColor clearColor];
            config.tagSelectedBackgroundColor = [UIColor clearColor];
            config.tagCornerRadius = 14.0f;
            config.tagSelectedCornerRadius = 14.0f;
            config.tagBorderWidth = 0.f;
            config.tagBorderColor = FUIColorFromRGB(0x999999);
            config.tagSelectedBorderColor = FUIColorFromRGB(0x999999);
            config.tagShadowColor = [UIColor clearColor];
            config.tagShadowOffset = CGSizeMake(0, 0);
            config.tagShadowOpacity = 0.0f;
            config.tagShadowRadius = 0;
            _twoLineTagView.delegate = self;
            [_twoLineTagView addTag:@"您还没有关注标签哦~"];
            _twoLineTagView.numberOfLines = 1;
            [_twoLineTagView reload];
            _twoLineTagView.userInteractionEnabled = NO;
            
            
        }else {
            
            NSLog(@"userInfo:::::::::::::::::::::::::%@",userInfo);
            
            // 更新数据源
            [_allUserGuanJianCiArr removeAllObjects];
            [_allUserGuanJianCiArr addObjectsFromArray:userInfo];
            
            [_allUserGuanJianCiNameArr removeAllObjects];
            
            for (int i = 0; i < [userInfo count]; i++) {
                AllTieZiLingYuModel *model = userInfo[i];
                [_allUserGuanJianCiNameArr addObject:model.title];
            }
            
            
            // 先去掉，再添加
            [_twoLineTagView removeAllTags];
            [_twoLineTagView addTags:_allUserGuanJianCiNameArr];
            TTGTextTagConfig *config = _twoLineTagView.defaultConfig;
            config.tagTextFont = [UIFont systemFontOfSize:15.0f];
            config.tagExtraSpace = CGSizeMake(10, 10);
            config.tagTextColor = FUIColorFromRGB(0xffffff);
            config.tagSelectedTextColor = [UIColor whiteColor];
            config.tagBackgroundColor = [UIColor clearColor];
            config.tagSelectedBackgroundColor = [UIColor clearColor];
            config.tagCornerRadius = 14.0f;
            config.tagSelectedCornerRadius = 14.0f;
            config.tagBorderWidth = 1.f;
            config.tagBorderColor = FUIColorFromRGB(0x999999);
            config.tagSelectedBorderColor = FUIColorFromRGB(0x999999);
            config.tagShadowColor = [UIColor clearColor];
            config.tagShadowOffset = CGSizeMake(0, 0);
            config.tagShadowOpacity = 0.0f;
            config.tagShadowRadius = 0;
            _twoLineTagView.delegate = self;
            _twoLineTagView.numberOfLines = 1;
            [_twoLineTagView reload];
            _twoLineTagView.userInteractionEnabled = YES;
        }
        
        
        
        
        
    } failure:^(NSError *error) {
        
        // 请求失败
    }];
}

// 初始化数组
- (void) initArr {
    
    // 是否滑动过卡片
    isSlideCard = NO;
    
    // 用户关注的关键词
    _allUserGuanJianCiNameArr = [NSMutableArray array];
    _allUserGuanJianCiArr = [NSMutableArray array];
    
    isAppearCardView = NO;
    isDoThisViewRefrensh = NO;
    
    
    // 是否收到请求失败
    isFalseforCardRefrensh = NO;
    // 是否进行了去重
    isDidFilterForResponseDataList = NO;
    
    // 用于推荐用户
    pageStartForUser = 0;
    // 用于推荐用户卡片
    pageStartForUserCard = 0;
    
    // 当前页面的分页和约束
    pageStart = 0;
    pageSize = 10;
    
    // 发现页推荐用户数组
    _tbvTuijianUserDataArr = [NSMutableArray array];
    // 发现页面推荐用户卡片数组
    _tbvTuijianUserForCardDataArr = [NSMutableArray array];
    
    // 关键词数组
    _tbvGuanJianCiArr = [NSMutableArray array];
    // 关键词下对应的帖子
    _tbvGuanJianCiTieZiArr = [NSMutableArray array];
}


// 进行数据请求
- (void) initData {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 获取用户加密相关信息
    NSArray *jiamiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    
    // 用于发起请求的字典
    NSDictionary *dicData = @{@"pageSize":[NSString stringWithFormat:@"%ld",pageSize],@"pageStart":[NSString stringWithFormat:@"%ld",pageStart],@"pageSizeForNote":@"10"};
    NSString *dataJiaMi = [[MakeJson createJson:dicData] AES128EncryptWithKey:jiamiArr[3]];
    NSDictionary *dataDicJiaMi = @{@"tk":jiamiArr[0],@"key":jiamiArr[1],@"cg":jiamiArr[2],@"data":dataJiaMi};
    NSLog(@"dataDicJiaMi:%@",dataDicJiaMi);
    // 获取相关喜好订阅关键词
    [http PostGetKeywordListForUserLikeWithNotesWithDic:dataDicJiaMi Success:^(id userInfo) {
        
        if ([userInfo isKindOfClass:[NSString class]]) {
            
//            // 清空下面所有
//            [_tbvGuanJianCiArr removeAllObjects];
            
            // 拿数据失败了
            [self.tableView reloadData];
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            
        }else {
            // 拿数据成功了
            NSLog(@"userInfo::::%@",userInfo);
            [_tbvGuanJianCiArr removeAllObjects];
            _tbvGuanJianCiArr = [userInfo objectForKey:@"keywordList"];
            countForXiaoBiaoTi = [[userInfo objectForKey:@"count"] integerValue];
            // 刷新列表
            [_tableView reloadData];
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            
        }
        
    } failure:^(NSError *error) {
        
        [self.tableView reloadData];
        // 结束动画
        [_HUD hide:YES];
        // 表格刷新完毕,结束上下刷新视图
        [self.tableView.mj_footer endRefreshing];
        NSLog(@"网络请求失败了");
    }];
    
    
}

// 布局页面
- (void)layoutViews {
    
    // 底层滚动图
    _bigScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, W, H - 29)];
    _bigScrollView.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    [self.view addSubview:_bigScrollView];
    _bigScrollView.delegate = self;
    _bigScrollView.contentSize = CGSizeMake(W, H);
    _bigScrollView.alwaysBounceVertical = YES;
    
//    //如果你导入的MJRefresh库是最新的库，就用下面的方法创建下拉刷新和上拉加载事件
//    _bigScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headRefresh)];
//    _bigScrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefresh)];
    
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 调用下拉刷新方法
        [self footerRefresh];
    }];
    // 设置_tableView的顶头
    _bigScrollView.mj_footer = footer;
    
    [footer setTitle:@"继续上拉刷新当前数据" forState:MJRefreshStateIdle];
    [footer setTitle:@"松开刷新当前数据" forState:MJRefreshStatePulling];
    [footer setTitle:@"正在加载" forState:MJRefreshStateRefreshing];
    
    
    // 更多好友推荐页
    _moreFriendView = [[UIView alloc] initWithFrame:CGRectMake(0, - (H+49), W, H + 49)];
    [self.view addSubview:_moreFriendView];
    _moreFriendView.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    //添加轻扫手势
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    //设置轻扫的方向
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp; //默认向右
    [_moreFriendView addGestureRecognizer:swipeGesture];
    
    
//    // 我关注的标签
//    _mineFocusLb = [[MineFocusOnLabel alloc] initWithFrame:CGRectMake(0, 64, W, 0.125 * H)];
//    [_bigScrollView addSubview:_mineFocusLb];
    
    
    UILabel *myFocusLabelLbTip = [[UILabel alloc] initWithFrame:CGRectMake(18, 74, 85, 13)];
    [_bigScrollView addSubview:myFocusLabelLbTip];
    myFocusLabelLbTip.textColor = [UIColor colorWithRed:118/255.0 green:119/255.0 blue:120/255.0 alpha:1.0];
    myFocusLabelLbTip.font = [UIFont systemFontOfSize:13];
    myFocusLabelLbTip.textAlignment = NSTextAlignmentCenter;
    myFocusLabelLbTip.text = @"我关注的标签";
    

//    NSArray *tags = @[@"AutoLayout"];
    _twoLineTagView = [[TTGTextTagCollectionView alloc] initWithFrame:CGRectMake(20, 97, W - 22, 40)];
    [_bigScrollView addSubview:_twoLineTagView];
    // 两行
    _twoLineTagView.scrollDirection = TTGTagCollectionScrollDirectionHorizontal;
    _twoLineTagView.showsHorizontalScrollIndicator = NO;
    _twoLineTagView.showsVerticalScrollIndicator = NO;
    _twoLineTagView.alignment = TTGTagCollectionAlignmentLeft;
    
    TTGTextTagConfig *config = _twoLineTagView.defaultConfig;
    config.tagTextFont = [UIFont systemFontOfSize:15.0f];
    config.tagExtraSpace = CGSizeMake(10, 10);
    config.tagTextColor = FUIColorFromRGB(0xffffff);
    config.tagSelectedTextColor = [UIColor whiteColor];
    config.tagBackgroundColor = [UIColor clearColor];
    config.tagSelectedBackgroundColor = [UIColor clearColor];
    config.tagCornerRadius = 14.0f;
    config.tagSelectedCornerRadius = 14.0f;
    config.tagBorderWidth = 1.f;
    config.tagBorderColor = FUIColorFromRGB(0x999999);
    config.tagSelectedBorderColor = FUIColorFromRGB(0x999999);
    config.tagShadowColor = [UIColor clearColor];
    config.tagShadowOffset = CGSizeMake(0, 0);
    config.tagShadowOpacity = 0.0f;
    config.tagShadowRadius = 0;
    _twoLineTagView.delegate = self;
    
    _twoLineTagView.numberOfLines = 1;
    [_twoLineTagView reload];
    
    // tableview
    [self createTableView];
    
    // 创建导航栏
    [self createNavItem];
}


#pragma mark - 下拉刷新
//- (void)headRefresh{
//    
//    NSLog(@"上拉");
//}

#pragma mark - 上拉加载
- (void)footerRefresh{
    
    NSLog(@"哈哈");
    
    // 刷新动画
//    [self createLoadingForBtnClick];
    if (countForXiaoBiaoTi > pageSize) {
        pageStart = arc4random()%(countForXiaoBiaoTi-pageSize+1);
    }else {
        pageStart = 0;
    }
    // 请求数据
    [self initDataForTuiJianUser];
    [_bigScrollView.mj_footer endRefreshing];
}




#pragma mark ------TTGTextTagCollectionViewDelegate------
// collectionView的点击事件
- (void)textTagCollectionView:(TTGTextTagCollectionView *)textTagCollectionView didTapTag:(NSString *)tagText atIndex:(NSUInteger)index selected:(BOOL)selected {

    NSLog(@"Tap tag: %@, at: %ld, selected: %d", tagText, (long) index, selected);
    
    AllTieZiLingYuModel *model = _allUserGuanJianCiArr[index];
    SearchLabelDeatilViewController *vc = [[SearchLabelDeatilViewController alloc] init];
    vc.strDeatil = model.title;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}


//轻扫手势触发方法
-(void)swipeGesture:(id)sender
{
    
    UISwipeGestureRecognizer *swipe = sender;
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        
        //向上轻扫做的事情
        // 调用返回按钮点击事件
        [self backClick];
    }
}

// 创建tableView
- (void) createTableView {
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 137, W, H - 137) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [_bigScrollView addSubview:_tableView];
    [_tableView registerNib:[UINib nibWithNibName:@"FindTuiJianTableViewCell" bundle:nil] forCellReuseIdentifier:@"tuijianCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"FindFenLeiTableViewCell" bundle:nil] forCellReuseIdentifier:@"fenleiCell"];
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
}

// 上拉下拉刷新动画
- (void) createLoadingForBtnClick {
    // 动画
    _HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 展示
    [_HUD show:YES];
}


#pragma mark --- UITableViewDelegate,UITableViewDataSource ---
// 返回的分组数
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    // 推荐
    if (_tbvTuijianUserDataArr.count == 0) {
        
        NSInteger num = _tbvGuanJianCiArr.count;
        
        // 在返回行数前，修改tableView和scrollView的高度
        _tableView.size = CGSizeMake(W, 35*num + 0.34375 * W * num);
        _bigScrollView.contentSize = CGSizeMake(W, 137 + 35*num + 0.34375 * W * num + 20);
        
        return num;
        
    }else {
        
        NSInteger num = _tbvGuanJianCiArr.count + 1;
        // 在返回行数前，修改tableView和scrollView的高度
        _tableView.size = CGSizeMake(W, 35*num + 0.49375 * W + 0.34375 * W * num);
        _bigScrollView.contentSize = CGSizeMake(W, 137 + 35*num + 0.49375 * W + 0.34375 * W * (num - 1) + 20);
        return num;
    }
}

// 返回的行数
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

// 绑定数据
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_tbvTuijianUserDataArr.count == 0) {
        
        FindFenLeiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fenleiCell" forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.dataSource = _tbvGuanJianCiArr[indexPath.section];
        return cell;
        
    }else {
        
        
        if (_tbvGuanJianCiArr.count == 0) {
            // 关键词为空
            FindTuiJianTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tuijianCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor clearColor];
            cell.dataSource = _tbvTuijianUserDataArr;
            return cell;
            
        }else {
            // 关键词不为空
            if (indexPath.section == 0) {
                
                FindTuiJianTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tuijianCell" forIndexPath:indexPath];
                cell.backgroundColor = [UIColor clearColor];
                cell.dataSource = _tbvTuijianUserDataArr;
                return cell;
                
            }else {
                
                FindFenLeiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fenleiCell" forIndexPath:indexPath];
                
                cell.backgroundColor = [UIColor clearColor];
                cell.dataSource = _tbvGuanJianCiArr[indexPath.section - 1];
                return cell;
            }
        }
    }
}

// 返回的每一行的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_tbvTuijianUserDataArr.count == 0) {
        
        return 0.34375 * W;
        
    }else {
        
        NSLog(@"_tbvTuijianUserDataArr.count::::%ld",_tbvTuijianUserDataArr.count);
        
        if (indexPath.section == 0) {
            
            // 336
            //        return 0.295 * H;
            return 0.49375 * W;
            
        }else {
            
            return 0.34375 * W;
            
            // 240
            //        return 0.444 * W + 20;
        }
    }
}

// 点击事件
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%ld",indexPath.row);
}



// 自定义分区表头和表尾
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, 0)];
    uv.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    
    
    if (_tbvTuijianUserDataArr.count == 0) {
        // 推荐用户为空
        // 小横条
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 10, 3)];
        [uv addSubview:lb];
        lb.backgroundColor = [UIColor colorWithRed:252/255.0 green:169/255.0 blue:44/255.0 alpha:1.0];
        
        // 文字
        UIButton *lbCls = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 120, 35)];
        [lbCls setTitleColor:[UIColor colorWithRed:118/255.0 green:119/255.0 blue:120/255.0 alpha:1.0] forState:UIControlStateNormal];
        [lbCls setTitle:[_tbvGuanJianCiArr[section] valueForKey:@"title"] forState:UIControlStateNormal];
        lbCls.titleLabel.font = [UIFont systemFontOfSize:15];
        [uv addSubview:lbCls];
        lbCls.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [lbCls addTarget:self action:@selector(headerClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }else {
        // 推荐用户不为空
        if (section == 0) {
            
            // 小横条
            UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 10, 3)];
            [uv addSubview:lb];
            lb.backgroundColor = [UIColor colorWithRed:252/255.0 green:64/255.0 blue:68/255.0 alpha:1.0];
            
            // 文字
            UILabel *lbCls = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 120, 35)];
            lbCls.textColor = [UIColor colorWithRed:118/255.0 green:119/255.0 blue:120/255.0 alpha:1.0];
            lbCls.text = @"热门推荐";
            lbCls.font = [UIFont systemFontOfSize:15];
            [uv addSubview:lbCls];
            
        }else {
            
            // 小横条
            UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 10, 3)];
            [uv addSubview:lb];
            lb.backgroundColor = [UIColor colorWithRed:252/255.0 green:169/255.0 blue:44/255.0 alpha:1.0];
            
            // 文字
            UIButton *lbCls = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 120, 35)];
            [lbCls setTitleColor:[UIColor colorWithRed:118/255.0 green:119/255.0 blue:120/255.0 alpha:1.0] forState:UIControlStateNormal];
            [lbCls setTitle:[_tbvGuanJianCiArr[section - 1] valueForKey:@"title"] forState:UIControlStateNormal];
            lbCls.titleLabel.font = [UIFont systemFontOfSize:15];
            [uv addSubview:lbCls];
            lbCls.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [lbCls addTarget:self action:@selector(headerClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    return uv;
}

// 表头点击事件
- (void) headerClick:(UIButton *)btn {
    
    SearchLabelDeatilViewController *vc = [[SearchLabelDeatilViewController alloc] init];
    vc.strDeatil = [btn titleForState:UIControlStateNormal];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 35;
}


// 创建导航栏
- (void) createNavItem {
    
    // 提示刷新当前数据
    UILabel *lbTipXiala = [[UILabel alloc] init];
    [_bigScrollView addSubview:lbTipXiala];
    [lbTipXiala mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bigScrollView).with.offset(13);
        make.centerX.equalTo(_bigScrollView);
    }];
    lbTipXiala.font = [UIFont systemFontOfSize:12];
    lbTipXiala.attributedText = [self getAttributedStringWithString:@"~刷新当前数据~" lineSpace:5];
    lbTipXiala.numberOfLines = 0;
    lbTipXiala.textAlignment = NSTextAlignmentCenter;
    lbTipXiala.textColor = [UIColor whiteColor];
    
    
    
    // 导航栏
    navView = [[UIView alloc] init];
    [_bigScrollView addSubview:navView];
    [navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(_bigScrollView);
        make.width.equalTo(@(W));
        make.height.equalTo(@(64));
    }];
    navView.tag = 320;
    navView.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:31/255.0 alpha:1.0];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navViewtapClick)];
    [navView addGestureRecognizer:tap];
    
    // 提示语
    jixuXiaLaLb = [[UILabel alloc] init];
    [navView addSubview:jixuXiaLaLb];
    [jixuXiaLaLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(navView).with.offset(- 5);
        make.centerX.equalTo(navView);
    }];
    jixuXiaLaLb.font = [UIFont systemFontOfSize:12];
    jixuXiaLaLb.attributedText = [self getAttributedStringWithString:@"继续下拉\n显示更多好友推荐" lineSpace:5];
    jixuXiaLaLb.numberOfLines = 0;
    jixuXiaLaLb.textAlignment = NSTextAlignmentCenter;
    jixuXiaLaLb.textColor = [UIColor whiteColor];
    jixuXiaLaLb.hidden = YES;
    
    
    
    // 提示语
    UILabel *moreFriendTipLb = [[UILabel alloc] init];
    [navView addSubview:moreFriendTipLb];
    [moreFriendTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(navView).with.offset(10);
        make.left.equalTo(navView).with.offset(20);
    }];
    moreFriendTipLb.font = [UIFont systemFontOfSize:13];
    moreFriendTipLb.textColor = [UIColor grayColor];
    moreFriendTipLb.text = @"更多好友推荐";
    // 头像图片
    for (int i = 0; i < 3; i++) {
        
        UIImageView *imgView1 = [[UIImageView alloc] init];
        [navView addSubview:imgView1];
        [imgView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(navView).with.offset(-40 - 20*i);
            make.centerY.equalTo(moreFriendTipLb);
            make.width.equalTo(@(32));
            make.height.equalTo(@(32));
        }];
        imgView1.layer.cornerRadius = 16;
        imgView1.clipsToBounds = YES;
        imgView1.layer.borderColor = [FUIColorFromRGB(0xffffff) CGColor];
        imgView1.layer.borderWidth = 1.0;
        imgView1.image = [UIImage imageNamed:@"账户管理_默认头像"];
        imgView1.tag = 500 + i;
    }
    
    UIImageView *rightMenuImgView = [[UIImageView alloc] init];
    [navView addSubview:rightMenuImgView];
    [rightMenuImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(moreFriendTipLb);
        make.right.equalTo(navView).with.offset(-13.5);
        make.width.equalTo(@(13));
        make.height.equalTo(@(13));
    }];
    rightMenuImgView.image = [UIImage imageNamed:@"discover_icon1"];
}

// 导航栏点击事件
- (void) navViewtapClick {
    
    // 展示更多好友推荐页面
    [UIView animateWithDuration:0.3f animations:^{
        
        _moreFriendView.frame = CGRectMake(0, 0, W, H + 49);
        backBtn.hidden = NO;
        isAppearCardView = YES;
        
        pageStartForUserCard = 0;
        
        // 动画
        [self createLoadingForBtnClick];
        // 请求数据
        [self initDataForCard];
        
    } completion:^(BOOL finished) {
        
        [self.tabBarController.tabBar setHidden:YES];
    }];
}

//  一个string转换成AttributedString的方法
-(NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace; // 调整行间距
    NSRange range = NSMakeRange(0, [string length]);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attributedString;
}


- (void) btnreloadClick:(UIButton *)btn{
    
    [self initDataForCard];
}



//隐藏tabbar
//- (void)hideTabBar {
//    
//    if (self.tabBarController.tabBar.hidden == YES)
//    {
//        return;
//    }
//    UIView *contentView;
//    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
//        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
//    else
//        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
//    contentView.frame = CGRectMake(contentView.bounds.origin.x,  contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height + self.tabBarController.tabBar.frame.size.height);
//    
//    self.tabBarController.tabBar.hidden = YES;
//}

//显示tabbar
//- (void)showTabBar {
//    
//    if (self.tabBarController.tabBar.hidden == NO)
//    {
//        return;
//    }
//    UIView *contentView;
//    if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]])
//        
//        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
//    
//    else
//        
//        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
//    contentView.frame = CGRectMake(contentView.bounds.origin.x, contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
//    self.tabBarController.tabBar.hidden = NO;
//    
//}


// 更多好友推荐页布局
- (void) layoutMoreFriendView {
    
    
    // 返回按钮
    if (backBtn == nil) {
        backBtn = [[UIButton alloc] init];
        [self.tabBarController.view addSubview:backBtn];
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.tabBarController.view);
            make.centerX.equalTo(self.tabBarController.view);
            make.width.equalTo(@(87));
            make.height.equalTo(@(50));
        }];
        backBtn.imageView.sd_layout
        .bottomSpaceToView(backBtn, 15)
        .centerXEqualToView(backBtn)
        .widthIs(13)
        .heightIs(13);
        backBtn.titleLabel.sd_layout
        .bottomSpaceToView(backBtn.imageView, 8)
        .centerXEqualToView(backBtn)
        .widthIs(87)
        .heightIs(14);
        [backBtn setImage:[UIImage imageNamed:@"discover_icon2"] forState:UIControlStateNormal];
        [backBtn setTitle:@"回到发现主页" forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
//        backBtn.hidden = YES;
    }
    
    
    // 顶部提示语
    UILabel *topTipLb = [[UILabel alloc] init];
    [_moreFriendView addSubview:topTipLb];
    [topTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_moreFriendView).with.offset(44);
        make.centerX.equalTo(_moreFriendView);
    }];
    topTipLb.textColor = FUIColorFromRGB(0xffffff);
    topTipLb.text = @"更多好友推荐";
    topTipLb.font = [UIFont systemFontOfSize:16];
    
    
    // 计次
    _count = 0;
    
    // 宽高
    _outW = 0.84375 * W;
    _outH = 1.140625 * W;
    _centerW = 0.78125 * W;
    _centerH = _outH - (_outW - _centerW) / 2;
    _backW = _centerW - (_outW - _centerW);
    _backH = _centerH - (_outW - _centerW) / 2;
    
    
    if (_tbvTuijianUserForCardDataArr.count == 0) {
        
        [_tbvTuijianUserForCardDataArr removeAllObjects];
        
        
        // 移除所有
        [_vc4 removeFromSuperview];
        [_vc3 removeFromSuperview];
        [_vc2 removeFromSuperview];
        [_vc1 removeFromSuperview];
        
        
        // 重新加载按钮
        UIButton *btnReload = [[UIButton alloc] init];
        [_moreFriendView addSubview:btnReload];
        [btnReload mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_moreFriendView);
            make.width.equalTo(@(120));
            make.height.equalTo(@(40));
        }];
        [btnReload setTitle:@"再找找看～" forState:UIControlStateNormal];
        btnReload.layer.cornerRadius = 20;
        btnReload.layer.borderColor = FUIColorFromRGB(0xfeaa0a).CGColor;
        btnReload.layer.borderWidth = 1.0f;
        [btnReload setTitleColor:FUIColorFromRGB(0xfeaa0a) forState:UIControlStateNormal];
        [btnReload addTarget:self action:@selector(btnreloadClick:) forControlEvents:UIControlEventTouchUpInside];
        btnReload.titleLabel.font = [UIFont systemFontOfSize:14];
        btnReload.titleLabel.textAlignment = NSTextAlignmentCenter;
        
    }else {
        
        [_vc4 removeFromSuperview];
        [_vc3 removeFromSuperview];
        [_vc2 removeFromSuperview];
        [_vc1 removeFromSuperview];
        
        // 4个视图
        if (_vc1 == nil) {
            _vc1 = [[UIView alloc] initWithFrame:CGRectMake(0, topOut, _outW, _outH)];
            CGPoint pt1 = _vc1.center;
            pt1.x = self.view.frame.size.width / 2;
            _ptOut = pt1;
            _vc1.center = _ptOut;
        }
        if (_vc2 == nil) {
            _vc2 = [[UIView alloc] initWithFrame:CGRectMake(0, topCenter, _centerW, _centerH)];
            CGPoint pt2 = _vc2.center;
            pt2.x = self.view.frame.size.width / 2;
            _ptCenter = pt2;
            _vc2.center = _ptCenter;
        }
        if (_vc3 == nil) {
            _vc3 = [[UIView alloc] initWithFrame:CGRectMake(0, topBack, _backW, _backH)];
            CGPoint pt3 = _vc3.center;
            pt3.x = self.view.frame.size.width / 2;
            _ptBack = pt3;
            _vc3.center = _ptBack;
        }
        if (_vc4 == nil) {
            _vc4 = [[UIView alloc] initWithFrame:CGRectMake(0, topBack, _backW, _backH)];
            _vc4.center = _ptBack;
        }
        
        [_moreFriendView addSubview:_vc4];
        [_moreFriendView addSubview:_vc3];
        [_moreFriendView addSubview:_vc2];
        [_moreFriendView addSubview:_vc1];
        
        // 背景色
        _vc1.backgroundColor = FUIColorFromRGB(0xffffff);
        _vc2.backgroundColor = FUIColorFromRGB(0xffffff);
        _vc3.backgroundColor = FUIColorFromRGB(0xffffff);
        _vc4.backgroundColor = FUIColorFromRGB(0xffffff);
        // 圆角
        _vc1.layer.cornerRadius = 5;
        _vc2.layer.cornerRadius = 5;
        _vc3.layer.cornerRadius = 5;
        _vc4.layer.cornerRadius = 5;
        _vc1.clipsToBounds = YES;
        _vc2.clipsToBounds = YES;
        _vc3.clipsToBounds = YES;
        _vc4.clipsToBounds = YES;
        
        // 透明度
        _vc1.alpha = OutAlpha;
        _vc2.alpha = CenterAlpha;
        _vc3.alpha = BackAlpha;
        _vc4.hidden = YES;
        
        
        // 没兴趣按钮
        UIButton *notInterestedBtn = [[UIButton alloc] init];
        [_moreFriendView addSubview:notInterestedBtn];
        [notInterestedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_moreFriendView).with.offset(topOut + _outH + 25);
            make.left.equalTo(_moreFriendView).with.offset(0.1328125 * W);
            make.width.equalTo(@(0.3125 * W));
            make.height.equalTo(notInterestedBtn.mas_width).multipliedBy(0.34);
        }];
//        notInterestedBtn.imageView.sd_layout
//        .centerYEqualToView(notInterestedBtn)
//        .leftSpaceToView(notInterestedBtn, 0.2 * 0.3125 * W)
//        .widthIs(0.14 * 0.3125 * W)
//        .heightIs(0.14 * 0.3125 * W);
//        notInterestedBtn.titleLabel.sd_layout
//        .centerYEqualToView(notInterestedBtn)
//        .rightSpaceToView(notInterestedBtn, 0.2 * 0.3125 * W)
//        .widthIs(43.5)
//        .heightIs(14);
//        [notInterestedBtn setImage:[UIImage imageNamed:@"discover_button1"] forState:UIControlStateNormal];
        notInterestedBtn.layer.cornerRadius = 0.3125 * W * 0.34 / 2;
        notInterestedBtn.layer.borderWidth = 1.0;
        notInterestedBtn.layer.borderColor = [[UIColor grayColor] CGColor];
        [notInterestedBtn setTitle:@"左划没兴趣" forState:UIControlStateNormal];
        [notInterestedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        notInterestedBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        // 加关注按钮
        UIButton *focusOnBtn = [[UIButton alloc] init];
        [_moreFriendView addSubview:focusOnBtn];
        [focusOnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_moreFriendView).with.offset(topOut + _outH + 25);
            make.right.equalTo(_moreFriendView).with.offset(- 0.1328125 * W);
            make.width.equalTo(@(0.3125 * W));
            make.height.equalTo(notInterestedBtn.mas_width).multipliedBy(0.34);
        }];
//        focusOnBtn.imageView.sd_layout
//        .centerYEqualToView(focusOnBtn)
//        .leftSpaceToView(focusOnBtn, 0.2 * 0.3125 * W)
//        .widthIs(0.14 * 0.3125 * W)
//        .heightIs(0.14 * 0.3125 * W);
//        focusOnBtn.titleLabel.sd_layout
//        .centerYEqualToView(focusOnBtn)
//        .rightSpaceToView(focusOnBtn, 0.2 * 0.3125 * W)
//        .widthIs(43.5)
//        .heightIs(14);
//        [focusOnBtn setImage:[UIImage imageNamed:@"discover_button2"] forState:UIControlStateNormal];
        focusOnBtn.layer.cornerRadius = 0.3125 * W * 0.34 / 2;
        focusOnBtn.layer.borderWidth = 1.0;
        focusOnBtn.layer.borderColor = [[UIColor colorWithRed:249/255.0 green:170/255.0 blue:45/255.0 alpha:1.0] CGColor];
        [focusOnBtn setTitle:@"右划加关注" forState:UIControlStateNormal];
        [focusOnBtn setTitleColor:[UIColor colorWithRed:249/255.0 green:170/255.0 blue:45/255.0 alpha:1.0] forState:UIControlStateNormal];
        focusOnBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        
        
        
        [_imgView1_1 removeFromSuperview];
        [_imgView1_2 removeFromSuperview];
        [_imgView1_3 removeFromSuperview];
        [_imgView2_1 removeFromSuperview];
        [_imgView2_2 removeFromSuperview];
        [_imgView2_3 removeFromSuperview];
        [_imgView3_1 removeFromSuperview];
        [_imgView3_2 removeFromSuperview];
        [_imgView3_3 removeFromSuperview];
        [_imgView4_1 removeFromSuperview];
        [_imgView4_2 removeFromSuperview];
        [_imgView4_3 removeFromSuperview];
        
        
        
        // 4个视图图片/头像/昵称/个性签名/帖子数量/关注人数
        _imgView1_1 = [[UIImageView alloc] init];
        _imgView1_2 = [[UIImageView alloc] init];
        _imgView1_3 = [[UIImageView alloc] init];
        _imgView2_1 = [[UIImageView alloc] init];
        _imgView2_2 = [[UIImageView alloc] init];
        _imgView2_3 = [[UIImageView alloc] init];
        _imgView3_1 = [[UIImageView alloc] init];
        _imgView3_2 = [[UIImageView alloc] init];
        _imgView3_3 = [[UIImageView alloc] init];
        _imgView4_1 = [[UIImageView alloc] init];
        _imgView4_2 = [[UIImageView alloc] init];
        _imgView4_3 = [[UIImageView alloc] init];
        [_vc1 addSubview:_imgView1_1];
        [_vc1 addSubview:_imgView1_2];
        [_vc1 addSubview:_imgView1_3];
        [_vc2 addSubview:_imgView2_1];
        [_vc2 addSubview:_imgView2_2];
        [_vc2 addSubview:_imgView2_3];
        [_vc3 addSubview:_imgView3_1];
        [_vc3 addSubview:_imgView3_2];
        [_vc3 addSubview:_imgView3_3];
        [_vc4 addSubview:_imgView4_1];
        [_vc4 addSubview:_imgView4_2];
        [_vc4 addSubview:_imgView4_3];
        
        
        
        [_iconImgView1 removeFromSuperview];
        [_iconImgView2 removeFromSuperview];
        [_iconImgView3 removeFromSuperview];
        [_iconImgView4 removeFromSuperview];
        
        
        // 头像
        _iconImgView1 = [[UIImageView alloc] init];
        _iconImgView2 = [[UIImageView alloc] init];
        _iconImgView3 = [[UIImageView alloc] init];
        _iconImgView4 = [[UIImageView alloc] init];
        [_vc1 addSubview:_iconImgView1];
        [_vc2 addSubview:_iconImgView2];
        [_vc3 addSubview:_iconImgView3];
        [_vc4 addSubview:_iconImgView4];
        
        [_nickNameLb1 removeFromSuperview];
        [_nickNameLb2 removeFromSuperview];
        [_nickNameLb3 removeFromSuperview];
        [_nickNameLb4 removeFromSuperview];
        // 昵称
        _nickNameLb1 = [[UILabel alloc] init];
        _nickNameLb2 = [[UILabel alloc] init];
        _nickNameLb3 = [[UILabel alloc] init];
        _nickNameLb4 = [[UILabel alloc] init];
        [_vc1 addSubview:_nickNameLb1];
        [_vc2 addSubview:_nickNameLb2];
        [_vc3 addSubview:_nickNameLb3];
        [_vc4 addSubview:_nickNameLb4];
        
        [_signLb1 removeFromSuperview];
        [_signLb2 removeFromSuperview];
        [_signLb3 removeFromSuperview];
        [_signLb4 removeFromSuperview];
        // 个性签名
        _signLb1 = [[UILabel alloc] init];
        _signLb2 = [[UILabel alloc] init];
        _signLb3 = [[UILabel alloc] init];
        _signLb4 = [[UILabel alloc] init];
        [_vc1 addSubview:_signLb1];
        [_vc2 addSubview:_signLb2];
        [_vc3 addSubview:_signLb3];
        [_vc4 addSubview:_signLb4];
        
        [_btnTieZiNum1 removeFromSuperview];
        [_btnTieZiNum2 removeFromSuperview];
        [_btnTieZiNum3 removeFromSuperview];
        [_btnTieZiNum4 removeFromSuperview];
        // 帖子数量
        _btnTieZiNum1 = [[UIButton alloc] init];
        _btnTieZiNum2 = [[UIButton alloc] init];
        _btnTieZiNum3 = [[UIButton alloc] init];
        _btnTieZiNum4 = [[UIButton alloc] init];
        [_vc1 addSubview:_btnTieZiNum1];
        [_vc2 addSubview:_btnTieZiNum2];
        [_vc3 addSubview:_btnTieZiNum3];
        [_vc4 addSubview:_btnTieZiNum4];
        
        [_followOnNum1 removeFromSuperview];
        [_followOnNum2 removeFromSuperview];
        [_followOnNum3 removeFromSuperview];
        [_followOnNum4 removeFromSuperview];
        // 关注人数
        _followOnNum1 = [[UIButton alloc] init];
        _followOnNum2 = [[UIButton alloc] init];
        _followOnNum3 = [[UIButton alloc] init];
        _followOnNum4 = [[UIButton alloc] init];
        [_vc1 addSubview:_followOnNum1];
        [_vc2 addSubview:_followOnNum2];
        [_vc3 addSubview:_followOnNum3];
        [_vc4 addSubview:_followOnNum4];
        
        
        // 布局_vc1上的图片
        [_imgView1_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_vc1);
            make.left.equalTo(_vc1);
            make.width.equalTo(_vc1);
            make.height.mas_equalTo(_vc1.mas_height).multipliedBy(0.465753);
        }];
        [_imgView1_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView1_1.mas_bottom).with.offset(3);
            make.left.equalTo(_vc1);
            make.width.equalTo(_vc1.mas_width).multipliedBy(0.5).with.offset(-3);
            make.height.mas_equalTo(_vc1.mas_height).multipliedBy(0.223);
        }];
        [_imgView1_3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView1_2);
            make.right.equalTo(_vc1);
            make.width.equalTo(_imgView1_2);
            make.height.equalTo(_imgView1_2);
        }];
        
        // 布局_vc2上的图
        [_imgView2_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_vc2);
            make.left.equalTo(_vc2);
            make.width.equalTo(_vc2);
            make.height.mas_equalTo(_vc2.mas_height).multipliedBy(0.465753);
        }];
        [_imgView2_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView2_1.mas_bottom).with.offset(3);
            make.left.equalTo(_vc2);
            make.width.equalTo(_vc2.mas_width).multipliedBy(0.5).with.offset(-3);
            make.height.mas_equalTo(_vc2.mas_height).multipliedBy(0.223);
        }];
        [_imgView2_3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView2_2);
            make.right.equalTo(_vc2);
            make.width.equalTo(_imgView2_2);
            make.height.equalTo(_imgView2_2);
        }];
        // 布局_vc3上的图
        [_imgView3_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_vc3);
            make.left.equalTo(_vc3);
            make.width.equalTo(_vc3);
            make.height.mas_equalTo(_vc3.mas_height).multipliedBy(0.465753);
        }];
        [_imgView3_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView3_1.mas_bottom).with.offset(3);
            make.left.equalTo(_vc3);
            make.width.equalTo(_vc3.mas_width).multipliedBy(0.5).with.offset(-3);
            make.height.mas_equalTo(_vc3.mas_height).multipliedBy(0.223);
        }];
        [_imgView3_3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView3_2);
            make.right.equalTo(_vc3);
            make.width.equalTo(_imgView3_2);
            make.height.equalTo(_imgView3_2);
        }];
        // 布局_vc4上的图
        [_imgView4_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_vc4);
            make.left.equalTo(_vc4);
            make.width.equalTo(_vc4);
            make.height.mas_equalTo(_vc4.mas_height).multipliedBy(0.465753);
        }];
        [_imgView4_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView4_1.mas_bottom).with.offset(3);
            make.left.equalTo(_vc4);
            make.width.equalTo(_vc4.mas_width).multipliedBy(0.5).with.offset(-3);
            make.height.mas_equalTo(_vc4.mas_height).multipliedBy(0.223);
        }];
        [_imgView4_3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView4_2);
            make.right.equalTo(_vc4);
            make.width.equalTo(_imgView4_2);
            make.height.equalTo(_imgView4_2);
        }];
        
        
        // 布局头像
        [_iconImgView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView1_2.mas_bottom).with.offset(- 0.1 * _outW);
            make.centerX.equalTo(_vc1);
            make.height.mas_equalTo(_vc1.mas_width).multipliedBy(0.2);
            make.width.mas_equalTo(_vc1.mas_width).multipliedBy(0.2);
        }];
        _iconImgView1.layer.cornerRadius = 0.5 * 0.2 * _outW;
        _iconImgView1.clipsToBounds = YES;
        _iconImgView1.layer.borderWidth = 1.5;
        _iconImgView1.layer.borderColor = [FUIColorFromRGB(0xffffff) CGColor];
        [_iconImgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView2_2.mas_bottom).with.offset(- 0.1 * _outW);
            make.centerX.equalTo(_vc2);
            make.height.mas_equalTo(_vc2.mas_width).multipliedBy(0.2);
            make.width.mas_equalTo(_vc2.mas_width).multipliedBy(0.2);
        }];
        _iconImgView2.layer.cornerRadius = 0.5 * 0.2 * _outW;
        _iconImgView2.clipsToBounds = YES;
        _iconImgView2.layer.borderWidth = 1.5;
        _iconImgView2.layer.borderColor = [FUIColorFromRGB(0xffffff) CGColor];
        [_iconImgView3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView3_2.mas_bottom).with.offset(- 0.1 * _outW);
            make.centerX.equalTo(_vc3);
            make.height.mas_equalTo(_vc3.mas_width).multipliedBy(0.2);
            make.width.mas_equalTo(_vc3.mas_width).multipliedBy(0.2);
        }];
        _iconImgView3.layer.cornerRadius = 0.5 * 0.2 * _outW;
        _iconImgView3.clipsToBounds = YES;
        _iconImgView3.layer.borderWidth = 1.5;
        _iconImgView3.layer.borderColor = [FUIColorFromRGB(0xffffff) CGColor];
        [_iconImgView4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView4_2.mas_bottom).with.offset(- 0.1 * _outW);
            make.centerX.equalTo(_vc4);
            make.height.mas_equalTo(_vc4.mas_width).multipliedBy(0.2);
            make.width.mas_equalTo(_vc4.mas_width).multipliedBy(0.2);
        }];
        _iconImgView4.layer.cornerRadius = 0.5 * 0.2 * _outW;
        _iconImgView4.clipsToBounds = YES;
        _iconImgView4.layer.borderWidth = 1.5;
        _iconImgView4.layer.borderColor = [FUIColorFromRGB(0xffffff) CGColor];
        
        // 昵称布局
        [_nickNameLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImgView1.mas_bottom).with.offset(0.037 * _outW);
            make.centerX.equalTo(_vc1);
            make.height.equalTo(@(15));
        }];
        _nickNameLb1.font = [UIFont systemFontOfSize:15];
        _nickNameLb1.textColor = FUIColorFromRGB(0x212121);
        [_nickNameLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImgView2.mas_bottom).with.offset(0.037 * _outW);
            make.centerX.equalTo(_vc2);
            make.height.equalTo(@(15));
        }];
        _nickNameLb2.font = [UIFont systemFontOfSize:15];
        _nickNameLb2.textColor = FUIColorFromRGB(0x212121);
        [_nickNameLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImgView3.mas_bottom).with.offset(0.037 * _outW);
            make.centerX.equalTo(_vc3);
            make.height.equalTo(@(15));
        }];
        _nickNameLb3.font = [UIFont systemFontOfSize:15];
        _nickNameLb3.textColor = FUIColorFromRGB(0x212121);
        [_nickNameLb4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImgView4.mas_bottom).with.offset(0.037 * _outW);
            make.centerX.equalTo(_vc4);
            make.height.equalTo(@(15));
        }];
        _nickNameLb4.font = [UIFont systemFontOfSize:15];
        _nickNameLb4.textColor = FUIColorFromRGB(0x212121);
        
        // 个性签名布局
        [_signLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nickNameLb1.mas_bottom).with.offset(0.037 * _outW);
            make.centerX.equalTo(_vc1);
            make.height.equalTo(@(14));
        }];
        _signLb1.textColor = FUIColorFromRGB(0x999999);
        _signLb1.font = [UIFont systemFontOfSize:14];
        [_signLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nickNameLb2.mas_bottom).with.offset(0.037 * _outW);
            make.centerX.equalTo(_vc2);
            make.height.equalTo(@(14));
        }];
        _signLb2.textColor = FUIColorFromRGB(0x999999);
        _signLb2.font = [UIFont systemFontOfSize:14];
        [_signLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nickNameLb3.mas_bottom).with.offset(0.037 * _outW);
            make.centerX.equalTo(_vc3);
            make.height.equalTo(@(14));
        }];
        _signLb3.textColor = FUIColorFromRGB(0x999999);
        _signLb3.font = [UIFont systemFontOfSize:14];
        [_signLb4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nickNameLb4.mas_bottom).with.offset(0.037 * _outW);
            make.centerX.equalTo(_vc4);
            make.height.equalTo(@(14));
        }];
        _signLb4.textColor = FUIColorFromRGB(0x999999);
        _signLb4.font = [UIFont systemFontOfSize:14];
        
        
        // 关注人数布局
        _followOnNum1.sd_layout
        .rightSpaceToView(_vc1, 0.148 * _outW)
        .topSpaceToView(_signLb1, 0.0426 * _outW)
        .widthIs(_outW * 0.27)
        .heightIs(_outW * 0.0703);
        _followOnNum2.sd_layout
        .rightSpaceToView(_vc2, 0.148 * _outW)
        .topSpaceToView(_signLb2, 0.0426 * _outW)
        .widthIs(_outW * 0.27)
        .heightIs(_outW * 0.0703);
        _followOnNum3.sd_layout
        .rightSpaceToView(_vc3, 0.148 * _outW)
        .topSpaceToView(_signLb3, 0.0426 * _outW)
        .widthIs(_outW * 0.27)
        .heightIs(_outW * 0.0703);
        _followOnNum4.sd_layout
        .rightSpaceToView(_vc4, 0.148 * _outW)
        .topSpaceToView(_signLb4, 0.0426 * _outW)
        .widthIs(_outW * 0.27)
        .heightIs(_outW * 0.0703);
        [self addBorderToLayer:_followOnNum1];
        [self addBorderToLayer:_followOnNum2];
        [self addBorderToLayer:_followOnNum3];
        [self addBorderToLayer:_followOnNum4];
        [_followOnNum1 setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [_followOnNum2 setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [_followOnNum3 setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [_followOnNum4 setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
        _followOnNum1.titleLabel.font = [UIFont systemFontOfSize:13];
        _followOnNum2.titleLabel.font = [UIFont systemFontOfSize:13];
        _followOnNum3.titleLabel.font = [UIFont systemFontOfSize:13];
        _followOnNum4.titleLabel.font = [UIFont systemFontOfSize:13];
        
        // 帖子数量布局
        _btnTieZiNum1.sd_layout
        .leftSpaceToView(_vc1, 0.148 * _outW)
        .topSpaceToView(_signLb1, 0.0426 * _outW)
        .widthIs(_outW * 0.27)
        .heightIs(_outW * 0.0703);
        _btnTieZiNum2.sd_layout
        .leftSpaceToView(_vc2, 0.148 * _outW)
        .topSpaceToView(_signLb2, 0.0426 * _outW)
        .widthIs(_outW * 0.27)
        .heightIs(_outW * 0.0703);
        _btnTieZiNum3.sd_layout
        .leftSpaceToView(_vc3, 0.148 * _outW)
        .topSpaceToView(_signLb3, 0.0426 * _outW)
        .widthIs(_outW * 0.27)
        .heightIs(_outW * 0.0703);
        _btnTieZiNum4.sd_layout
        .leftSpaceToView(_vc4, 0.148 * _outW)
        .topSpaceToView(_signLb4, 0.0426 * _outW)
        .widthIs(_outW * 0.27)
        .heightIs(_outW * 0.0703);
        // 设置圆角
        [self addBorderToLayer:_btnTieZiNum1];
        [self addBorderToLayer:_btnTieZiNum2];
        [self addBorderToLayer:_btnTieZiNum3];
        [self addBorderToLayer:_btnTieZiNum4];
        [_btnTieZiNum1 setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [_btnTieZiNum2 setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [_btnTieZiNum3 setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [_btnTieZiNum4 setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
        _btnTieZiNum1.titleLabel.font = [UIFont systemFontOfSize:13];
        _btnTieZiNum2.titleLabel.font = [UIFont systemFontOfSize:13];
        _btnTieZiNum3.titleLabel.font = [UIFont systemFontOfSize:13];
        _btnTieZiNum4.titleLabel.font = [UIFont systemFontOfSize:13];
        
        
        
        // 拖拽手势
        UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doHandlePanAction:)];
        [_vc1 addGestureRecognizer:panGestureRecognizer];
        
        
        // 拖拽手势
        UIPanGestureRecognizer * panGestureRecognizer2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doHandlePanAction2:)];
        [_vc2 addGestureRecognizer:panGestureRecognizer2];
        
        // 拖拽手势
        UIPanGestureRecognizer * panGestureRecognizer3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doHandlePanAction3:)];
        [_vc3 addGestureRecognizer:panGestureRecognizer3];
        
        // 拖拽手势
        UIPanGestureRecognizer * panGestureRecognizer4 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doHandlePanAction4:)];
        [_vc4 addGestureRecognizer:panGestureRecognizer4];
        
        
        // 用户交互开关
        _vc1.userInteractionEnabled = YES;
        _vc2.userInteractionEnabled = NO;
        _vc3.userInteractionEnabled = NO;
        _vc4.userInteractionEnabled = NO;
        
        
        
        // 头像
        if ([[_tbvTuijianUserForCardDataArr[0] valueForKey:@"img"] isKindOfClass:[NSArray class]]) {
            // 头像为空
            _iconImgView1.image = [UIImage imageNamed:@"账户管理_默认头像"];
        }else {
            
            // 头像为空
            [_iconImgView1 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[0] valueForKey:@"img"] valueForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        }
        // 个性签名
        _signLb1.text = [_tbvTuijianUserForCardDataArr[0] valueForKey:@"sign"];
        // 昵称
        _nickNameLb1.text = [_tbvTuijianUserForCardDataArr[0] valueForKey:@"nickname"];
        // 帖子数量
        [_btnTieZiNum1 setTitle:[NSString stringWithFormat:@"%@篇帖子",[_tbvTuijianUserForCardDataArr[0] valueForKey:@"noteNum"]] forState:UIControlStateNormal];
        // 粉丝数量
        [_followOnNum1 setTitle:[NSString stringWithFormat:@"%@人关注",[_tbvTuijianUserForCardDataArr[0] valueForKey:@"followNum"]] forState:UIControlStateNormal];
        // 三个热门帖子
        [_imgView1_1  sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[0] valueForKey:@"topNotes"][0] valueForKey:@"files"]]];
        [_imgView1_2  sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[0] valueForKey:@"topNotes"][1] valueForKey:@"files"]]];
        [_imgView1_3 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[0] valueForKey:@"topNotes"][2] valueForKey:@"files"]]];
    
        
        
        _imgView1_1.userInteractionEnabled = YES;
        _imgView1_2.userInteractionEnabled = YES;
        _imgView1_3.userInteractionEnabled = YES;
        _imgView2_1.userInteractionEnabled = YES;
        _imgView2_2.userInteractionEnabled = YES;
        _imgView2_3.userInteractionEnabled = YES;
        _imgView3_1.userInteractionEnabled = YES;
        _imgView3_2.userInteractionEnabled = YES;
        _imgView3_3.userInteractionEnabled = YES;
        _imgView4_1.userInteractionEnabled = YES;
        _imgView4_2.userInteractionEnabled = YES;
        _imgView4_3.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap1_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick1)];
        UITapGestureRecognizer *tap2_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick1)];
        UITapGestureRecognizer *tap3_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick1)];
        UITapGestureRecognizer *tap4_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick1)];
        UITapGestureRecognizer *tap1_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick2)];
        UITapGestureRecognizer *tap2_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick2)];
        UITapGestureRecognizer *tap3_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick2)];
        UITapGestureRecognizer *tap4_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick2)];
        UITapGestureRecognizer *tap1_3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick3)];
        UITapGestureRecognizer *tap2_3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick3)];
        UITapGestureRecognizer *tap3_3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick3)];
        UITapGestureRecognizer *tap4_3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziImgClick3)];
        [_imgView1_1 addGestureRecognizer:tap1_1];
        [_imgView1_2 addGestureRecognizer:tap1_2];
        [_imgView1_3 addGestureRecognizer:tap1_3];
        [_imgView2_1 addGestureRecognizer:tap2_1];
        [_imgView2_2 addGestureRecognizer:tap2_2];
        [_imgView2_3 addGestureRecognizer:tap2_3];
        [_imgView3_1 addGestureRecognizer:tap3_1];
        [_imgView3_2 addGestureRecognizer:tap3_2];
        [_imgView3_3 addGestureRecognizer:tap3_3];
        [_imgView4_1 addGestureRecognizer:tap4_1];
        [_imgView4_2 addGestureRecognizer:tap4_2];
        [_imgView4_3 addGestureRecognizer:tap4_3];
        
        [_imgView1_1 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView1_1.clipsToBounds = YES;
        [_imgView1_2 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView1_2.clipsToBounds = YES;
        [_imgView1_3 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView1_3.clipsToBounds = YES;
        [_imgView2_1 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView2_1.clipsToBounds = YES;
        [_imgView2_2 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView2_2.clipsToBounds = YES;
        [_imgView2_3 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView2_3.clipsToBounds = YES;
        [_imgView3_1 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView3_1.clipsToBounds = YES;
        [_imgView3_2 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView3_2.clipsToBounds = YES;
        [_imgView3_3 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView3_3.clipsToBounds = YES;
        [_imgView4_1 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView4_1.clipsToBounds = YES;
        [_imgView4_2 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView4_2.clipsToBounds = YES;
        [_imgView4_3 setContentMode:UIViewContentModeScaleAspectFill];
        _imgView4_3.clipsToBounds = YES;
        
        
        
        _iconImgView1.userInteractionEnabled = YES;
        _iconImgView2.userInteractionEnabled = YES;
        _iconImgView3.userInteractionEnabled = YES;
        _iconImgView4.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touxiangDianji)];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touxiangDianji)];
        UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touxiangDianji)];
        UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touxiangDianji)];
        [_iconImgView1 addGestureRecognizer:tap1];
        [_iconImgView2 addGestureRecognizer:tap2];
        [_iconImgView3 addGestureRecognizer:tap3];
        [_iconImgView4 addGestureRecognizer:tap4];
        
    }
}


// 帖子图片
- (void) tieziImgClick1 {

    // 详情页
    DetailImgViewController *vc = [[DetailImgViewController alloc] init];
    vc.strId = [[_tbvTuijianUserForCardDataArr[0] valueForKey:@"topNotes"][0] valueForKey:@"id"];
    [vc setHidesBottomBarWhenPushed:YES];
    backBtn.hidden = YES;
    // 跳转
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void) tieziImgClick2 {
    // 详情页
    DetailImgViewController *vc = [[DetailImgViewController alloc] init];
    vc.strId = [[_tbvTuijianUserForCardDataArr[0] valueForKey:@"topNotes"][1] valueForKey:@"id"];
    [vc setHidesBottomBarWhenPushed:YES];
    backBtn.hidden = YES;
    // 跳转
    [self.navigationController pushViewController:vc animated:YES];
}
- (void) tieziImgClick3 {
    // 详情页
    DetailImgViewController *vc = [[DetailImgViewController alloc] init];
    vc.strId = [[_tbvTuijianUserForCardDataArr[0] valueForKey:@"topNotes"][2] valueForKey:@"id"];
    [vc setHidesBottomBarWhenPushed:YES];
    backBtn.hidden = YES;
    // 跳转
    [self.navigationController pushViewController:vc animated:YES];
}

// 头像的点击
- (void) touxiangDianji {
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 拿到用户id
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([[_tbvTuijianUserForCardDataArr[0] valueForKey:@"id"] isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        // 是自己
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"这是你自己哟~"];
        
    }else {
        // 跳转到他人主页
        OtherMineViewController *vc = [[OtherMineViewController alloc] init];
        vc.userId = [_tbvTuijianUserForCardDataArr[0] valueForKey:@"id"];
        [vc setHidesBottomBarWhenPushed:YES];
        backBtn.hidden = YES;
        // 跳转
        [self.navigationController pushViewController:vc animated:YES];
    }
}


// 设置虚线layer
- (void)addBorderToLayer:(UIButton *)btn {
    
    
    CAShapeLayer *border = [CAShapeLayer layer];
    //虚线的颜色
    border.strokeColor = FUIColorFromRGB(0xeeeeee).CGColor;
    //填充的颜色
    border.fillColor = [UIColor clearColor].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:btn.bounds cornerRadius:btn.height / 2];
    //设置路径
    border.path = path.CGPath;
    border.frame = btn.bounds;
    //虚线的宽度
    border.lineWidth = 1.f;
    //设置线条的样式
    border.lineCap = @"square";
    //虚线的间隔
    border.lineDashPattern = @[@5, @2];
    [btn.layer addSublayer:border];
    
}

// 返回点击事件
- (void) backClick {
    
    [UIView animateWithDuration:0.3f animations:^{
        
        _moreFriendView.frame = CGRectMake(0, - (H+49), W, H + 49);
        backBtn.hidden = YES;
        isAppearCardView = NO;
        
        
    } completion:^(BOOL finished) {
        
        // 滑动了卡片
        if (isSlideCard == YES) {
            // 动画
            [self createLoadingForBtnClick];
            // 重新获取推荐用户数据(仅进行推荐用户数据刷新，下面的内容不动)
            [self JustinitDataForTuiJianUser];
            isSlideCard = NO;
        }
        
        [self.tabBarController.tabBar setHidden:NO];
    }];
}

// 拖拽手势_vc4 视图
- (void) doHandlePanAction4:(UIPanGestureRecognizer *)paramSender {
    
    // 开始拖拽
    if (paramSender.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh%ld",_count);
        
        if (_count < _tbvTuijianUserForCardDataArr.count - 1) {
            
            _count ++;
            
        }else {
            
            _count = 0;
        }
    }
    
    // 0.3秒内完成动画_vc4   _vc4 Out
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc1.frame = CGRectMake(0, topOut, _outW, _outH);
        _vc1.center = _ptOut;
        _vc1.alpha = OutAlpha;
        
        if (_tbvTuijianUserForCardDataArr.count > 1) {
            // 头像
            if ([[_tbvTuijianUserForCardDataArr[1] valueForKey:@"img"] isKindOfClass:[NSArray class]]) {
                // 头像为空
                _iconImgView1.image = [UIImage imageNamed:@"账户管理_默认头像"];
                
            }else {
                
                // 有头像
                [_iconImgView1 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"img"] valueForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
            }
            // 个性签名
            _signLb1.text = [_tbvTuijianUserForCardDataArr[1] valueForKey:@"sign"];
            // 昵称
            _nickNameLb1.text = [_tbvTuijianUserForCardDataArr[1] valueForKey:@"nickname"];
            // 帖子数量
            [_btnTieZiNum1 setTitle:[NSString stringWithFormat:@"%@篇帖子",[_tbvTuijianUserForCardDataArr[1] valueForKey:@"noteNum"]] forState:UIControlStateNormal];
            // 帖子数量
            [_followOnNum1 setTitle:[NSString stringWithFormat:@"%@人关注",[_tbvTuijianUserForCardDataArr[1] valueForKey:@"followNum"]] forState:UIControlStateNormal];
            // 三个热门帖子
            [_imgView1_1 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][0] valueForKey:@"files"]]];
            [_imgView1_2 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][1] valueForKey:@"files"]]];
            [_imgView1_3 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][2] valueForKey:@"files"]]];
        }
        
    }];
    // 0.3秒内完成动画_vc2   _vc2 Center
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc2.frame = CGRectMake(0, topCenter, _centerW, _centerH);
        _vc2.center = _ptCenter;
        _vc2.alpha = CenterAlpha;
    }];
    // 0.3秒内完成动画_vc3   _vc3 Back
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc3.hidden = NO;
        _vc3.alpha = BackAlpha;
    }];
    
    
    // 完成手势拖拽
    CGPoint point = [paramSender translationInView:self.view];
    
    paramSender.view.center = CGPointMake(paramSender.view.center.x + point.x, paramSender.view.center.y + point.y);
    
    [paramSender setTranslation:CGPointMake(0, 0) inView:self.view];
    
    
    // 拖拽结束
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        
        // 移动的位置，大于页面总宽度的1/4
        if (fabs((paramSender.view.center.x - self.view.center.x)) > self.view.frame.size.width / 4) {
            
            // 创建请求头
            HttpRequest *http = [[HttpRequest alloc] init];
            // 获取用户加密相关
            NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
            NSDictionary *dic = @{@"uid":[_tbvTuijianUserForCardDataArr[0] valueForKey:@"id"]};
            // 临时ID
            NSString *tempId = _tbvTuijianUserForCardDataArr[0];
            NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            
            
            [UIView animateWithDuration:0.3f animations:^{
                
                if (paramSender.view.center.x > self.view.frame.size.width / 2) {
                    
                    // 向右飞出
                    _vc4.frame = CGRectMake(W,topOut -  2 * (topOut - paramSender.view.frame.origin.y), _outW, _outH);
                    
                    // 进行喜欢数据请求
                    [http PostAddFollowUserWithDic:dicData Success:^(id userInfo) {
                        
                        if ([userInfo isEqualToString:@"1"]) {
                            
                            // 做一个单例 用于修改发现页面的推荐用户
                            if ([UserDefaults valueForKey:@"FollowUserForNews"] == nil) {
                                NSMutableArray *tempArr = [NSMutableArray array];
                                [tempArr addObject:[tempId valueForKey:@"id"]];
                                [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                            }else {
                                NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserForNews"]];
                                [tempArr addObject:[tempId valueForKey:@"id"]];
                                [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                            }
                        }
                        
                    } failure:^(NSError *error) {
                    }];
            
                }else {
                    
                    // 向左飞出
                    _vc4.frame = CGRectMake(-_outW,topOut -  2 * (topOut - paramSender.view.frame.origin.y), _outW, _outH);
                    
                    // 进行不喜欢数据请求
                    [http PostAddDislikeUserWithDic:dicData Success:^(id userInfo) {
                    } failure:^(NSError *error) {
                    }];
                }
                
                
            } completion:^(BOOL finished) {
                
                // 是否滑动过卡片
                isSlideCard = YES;
                
                // 判断是否进行重新请求和布局页面的处理
                [self refrenshForCardToInitData];
                
                // 将视图转移成隐藏的底层
                _vc4.frame = CGRectMake(0, topBack, _backW, _backH);
                _vc4.center = _ptBack;
                [_moreFriendView insertSubview:_vc4 belowSubview:_vc3];
                _imgView4_1.image = [UIImage imageNamed:@"trans"];
                _imgView4_2.image = [UIImage imageNamed:@"trans"];
                _imgView4_3.image = [UIImage imageNamed:@"trans"];
                _iconImgView4.image = [UIImage imageNamed:@"trans"];
                // 个性签名
                _signLb4.text = @"";
                // 昵称
                _nickNameLb4.text = @"";
                // 帖子数量
                [_btnTieZiNum4 setTitle:@"" forState:UIControlStateNormal];
                // 关注数量
                [_followOnNum4 setTitle:@"" forState:UIControlStateNormal];

                _vc4.hidden = YES;
                _vc4.alpha = 0.0;
                
                // 用户交互开关
                _vc1.userInteractionEnabled = YES;
                _vc2.userInteractionEnabled = NO;
                _vc3.userInteractionEnabled = NO;
                _vc4.userInteractionEnabled = NO;
                
            }];
        }else {
            
            if (_count != 0) {
                
                _count--;
                
            }else {
                
                _count = _tbvTuijianUserForCardDataArr.count - 1;
            }
            
            // 0.3秒内完成复原动画
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc4.frame = CGRectMake(0, topOut, _outW, _outH);
                _vc4.center = _ptOut;
            }];
            
            // 0.3秒内完成动画_vc1复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc1.frame = CGRectMake(0, topCenter, _centerW, _centerH);
                _vc1.center = _ptCenter;
                _vc1.alpha = CenterAlpha;
                
                // 移除图片
                _imgView1_1.image = [UIImage imageNamed:@"trans"];
                _imgView1_2.image = [UIImage imageNamed:@"trans"];
                _imgView1_3.image = [UIImage imageNamed:@"trans"];
                _nickNameLb1.text = @"";
                _signLb1.text = @"";
                _iconImgView1.image = [UIImage imageNamed:@"trans"];
                [_followOnNum1 setTitle:@"" forState:UIControlStateNormal];
                [_btnTieZiNum1 setTitle:@"" forState:UIControlStateNormal];
                
                
            } completion:^(BOOL finished) {
                // 移除图片
            }];
            
            
            // 0.3秒内完成动画_vc2复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc2.frame = CGRectMake(0, topBack, _backW, _backH);
                _vc2.center = _ptBack;
                _vc2.alpha = BackAlpha;
            }];
            // 0.3秒内完成动画_vc3复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc3.hidden = YES;
                _vc3.alpha = 0.0;
            }];
        }
    }
}


// 去拿到卡片的下一批数据
- (void) refrenshForCardToInitData {
    
    // 删掉第一条数据
    [_tbvTuijianUserForCardDataArr removeObjectAtIndex:0];
    
    if ((pageSize < cardCount) && ((_tbvTuijianUserForCardDataArr.count == pageSize / 2) || (isDidFilterForResponseDataList && _tbvTuijianUserForCardDataArr.count < pageSize/2) || (isFalseforCardRefrensh == YES))) {
        
        // 生成随机起始位置
        pageStart = arc4random()%(cardCount+1);
        
        isDidFilterForResponseDataList = NO;
        // 去请求数据
        [self initDataForCardRefrensh];
    }
    
    // 判断当前数组是否为空
    if (_tbvTuijianUserForCardDataArr.count == 0) {
        [_vc1 removeFromSuperview];
        [_vc2 removeFromSuperview];
        [_vc3 removeFromSuperview];
        [_vc4 removeFromSuperview];
        _vc1 = nil;
        _vc2 = nil;
        _vc3 = nil;
        _vc4 = nil;
        [self layoutMoreFriendView];
    }
}



// 拖拽手势_vc3 视图
- (void) doHandlePanAction3:(UIPanGestureRecognizer *)paramSender {
    
    // 开始拖拽
    if (paramSender.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh%ld",_count);
        
        if (_count < _tbvTuijianUserForCardDataArr.count-1) {
            
            _count ++;
            
        }else {
            
            _count = 0;
        }
    }
    
    // 0.3秒内完成动画_vc4   _vc4 Out
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc4.frame = CGRectMake(0, topOut, _outW, _outH);
        _vc4.center = _ptOut;
        _vc4.alpha = OutAlpha;
        
        if (_tbvTuijianUserForCardDataArr.count > 1) {
            // 头像
            if ([[_tbvTuijianUserForCardDataArr[1] valueForKey:@"img"] isKindOfClass:[NSArray class]]) {
                // 头像为空
                _iconImgView4.image = [UIImage imageNamed:@"账户管理_默认头像"];
                
            }else {
                // 有头像
                [_iconImgView4 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"img"] valueForKey:@"icon"]]];
            }
            // 个性签名
            _signLb4.text = [_tbvTuijianUserForCardDataArr[1] valueForKey:@"sign"];
            // 昵称
            _nickNameLb4.text = [_tbvTuijianUserForCardDataArr[1] valueForKey:@"nickname"];
            // 帖子数量
            [_btnTieZiNum4 setTitle:[NSString stringWithFormat:@"%@篇帖子",[_tbvTuijianUserForCardDataArr[1] valueForKey:@"noteNum"]] forState:UIControlStateNormal];
            // 帖子数量
            [_followOnNum4 setTitle:[NSString stringWithFormat:@"%@人关注",[_tbvTuijianUserForCardDataArr[1] valueForKey:@"followNum"]] forState:UIControlStateNormal];
            // 三个热门帖子
            [_imgView4_1 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][0] valueForKey:@"files"]]];
            [_imgView4_2 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][1] valueForKey:@"files"]]];
            [_imgView4_3 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][2] valueForKey:@"files"]]];
        }
        
    }];
    // 0.3秒内完成动画_vc1   _vc1 Center
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc1.frame = CGRectMake(0, topCenter, _centerW, _centerH);
        _vc1.center = _ptCenter;
        _vc1.alpha = CenterAlpha;
    }];
    // 0.3秒内完成动画_vc2   _vc2 Back
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc2.hidden = NO;
        _vc2.alpha = BackAlpha;
    }];
    
    
    // 完成手势拖拽
    CGPoint point = [paramSender translationInView:self.view];
//    NSLog(@"X:%f;Y:%f",point.x,point.y);
    
    paramSender.view.center = CGPointMake(paramSender.view.center.x + point.x, paramSender.view.center.y + point.y);
    
    [paramSender setTranslation:CGPointMake(0, 0) inView:self.view];
    
    
    // 拖拽结束
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        
        // 移动的位置，大于页面总宽度的1/4
        if (fabs((paramSender.view.center.x - self.view.center.x)) > self.view.frame.size.width / 4) {
            
            
            // 创建请求头
            HttpRequest *http = [[HttpRequest alloc] init];
            // 获取用户加密相关
            NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
            NSDictionary *dic = @{@"uid":[_tbvTuijianUserForCardDataArr[0] valueForKey:@"id"]};
            // 临时ID
            NSString *tempId = _tbvTuijianUserForCardDataArr[0];
            NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            
            
            [UIView animateWithDuration:0.3f animations:^{
                
                if (paramSender.view.center.x > self.view.frame.size.width / 2) {
                    
                    // 向右飞出
                    _vc3.frame = CGRectMake(W,topOut -  2 * (topOut - paramSender.view.frame.origin.y), _outW, _outH);
                    
                    // 进行喜欢数据请求
                    [http PostAddFollowUserWithDic:dicData Success:^(id userInfo) {
                        
                        if ([userInfo isEqualToString:@"1"]) {
                            
                            // 做一个单例 用于修改发现页面的推荐用户
                            if ([UserDefaults valueForKey:@"FollowUserForNews"] == nil) {
                                NSMutableArray *tempArr = [NSMutableArray array];
                                [tempArr addObject:[tempId valueForKey:@"id"]];
                                [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                            }else {
                                NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserForNews"]];
                                [tempArr addObject:[tempId valueForKey:@"id"]];
                                [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                            }
                        }
                        
                    } failure:^(NSError *error) {
                    }];
                    
                }else {
                    
                    // 向左飞出
                    _vc3.frame = CGRectMake(-_outW,topOut -  2 * (topOut - paramSender.view.frame.origin.y), _outW, _outH);
                    
                    // 进行不喜欢数据请求
                    [http PostAddDislikeUserWithDic:dicData Success:^(id userInfo) {
                    } failure:^(NSError *error) {
                    }];
                }
                
                
            } completion:^(BOOL finished) {
                
                // 是否滑动过卡片
                isSlideCard = YES;
                
                // 判断是否进行重新请求和布局页面的处理
                [self refrenshForCardToInitData];
                
                // 将视图转移成隐藏的底层
                _vc3.frame = CGRectMake(0, topBack, _backW, _backH);
                _vc3.center = _ptBack;
                [_moreFriendView insertSubview:_vc3 belowSubview:_vc2];
                _imgView3_1.image = [UIImage imageNamed:@"trans"];
                _imgView3_2.image = [UIImage imageNamed:@"trans"];
                _imgView3_3.image = [UIImage imageNamed:@"trans"];
                _iconImgView3.image = [UIImage imageNamed:@"trans"];
                // 个性签名
                _signLb3.text = @"";
                // 昵称
                _nickNameLb3.text = @"";
                // 帖子数量
                [_btnTieZiNum3 setTitle:@"" forState:UIControlStateNormal];
                // 关注数量
                [_followOnNum3 setTitle:@"" forState:UIControlStateNormal];
                _vc3.hidden = YES;
                _vc3.alpha = 0.0;
                
                
                // 用户交互开关
                _vc1.userInteractionEnabled = NO;
                _vc2.userInteractionEnabled = NO;
                _vc3.userInteractionEnabled = NO;
                _vc4.userInteractionEnabled = YES;
                
            }];
        }else {
            
            if (_count != 0) {
                _count--;
            }else {
                _count = _tbvTuijianUserForCardDataArr.count - 1;
            }
            
            
            // 0.3秒内完成复原动画
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc3.frame = CGRectMake(0, topOut, _outW, _outH);
                _vc3.center = _ptOut;
            }];
            
            // 0.3秒内完成动画_vc4复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc4.frame = CGRectMake(0, topCenter, _centerW, _centerH);
                _vc4.center = _ptCenter;
                _vc4.alpha = CenterAlpha;
                
                // 移除图片
                _imgView4_1.image = [UIImage imageNamed:@"trans"];
                _imgView4_2.image = [UIImage imageNamed:@"trans"];
                _imgView4_3.image = [UIImage imageNamed:@"trans"];
                _nickNameLb4.text = @"";
                _signLb4.text = @"";
                _iconImgView4.image = [UIImage imageNamed:@"trans"];
                [_followOnNum4 setTitle:@"" forState:UIControlStateNormal];
                [_btnTieZiNum4 setTitle:@"" forState:UIControlStateNormal];
                
            } completion:^(BOOL finished) {
                // 移除图片
            }];
            
            // 0.3秒内完成动画_vc1复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc1.frame = CGRectMake(0, topBack, _backW, _backH);
                _vc1.center = _ptBack;
                _vc1.alpha = BackAlpha;
            }];
            // 0.3秒内完成动画_vc2复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc2.hidden = YES;
                _vc2.alpha = 0.0;
            }];
        }
    }
}

// 拖拽手势_vc2 视图
- (void) doHandlePanAction2:(UIPanGestureRecognizer *)paramSender {
    
    // 开始拖拽
    if (paramSender.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh%ld",_count);
        
        if (_count < _tbvTuijianUserForCardDataArr.count-1) {
            
            _count ++;
            
        }else {
            
            _count = 0;
        }
    }
    
    // 0.3秒内完成动画_vc3   _vc3 Out
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc3.frame = CGRectMake(0, topOut, _outW, _outH);
        _vc3.center = _ptOut;
        _vc3.alpha = OutAlpha;
        
        if (_tbvTuijianUserForCardDataArr.count > 1) {
            // 头像
            if ([[_tbvTuijianUserForCardDataArr[1] valueForKey:@"img"] isKindOfClass:[NSArray class]]) {
                // 头像为空
                _iconImgView3.image = [UIImage imageNamed:@"账户管理_默认头像"];
                
            }else {
                // 有头像
                [_iconImgView3 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"img"] valueForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
            }
            // 个性签名
            _signLb3.text = [_tbvTuijianUserForCardDataArr[1] valueForKey:@"sign"];
            // 昵称
            _nickNameLb3.text = [_tbvTuijianUserForCardDataArr[1] valueForKey:@"nickname"];
            // 帖子数量
            [_btnTieZiNum3 setTitle:[NSString stringWithFormat:@"%@篇帖子",[_tbvTuijianUserForCardDataArr[1] valueForKey:@"noteNum"]] forState:UIControlStateNormal];
            // 帖子数量
            [_followOnNum3 setTitle:[NSString stringWithFormat:@"%@人关注",[_tbvTuijianUserForCardDataArr[1] valueForKey:@"followNum"]] forState:UIControlStateNormal];
            // 三个热门帖子
            [_imgView3_1 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][0] valueForKey:@"files"]]];
            [_imgView3_2 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][1] valueForKey:@"files"]]];
            [_imgView3_3 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][2] valueForKey:@"files"]]];
        }
        
    }];
    
    
    // 0.3秒内完成动画_vc4   _vc4 Center
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc4.frame = CGRectMake(0, topCenter, _centerW, _centerH);
        _vc4.center = _ptCenter;
        _vc4.alpha = CenterAlpha;
    }];
    // 0.3秒内完成动画_vc1   _vc1 Back
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc1.hidden = NO;
        _vc1.alpha = BackAlpha;
    }];
    
    
    // 完成手势拖拽
    CGPoint point = [paramSender translationInView:self.view];
//    NSLog(@"X:%f;Y:%f",point.x,point.y);
    
    paramSender.view.center = CGPointMake(paramSender.view.center.x + point.x, paramSender.view.center.y + point.y);
    
    [paramSender setTranslation:CGPointMake(0, 0) inView:self.view];
    
    
    // 拖拽结束
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        
        // 移动的位置，大于页面总宽度的1/4
        if (fabs((paramSender.view.center.x - self.view.center.x)) > self.view.frame.size.width / 4) {
            
            // 创建请求头
            HttpRequest *http = [[HttpRequest alloc] init];
            // 获取用户加密相关
            NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
            NSDictionary *dic = @{@"uid":[_tbvTuijianUserForCardDataArr[0] valueForKey:@"id"]};
            // 临时ID
            NSString *tempId = _tbvTuijianUserForCardDataArr[0];
            NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            
            [UIView animateWithDuration:0.3f animations:^{
                
                if (paramSender.view.center.x > self.view.frame.size.width / 2) {
                    
                    // 向右飞出
                    _vc2.frame = CGRectMake(W,topOut -  2 * (topOut - paramSender.view.frame.origin.y), _outW, _outH);
                    
                    // 进行喜欢数据请求
                    [http PostAddFollowUserWithDic:dicData Success:^(id userInfo) {
                        
                        if ([userInfo isEqualToString:@"1"]) {
                            
                            // 做一个单例 用于修改发现页面的推荐用户
                            if ([UserDefaults valueForKey:@"FollowUserForNews"] == nil) {
                                NSMutableArray *tempArr = [NSMutableArray array];
                                [tempArr addObject:[tempId valueForKey:@"id"]];
                                [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                            }else {
                                NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserForNews"]];
                                [tempArr addObject:[tempId valueForKey:@"id"]];
                                [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                            }
                        }
                    } failure:^(NSError *error) {
                    }];
                    
                }else {
                    
                    // 向左飞出
                    _vc2.frame = CGRectMake(-_outW,topOut -  2 * (topOut - paramSender.view.frame.origin.y), _outW, _outH);
                    
                    
                    // 进行不喜欢数据请求
                    [http PostAddDislikeUserWithDic:dicData Success:^(id userInfo) {
                    } failure:^(NSError *error) {
                    }];
                    
                }
                
                
            } completion:^(BOOL finished) {
                
                // 是否滑动过卡片
                isSlideCard = YES;
                
                // 判断是否进行重新请求和布局页面的处理
                [self refrenshForCardToInitData];
                
                // 将视图转移成隐藏的底层
                _vc2.frame = CGRectMake(0, topBack, _backW, _backH);
                _vc2.center = _ptBack;
                [_moreFriendView insertSubview:_vc2 belowSubview:_vc1];
                _imgView2_1.image = [UIImage imageNamed:@"trans"];
                _imgView2_2.image = [UIImage imageNamed:@"trans"];
                _imgView2_3.image = [UIImage imageNamed:@"trans"];
                _iconImgView2.image = [UIImage imageNamed:@"trans"];
                // 个性签名
                _signLb2.text = @"";
                // 昵称
                _nickNameLb2.text = @"";
                // 帖子数量
                [_btnTieZiNum2 setTitle:@"" forState:UIControlStateNormal];
                // 关注数量
                [_followOnNum2 setTitle:@"" forState:UIControlStateNormal];

                _vc2.hidden = YES;
                _vc2.alpha = 0.0;
                
                // 用户交互开关
                _vc1.userInteractionEnabled = NO;
                _vc2.userInteractionEnabled = NO;
                _vc3.userInteractionEnabled = YES;
                _vc4.userInteractionEnabled = NO;
                
            }];
        }else {
            
            if (_count != 0) {
                
                _count--;
                
            }else {
                
                _count = _tbvTuijianUserForCardDataArr.count - 1;
            }
            
            // 0.3秒内完成复原动画
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc2.frame = CGRectMake(0, topOut, _outW, _outH);
                _vc2.center = _ptOut;
            }];
            
            // 0.3秒内完成动画_vc3复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc3.frame = CGRectMake(0, topCenter, _centerW, _centerH);
                _vc3.center = _ptCenter;
                _vc3.alpha = CenterAlpha;
                
                // 移除图片
                _imgView3_1.image = [UIImage imageNamed:@"trans"];
                _imgView3_2.image = [UIImage imageNamed:@"trans"];
                _imgView3_3.image = [UIImage imageNamed:@"trans"];
                _nickNameLb3.text = @"";
                _signLb3.text = @"";
                _iconImgView3.image = [UIImage imageNamed:@"trans"];
                [_followOnNum3 setTitle:@"" forState:UIControlStateNormal];
                [_btnTieZiNum3 setTitle:@"" forState:UIControlStateNormal];
                
            } completion:^(BOOL finished) {
                // 移除图片
            }];
            
            // 0.3秒内完成动画_vc4复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc4.frame = CGRectMake(0, topBack, _backW, _backH);
                _vc4.center = _ptBack;
                _vc4.alpha = BackAlpha;
            }];
            // 0.3秒内完成动画_vc4复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc1.hidden = YES;
                _vc1.alpha = 0.0;
            }];
        }
    }
}

// 拖拽手势_vc1 视图
- (void) doHandlePanAction:(UIPanGestureRecognizer *)paramSender {
    
    
    // 开始拖拽
    if (paramSender.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh%ld",_count);
        
        if (_count < _tbvTuijianUserForCardDataArr.count-1) {
            
            _count ++;
            
        }else {
            
            _count = 0;
        }
    }
    
    
    // 0.3秒内完成动画_vc2   _vc2 Out
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc2.frame = CGRectMake(0, topOut, _outW, _outH);
        _vc2.center = _ptOut;
        _vc2.alpha = OutAlpha;
        
        
        if (_tbvTuijianUserForCardDataArr.count > 1) {
            // 头像
            if ([[_tbvTuijianUserForCardDataArr[1] valueForKey:@"img"] isKindOfClass:[NSArray class]]) {
                // 头像为空
                _iconImgView2.image = [UIImage imageNamed:@"账户管理_默认头像"];
                
            }else {
                // 有头像
                [_iconImgView2 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"img"] valueForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
            }
            // 个性签名
            _signLb2.text = [_tbvTuijianUserForCardDataArr[1] valueForKey:@"sign"];
            // 昵称
            _nickNameLb2.text = [_tbvTuijianUserForCardDataArr[1] valueForKey:@"nickname"];
            // 帖子数量
            [_btnTieZiNum2 setTitle:[NSString stringWithFormat:@"%@篇帖子",[_tbvTuijianUserForCardDataArr[1] valueForKey:@"noteNum"]] forState:UIControlStateNormal];
            // 帖子数量
            [_followOnNum2 setTitle:[NSString stringWithFormat:@"%@人关注",[_tbvTuijianUserForCardDataArr[1] valueForKey:@"followNum"]] forState:UIControlStateNormal];
            // 三个热门帖子
            [_imgView2_1 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][0] valueForKey:@"files"]]];
            [_imgView2_2 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][1] valueForKey:@"files"]]];
            [_imgView2_3 sd_setImageWithURL:[NSURL URLWithString:[[_tbvTuijianUserForCardDataArr[1] valueForKey:@"topNotes"][2] valueForKey:@"files"]]];
        }
        
    }];
    
    // 0.3秒内完成动画_vc3   _vc3 Center
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc3.frame = CGRectMake(0, topCenter, _centerW, _centerH);
        _vc3.center = _ptCenter;
        _vc3.alpha = CenterAlpha;
    }];
    // 0.3秒内完成动画_vc4   _vc4 Back
    [UIView animateWithDuration:0.3f animations:^{
        
        _vc4.hidden = NO;
        _vc4.alpha = BackAlpha;
    }];
    
    
    // 完成手势拖拽
    CGPoint point = [paramSender translationInView:self.view];
//    NSLog(@"X:%f;Y:%f",point.x,point.y);
    
    paramSender.view.center = CGPointMake(paramSender.view.center.x + point.x, paramSender.view.center.y + point.y);
    
    [paramSender setTranslation:CGPointMake(0, 0) inView:self.view];
    
    
    // 拖拽结束
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        
        // 移动的位置，大于页面总宽度的1/4
        if (fabs((paramSender.view.center.x - self.view.center.x)) > self.view.frame.size.width / 4) {
            
            // 创建请求头
            HttpRequest *http = [[HttpRequest alloc] init];
            // 获取用户加密相关
            NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
            NSDictionary *dic = @{@"uid":[_tbvTuijianUserForCardDataArr[0] valueForKey:@"id"]};
            // 临时ID
            NSString *tempId = _tbvTuijianUserForCardDataArr[0];
            NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            
            [UIView animateWithDuration:0.3f animations:^{
                
                if (paramSender.view.center.x > self.view.frame.size.width / 2) {
                    
                    // 向右飞出
                    _vc1.frame = CGRectMake(W,topOut -  2 * (topOut - paramSender.view.frame.origin.y), _outW, _outH);
                    
                    // 进行喜欢数据请求
                    [http PostAddFollowUserWithDic:dicData Success:^(id userInfo) {
                        
                        if ([userInfo isEqualToString:@"1"]) {
                            
                            // 做一个单例 用于修改发现页面的推荐用户
                            if ([UserDefaults valueForKey:@"FollowUserForNews"] == nil) {
                                NSMutableArray *tempArr = [NSMutableArray array];
                                [tempArr addObject:[tempId valueForKey:@"id"]];
                                [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                            }else {
                                NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserForNews"]];
                                [tempArr addObject:[tempId valueForKey:@"id"]];
                                [UserDefaults setValue:tempArr forKey:@"FollowUserForNews"];
                            }
                        }
                    } failure:^(NSError *error) {
                    }];
                    
                    
                }else {
                    
                    // 向左飞出
                    _vc1.frame = CGRectMake(-_outW,topOut -  2 * (topOut - paramSender.view.frame.origin.y), _outW, _outH);
                    
                    
                    // 进行不喜欢数据请求
                    [http PostAddDislikeUserWithDic:dicData Success:^(id userInfo) {
                    } failure:^(NSError *error) {
                    }];
                    
                }
                
            } completion:^(BOOL finished) {
                
                // 是否滑动过卡片
                isSlideCard = YES;
                
                // 看是否需要布局和请求页面
                [self refrenshForCardToInitData];
                
                // 将视图转移成隐藏的底层
                _vc1.frame = CGRectMake(0, topBack, _backW, _backH);
                _vc1.center = _ptBack;
                [_moreFriendView insertSubview:_vc1 belowSubview:_vc4];
                _imgView1_1.image = [UIImage imageNamed:@"trans"];
                _imgView1_2.image = [UIImage imageNamed:@"trans"];
                _imgView1_3.image = [UIImage imageNamed:@"trans"];
                _iconImgView1.image = [UIImage imageNamed:@"trans"];
                // 个性签名
                _signLb1.text = @"";
                // 昵称
                _nickNameLb1.text = @"";
                // 帖子数量
                [_btnTieZiNum1 setTitle:@"" forState:UIControlStateNormal];
                // 关注数量
                [_followOnNum1 setTitle:@"" forState:UIControlStateNormal];
                _vc1.hidden = YES;
                _vc1.alpha = 0.0;
                
                // 用户交互开关
                _vc1.userInteractionEnabled = NO;
                _vc2.userInteractionEnabled = YES;
                _vc3.userInteractionEnabled = NO;
                _vc4.userInteractionEnabled = NO;
                
            }];
            
        }else {
            
            if (_count != 0) {
                
                _count--;
                
            }else {
                
                _count = _tbvTuijianUserForCardDataArr.count - 1;
            }
            
            // 0.3秒内完成复原动画
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc1.frame = CGRectMake(0, topOut, _outW, _outH);
                _vc1.center = _ptOut;
                
                // 旋转角度
                //            paramSender.view.transform = CGAffineTransformMakeRotation(- 270 *M_PI / 180.0);
            }];
            
            // 0.3秒内完成动画_vc2复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc2.frame = CGRectMake(0, topCenter, _centerW, _centerH);
                _vc2.center = _ptCenter;
                _vc2.alpha = CenterAlpha;
                
                // 移除图片/标题
                _imgView2_1.image = [UIImage imageNamed:@"trans"];
                _imgView2_2.image = [UIImage imageNamed:@"trans"];
                _imgView2_3.image = [UIImage imageNamed:@"trans"];
                _signLb2.text = @"";
                _nickNameLb2.text = @"";
                _iconImgView2.image = [UIImage imageNamed:@"trans"];
                [_followOnNum2 setTitle:@"" forState:UIControlStateNormal];
                [_btnTieZiNum2 setTitle:@"" forState:UIControlStateNormal];
                
            } completion:^(BOOL finished) {
                // 移除图片
            }];
            
            // 0.3秒内完成动画_vc3复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc3.frame = CGRectMake(0, topBack, _backW, _backH);
                _vc3.center = _ptBack;
                _vc3.alpha = BackAlpha;
            }];
            // 0.3秒内完成动画_vc4复原
            [UIView animateWithDuration:0.3f animations:^{
                
                _vc4.hidden = YES;
                _vc4.alpha = 0.0;
            }];
        }
    }
}


// 滚动视图代理事件（用于显示和隐藏topNavView）
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offset = scrollView.contentOffset.y;
    
    if (offset < -90) {
        isDoThisViewRefrensh = YES;
        jixuXiaLaLb.hidden = NO;
    }else {
        jixuXiaLaLb.hidden = YES;
    }
    
    if (offset < -150) {
        
        isAppearCardView = YES;
        
        [UIView animateWithDuration:0.3f animations:^{
            
            _moreFriendView.frame = CGRectMake(0, 0, W, H + 49);
            
        } completion:^(BOOL finished) {
            
            [self.tabBarController.tabBar setHidden:YES];
        }];
    }

    
    
//    CGFloat height = self.view.frame.size.height;
//    CGFloat contentYoffset = scrollView.contentOffset.y;
//    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
//    NSLog(@"height:%f contentYoffset:%f frame.y:%f",height,contentYoffset,scrollView.frame.origin.y);
//    
//    if (distanceFromBottom < height - 100) {
//        
//        NSLog(@"HHHHHHHHH");
//        
//        // 上拉刷新提示
////        lbTipupLoad.hidden = NO;
//        
//        isDoThisViewRefrensh = YES;
//    }else {
//        // 上拉刷新提示
//        lbTipupLoad.hidden = YES;
//    }
}

// 完成减速,已经停止了
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (isAppearCardView == NO) {
        if (isDoThisViewRefrensh == YES) {
            isDoThisViewRefrensh = NO;
            // 刷新动画
            [self createLoadingForBtnClick];
            if (countForXiaoBiaoTi > pageSize) {
                pageStart = arc4random()%(countForXiaoBiaoTi-pageSize+1);
            }else {
                pageStart = 0;
            }
            // 请求数据
            [self initDataForTuiJianUser];
        }
    }else {
        
        isDoThisViewRefrensh = NO;
    }
}


// 用户拖拽完毕以后
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    
    if (isAppearCardView == YES) {
        // 去拿页面
        backBtn.hidden = NO;
        pageStartForUserCard = 0;
        // 动画
        [self createLoadingForBtnClick];
        // 请求数据
        [self initDataForCard];
    }
    

    CGFloat offset = scrollView.contentOffset.y;
    
    if (offset > -90 && offset < 5) {
        isDoThisViewRefrensh = NO;
    }
    
//    CGFloat height = self.view.frame.size.height;
//    CGFloat contentYoffset = _bigScrollView.contentOffset.y;
//    CGFloat distanceFromBottom = _bigScrollView.contentSize.height - contentYoffset;
//    NSLog(@"height:%f contentYoffset:%f frame.y:%f",height,contentYoffset,_bigScrollView.frame.origin.y);
//    if (distanceFromBottom > height - 100 && distanceFromBottom < height + 10) {
//        
//        isDoThisViewRefrensh = NO;
//    }
}


// 监听处理事件
- (void)listen:(NSNotification *)noti {
    
    NSString *strNoti = noti.object;
    
    // 登录成功
    if ([strNoti isEqualToString:@"90"]) {
        
        // 重新获取数据
        [self initDataForTuiJianUser];
        
        // 销毁用户登录成功的通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginSuccessForFind" object:@"90"];
    }
    
    
    if ([[noti name] isEqualToString:@"reviseBiaoQian"]) {
        // 获取所有已关注标签
        [self getAllBiaoQian];
    }
}


// 页面已经加载
- (void) viewDidAppear:(BOOL)animated {
    
    if (_moreFriendView.frame.origin.y == 0) {
        backBtn.hidden = NO;
    }
}


// 页面将要加载
- (void) viewWillAppear:(BOOL)animated {
    
    NSArray *arr1 = @[@"6",@"5"];
    NSArray *arr2 = @[@"5",@"6"];
    
    if ([arr1 isEqual:arr2]) {
        NSLog(@"%@",@"11111xiangdeng");
    }
    
    
    
    
    
    // 接收消息
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    
    // 登录成功
    [notiCenter addObserver:self selector:@selector(listen:) name:@"loginSuccessForFind" object:@"90"];
    // 对关注的标签进行了修改
    [notiCenter addObserver:self selector:@selector(listen:) name:@"reviseBiaoQian" object:nil];
    
    
    // 其他页面关注和拉黑临时数组
    NSMutableArray *tempArr1 = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserOrBlacklistUser"]];
    NSMutableArray *followAndBlacklistUserMutArr = [[NSMutableArray alloc]init];
    for (NSString *str in tempArr1) {
        if (![followAndBlacklistUserMutArr containsObject:str]) {
            [followAndBlacklistUserMutArr addObject:str];
        }
    }
    // 其他页面取消关注临时数组
    NSMutableArray *tempArr2 = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"CancleFollowUser"]];
    NSMutableArray *cancleFollowUserMutArr = [[NSMutableArray alloc]init];
    for (NSString *str in tempArr2) {
        if (![cancleFollowUserMutArr containsObject:str]) {
            [cancleFollowUserMutArr addObject:str];
        }
    }
    // 其他页面取消拉黑临时数组
    NSMutableArray *tempArr3 = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"RemoveDisLikeUser"]];
    NSMutableArray *removeDisLikeUserMutArr = [[NSMutableArray alloc]init];
    for (NSString *str in tempArr3) {
        if (![removeDisLikeUserMutArr containsObject:str]) {
            [removeDisLikeUserMutArr addObject:str];
        }
    }
    
    if ([UserDefaults valueForKey:@"FollowUserOrBlacklistUser"] != nil && [UserDefaults valueForKey:@"CancleFollowUser"] == nil && [UserDefaults valueForKey:@"RemoveDisLikeUser"] == nil) {
        
        // 刷新推荐用户(仅用于推荐用户数据请求,下面的数据不动)
        [self JustinitDataForTuiJianUser];
    }
    if ([UserDefaults valueForKey:@"FollowUserOrBlacklistUser"] == nil && [UserDefaults valueForKey:@"CancleFollowUser"] != nil && [UserDefaults valueForKey:@"RemoveDisLikeUser"] == nil) {
        
        // 刷新推荐用户(仅用于推荐用户数据请求,下面的数据不动)
        [self JustinitDataForTuiJianUser];
    }
    if ([UserDefaults valueForKey:@"FollowUserOrBlacklistUser"] != nil && [UserDefaults valueForKey:@"CancleFollowUser"] != nil && [UserDefaults valueForKey:@"RemoveDisLikeUser"] == nil) {
        
        if ([followAndBlacklistUserMutArr isEqual:cancleFollowUserMutArr]) {
            // 相当于没操作
        }else {
            // 刷新推荐用户(仅用于推荐用户数据请求,下面的数据不动)
            [self JustinitDataForTuiJianUser];
        }
    }
    if ([UserDefaults valueForKey:@"FollowUserOrBlacklistUser"] != nil && [UserDefaults valueForKey:@"CancleFollowUser"] == nil && [UserDefaults valueForKey:@"RemoveDisLikeUser"] != nil) {
        if ([followAndBlacklistUserMutArr isEqual:removeDisLikeUserMutArr]) {
            // 相当于没操作
        }else {
            // 刷新推荐用户(仅用于推荐用户数据请求,下面的数据不动)
            [self JustinitDataForTuiJianUser];
        }
    }
    if ([UserDefaults valueForKey:@"FollowUserOrBlacklistUser"] == nil && [UserDefaults valueForKey:@"CancleFollowUser"] != nil && [UserDefaults valueForKey:@"RemoveDisLikeUser"] != nil) {
        // 刷新推荐用户(仅用于推荐用户数据请求,下面的数据不动)
        [self JustinitDataForTuiJianUser];
    }
    if ([UserDefaults valueForKey:@"FollowUserOrBlacklistUser"] != nil && [UserDefaults valueForKey:@"CancleFollowUser"] != nil && [UserDefaults valueForKey:@"RemoveDisLikeUser"] != nil) {
        
        NSMutableArray *arrTemp = [NSMutableArray array];
        for (NSString *str in removeDisLikeUserMutArr) {
            if (![arrTemp containsObject:str]) {
                [arrTemp addObject:str];
            }
        }
        for (NSString *str in cancleFollowUserMutArr) {
            if (![arrTemp containsObject:str]) {
                [arrTemp addObject:str];
            }
        }
        if ([arrTemp isEqual:followAndBlacklistUserMutArr]) {
            // 相当于没操作
        }else {
            // 刷新推荐用户(仅用于推荐用户数据请求,下面的数据不动)
            [self JustinitDataForTuiJianUser];
        }
        
    }
        
    
    
    if (_moreFriendView.frame.origin.y == 0) {
        [self.tabBarController.tabBar setHidden:YES];
    }
    
    
//    // 提示上拉刷新数据显示更多好友推荐
//    lbTipupLoad = [[UILabel alloc] init];
//    [self.view addSubview:lbTipupLoad];
//    [lbTipupLoad mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view).with.offset(- 15);
//        make.centerX.equalTo(_bigScrollView);
//    }];
//    lbTipupLoad.font = [UIFont systemFontOfSize:12];
//    lbTipupLoad.attributedText = [self getAttributedStringWithString:@"松手刷新" lineSpace:5];
//    lbTipupLoad.numberOfLines = 0;
//    lbTipupLoad.textAlignment = NSTextAlignmentCenter;
//    lbTipupLoad.textColor = [UIColor whiteColor];
//    lbTipupLoad.hidden = YES;
    
    // 不隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

// 页面将要消失
- (void) viewWillDisappear:(BOOL)animated {
    
    [UserDefaults removeObjectForKey:@"FollowUserOrBlacklistUser"];
    // 其他页面取消关注临时数组
    [UserDefaults removeObjectForKey:@"CancleFollowUser"];
    // 其他页面取消拉黑临时数组
    [UserDefaults removeObjectForKey:@"RemoveDisLikeUser"];
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
