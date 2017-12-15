//
//  MinePostViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/7/28.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "OtherPostViewController.h"
#import "SearchZFPlayerCell.h"
#import "ZFVideoModel.h"
#import "ZFVideoResolution.h"
#import "Masonry/Masonry.h"
//#import <ZFDownload/ZFDownloadManager.h>
#import "ZFPlayer.h"

#import <AudioToolbox/AudioToolbox.h> // 用于设置点击时的震动反馈
#import "SearchDetailTextCell.h" // 文字cell
#import "SearchImgDetailTableViewCell.h" // 图片cell
#import "SearchViewController.h" // 搜索页
#import "DongTaiViewController.h" // 动态

#import "MineViewController.h"

#import "PublishTextViewController.h" // 文字
#import "PublishPhotoViewController.h" // 图片
#import "PublishVideoViewController.h" // 视频

#import "SearchTieZiWithKeyWordModel.h" // 数据模型

#import "XLPhotoBrowser.h" // 大图查看器

#import "PingLunViewController.h" // 评论页面

#define KPraiseBtnWH          30
#define KBorkenTime          0.8f
#define KToBrokenHeartWH    120/195

// 单例
#define USER [NSUserDefaults standardUserDefaults]

@interface OtherPostViewController ()<UITableViewDelegate,UITableViewDataSource,ZFPlayerDelegate,CAAnimationDelegate,UIActionSheetDelegate,UIAlertViewDelegate> {
    
    BOOL _canScroll;
    
    NSInteger pageStart; // 请求数据开始位置
    NSInteger pageSize; // 一页的数量
    
    NSArray *_arrForAllLike; // 所有喜欢
    
    
    NSString *_strCurrentDelId; // 当前要删除的帖子的id
    NSString *_strCurrentDelPaiXu; // 当前要删除的帖子的排序
}

@property (nonatomic, strong) NSMutableArray      *tableViewArr;
//@property (nonatomic, strong) NSMutableArray      *dataSource;
@property (nonatomic, strong) ZFPlayerView        *playerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;

@property (nonatomic, copy) MBProgressHUD *HUD;


@end

@implementation OtherPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 是否可以滚动
    _canScroll = NO;
    
    // 背景色
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 初始化数组
    [self initArr];
    
    // 布局页面
    [self layoutViews];
    
    // 创建动画
    [self createLoadingForBtnClick];
    
    // 请求数据
    [self initData];
}

// 上拉下拉刷新动画
- (void) createLoadingForBtnClick {
    
    // 动画
    _HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 展示
    [_HUD show:YES];
    
}

// 初始化数组
- (void) initArr {
    
    // 初始化
    pageStart = 0;
    pageSize = 10;
    
    // tableViewArr
    _tableViewArr = [NSMutableArray array];
    
    _arrForAllLike = [NSArray array];
}



// 请求数据
- (void)initData {
    
    
    // 数据请求
    HttpRequest *http = [[HttpRequest alloc] init];
    NSArray *arrUserJiaMi = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    
    // 第0页
    if (pageStart == 0) {
        
        NSLog(@"uid::::%@",_userId1);
        NSDictionary *dataDic = @{@"uid":_userId1,@"pageSize":@"10"};
        NSString *strDataJiaMi = [[MakeJson createJson:dataDic] AES128EncryptWithKey:arrUserJiaMi[3]];
        
        NSDictionary *dicDataJiaMi = @{@"tk":arrUserJiaMi[0],@"key":arrUserJiaMi[1],@"cg":arrUserJiaMi[2],@"data":strDataJiaMi};
        // 打印用户请求数据
        NSLog(@"==============:%@",dicDataJiaMi);
        
        
        [http PostGetNoteListByUserForUcenterWithDic:dicDataJiaMi Success:^(id userInfo) {
            
            
            if ([userInfo isKindOfClass:[NSString class]]) {
                
                // 失败
                // 结束动画
                [_HUD hide:YES];
                // 表格刷新完毕,结束上下刷新视图
                [_tableView.mj_footer endRefreshing];
                
            }else {
                
                // 清空数组
                [_tableViewArr removeAllObjects];
                // 成功
                _tableViewArr = [NSMutableArray arrayWithArray:userInfo];
                
                
                // 获取用户所有喜欢的帖子编号
                NSDictionary *dicLikeAllList = @{@"tk":arrUserJiaMi[0],@"key":arrUserJiaMi[1],@"cg":arrUserJiaMi[2]};
                [http PostGetAllLoveNoteIdListWithDic:dicLikeAllList Success:^(id userInfo) {
                    
                    if ([userInfo isEqualToString:@"error"]) {
                        
                        NSLog(@"FNJKDSAFNKDANFJKASNFJKADJFKAS");
                        
                    }else {
                        
                        // 拿到了
                        _arrForAllLike = [userInfo componentsSeparatedByString:@","];
                        
                        NSLog(@"FNJKDSAFNKDANFJKASNFJKADJFKAS:::%@",_arrForAllLike);
                        
                        for (int i = 0; i < _tableViewArr.count; i++) {
                            
                            SearchTieZiWithKeyWordModel *model = _tableViewArr[i];
                            // 判断是否已经喜欢
                            if ([_arrForAllLike containsObject:model.id1]) {
                                model.isLike = @"YES";
                            }else {
                                model.isLike = @"NO";
                            }
                        }
                    }
                    
                    
                    // 结束动画
                    [_HUD hide:YES];
                    // 刷新列表
                    [_tableView reloadData];
                    
                    
                } failure:^(NSError *error) {
                    
                    // 结束动画
                    [_HUD hide:YES];
                    // 刷新列表
                    [_tableView reloadData];
                }];
                
                
            }
            
        } failure:^(NSError *error) {
            
            // 结束动画
            [_HUD hide:YES];
        }];
        
    }else {
        
        SearchTieZiWithKeyWordModel *model = [_tableViewArr lastObject];
        
        NSDictionary *dataDic = @{@"uid":_userId1,@"pageSize":[NSString stringWithFormat:@"%ld",pageSize],@"lastNoteId":model.id1,@"startTime":model.update_time};
        NSString *strDataJiaMi = [[MakeJson createJson:dataDic] AES128EncryptWithKey:arrUserJiaMi[3]];
        
        NSDictionary *dicDataJiaMi = @{@"tk":arrUserJiaMi[0],@"key":arrUserJiaMi[1],@"cg":arrUserJiaMi[2],@"data":strDataJiaMi};
        
        
        // 数据请求
        HttpRequest *http = [[HttpRequest alloc] init];
        [http PostGetNoteListByUserForUcenterWithDic:dicDataJiaMi Success:^(id userInfo) {
            
            if ([userInfo isKindOfClass:[NSString class]]) {
                
                // 结束动画
                [_HUD hide:YES];
                // 失败
                // 表格刷新完毕,结束上下刷新视图
                [_tableView.mj_footer endRefreshing];
                
            }else {
                
                // 成功
                [_tableViewArr addObjectsFromArray:userInfo];
                
                
                // 获取用户所有喜欢的帖子编号
                NSDictionary *dicLikeAllList = @{@"tk":arrUserJiaMi[0],@"key":arrUserJiaMi[1],@"cg":arrUserJiaMi[2]};
                
                NSLog(@"sadbfdsbfsadhbfjhasdbf%@",dicLikeAllList);
                
                [http PostGetAllLoveNoteIdListWithDic:dicLikeAllList Success:^(id userInfo) {
                    
                    
                    if ([userInfo isEqualToString:@"error"]) {
                        
                    }else {
                        
                        // 拿到了
                        _arrForAllLike = [userInfo componentsSeparatedByString:@","];
                        
                        for (int i = 0; i < _tableViewArr.count; i++) {
                            
                            SearchTieZiWithKeyWordModel *model = _tableViewArr[i];
                            // 判断是否已经喜欢
                            if ([_arrForAllLike containsObject:model.id1]) {
                                model.isLike = @"YES";
                            }else {
                                model.isLike = @"NO";
                            }
                        }
                    }
                    
                    // 结束动画
                    [_HUD hide:YES];
                    // 表格刷新完毕,结束上下刷新视图
                    [_tableView.mj_footer endRefreshing];
                    // 刷新列表
                    [_tableView reloadData];
                    
                    
                } failure:^(NSError *error) {
                    
                    // 结束动画
                    [_HUD hide:YES];
                    // 表格刷新完毕,结束上下刷新视图
                    [_tableView.mj_footer endRefreshing];
                    // 刷新列表
                    [_tableView reloadData];
                }];
                
            }
            
        } failure:^(NSError *error) {
            
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [_tableView.mj_footer endRefreshing];
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // 这里设置横竖屏不同颜色的statusbar
    if (ZFPlayerShared.isLandscape) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return ZFPlayerShared.isStatusBarHidden;
}

// 布局页面
- (void) layoutViews {
    
    // 列表
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, W, H - 5 - 20 - W * 0.78125 * 0.13) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
    
    // 继续配置_tableView;
    // 设置_tableView的底部
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 调用上拉刷新方法
        [self upRefresh];
    }];
    
    // 隐藏cell间的分隔线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 379.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

// 上拉刷新方法
- (void)upRefresh {
    
    // 起始位置
    pageStart = _tableViewArr.count;
    
    // 请求数据
    [self initData];
}


#pragma mark - Table view data source
// 返回的分组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// 返回的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _tableViewArr.count;
}

// 绑定数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    SearchTieZiWithKeyWordModel *model = _tableViewArr[indexPath.row];
    
    if ([model.type isEqualToString:@"1"]) {
        
        static NSString *CellIdentifier = @"Cell";
        // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
        SearchImgDetailTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
        if (cell == nil) {
            cell = [[SearchImgDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        // 头像
        [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        // 昵称
        cell.nickNameLb.text = model.nickname;
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
        NSArray *imgandIdArr = model.files;
        // 发布的图片
        [cell.showImgView sd_setImageWithURL:[NSURL URLWithString:[imgandIdArr[0] valueForKey:@"path"]] placeholderImage:[UIImage imageNamed:@""]];
        // 张数
        cell.imgNumLb.text = [NSString stringWithFormat:@"1/%ld",imgandIdArr.count];
        // 内容
        NSLog(@"model.content %@",model.content);
        if (model.content == nil) {
            cell.textLb.text = @"";
        }else {
            cell.textLb.attributedText = [self getAttributedStringWithString:model.content lineSpace:5];
        }
        
        // 右侧操作去掉
        cell.rightBtn.hidden = YES;
        cell.gerenBtn.hidden = YES;
        
        
        // 评论数量
        [cell.pinglunNumBtn setTitle:[NSString stringWithFormat:@"%@ 条评论",model.comment_num] forState:UIControlStateNormal];
        // 动态数量
        [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%@ 动态",model.active_num] forState:UIControlStateNormal];
        
        // 给标签
        NSLog(@"model.kwList:%@",model.kwList);
        NSArray *arrGuanjianCi = [model.kwList componentsSeparatedByString:@","];
        NSLog(@"arrGuanjianCi:%@",arrGuanjianCi);
        [cell giveArrForbiaoqian:arrGuanjianCi andNavIndex:[_strNavIndex integerValue]];
        
        
        
        // 是否已经喜欢
        if ([model.isLike isEqualToString:@"YES"]) {
            cell.praiseBtn.selected = YES;
        }else {
            cell.praiseBtn.selected = NO;
        }
        
        
        // 动态
        cell.dongtaiBtnClick = ^{
            [self dongtaiBtnBy:model];
        };
        // 分享
        cell.shareBtnClick = ^{
            [self shareBtnBy:model];
        };
        // 评论
        cell.pinglunBtnClick = ^{
            [self pinglunBtnBy:model];
        };
        // 展示图点击Block
        cell.showImgViewClick = ^{
            NSMutableArray *arrForImg = [NSMutableArray array];
            for (int i = 0; i < imgandIdArr.count; i++) {
                [arrForImg addObject:[imgandIdArr[i] valueForKey:@"path"]];
            }
            [self showImgViewBy:arrForImg];
        };
        // 喜欢
        cell.LoveButtonClick = ^(){
            [self loveButtonBy:indexPath];
        };
        
        // 选中无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }else if ([model.type isEqualToString:@"0"]) {
        
        static NSString *CellIdentifier = @"Cell";
        // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
        SearchDetailTextCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
        if (cell == nil) {
            cell = [[SearchDetailTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        // 右侧操作去掉
        cell.rightBtn.hidden = YES;
        cell.gerenBtn.hidden = YES;
        
        
        // 头像
        [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        // 昵称
        cell.nickNameLb.text = model.nickname;
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
        // 文字
        if (model.content == nil) {
            cell.lbText.text = @"";
        }else {
            cell.lbText.attributedText = [self getAttributedStringWithString:model.content lineSpace:5];
        }
        // 评论数量
        [cell.pinglunNumBtn setTitle:[NSString stringWithFormat:@"%@ 条评论",model.comment_num] forState:UIControlStateNormal];
        // 动态数量
        [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%@ 动态",model.active_num] forState:UIControlStateNormal];
        
        // 给标签
        NSArray *arrGuanjianCi = [model.kwList componentsSeparatedByString:@","];
        [cell giveArrForbiaoqian:arrGuanjianCi andNavIndex:[_strNavIndex integerValue]];
        
        // 选中无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        // 是否已经喜欢
        if ([model.isLike isEqualToString:@"YES"]) {
            cell.praiseBtn.selected = YES;
        }else {
            cell.praiseBtn.selected = NO;
        }
        
        
        // 动态
        cell.dongtaiBtnClick = ^{
            [self dongtaiBtnBy:model];
        };
        // 分享
        cell.shareBtnClick = ^{
            [self shareBtnBy:model];
        };
        // 评论
        cell.pinglunBtnClick = ^{
            [self pinglunBtnBy:model];
        };
        // 喜欢
        cell.LoveButtonClick = ^(){
            [self loveButtonBy:indexPath];
        };
        
        return cell;
        
    }else {
        
        
        static NSString *CellIdentifier = @"Cell";
        // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
        SearchZFPlayerCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
        if (cell == nil) {
            cell = [[SearchZFPlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // 选中无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // 取到对应cell的model
        __block SearchTieZiWithKeyWordModel *model = _tableViewArr[indexPath.row];
        // 赋值model
        __block NSIndexPath *weakIndexPath = indexPath;
        __block SearchZFPlayerCell *weakCell = cell;
        __weak typeof(self) weakSelf = self;
        
        // 给标签
        NSArray *arrGuanjianCi = [model.kwList componentsSeparatedByString:@","];
        [cell giveArrForbiaoqian:arrGuanjianCi andNavIndex:[_strNavIndex integerValue]];
        
        
        // 头像
        [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
        // 昵称
        cell.nickNameLb.text = model.nickname;
        // 时间label
        cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
        // 文字
        if (model.content == nil) {
            cell.textLb.text = @"";
        }else {
            cell.textLb.attributedText = [self getAttributedStringWithString:model.content lineSpace:5];
        }
        // 评论数量
        [cell.pinglunNumBtn setTitle:[NSString stringWithFormat:@"%@ 条评论",model.comment_num] forState:UIControlStateNormal];
        // 动态数量
        [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%@ 动态",model.active_num] forState:UIControlStateNormal];
        // 等待图
        [cell.picView sd_setImageWithURL:[NSURL URLWithString:[model.files[0] valueForKey:@"path_cover"]]placeholderImage:[UIImage imageNamed:@""]];
        
        // 是否已经喜欢
        if ([model.isLike isEqualToString:@"YES"]) {
            cell.praiseBtn.selected = YES;
        }else {
            cell.praiseBtn.selected = NO;
        }
        
        
        // 动态
        cell.dongtaiBtnClick = ^{
            [self dongtaiBtnBy:model];
        };
        // 分享
        cell.shareBtnClick = ^{
            [self shareBtnBy:model];
        };
        // 评论
        cell.pinglunBtnClick = ^{
            [self pinglunBtnBy:model];
        };
        // 喜欢
        cell.LoveButtonClick = ^(){
            [self loveButtonBy:indexPath];
        };
        
        // 右侧操作去掉
        cell.rightBtn.hidden = YES;
        cell.gerenBtn.hidden = YES;
        
        
        // 点击播放的回调
        cell.playBlock = ^(UIButton *btn){
            
            
            NSArray *arrFiles = model.files;
            NSURL *videoURL = [NSURL URLWithString:[arrFiles[0] valueForKey:@"path"]];
            
            ZFPlayerModel *playerModel = [[ZFPlayerModel alloc] init];
            playerModel.videoURL         = videoURL;
            playerModel.placeholderImageURLString = [arrFiles[0] valueForKey:@"path_cover"];
            playerModel.scrollView       = weakSelf.tableView;
            playerModel.indexPath        = weakIndexPath;
            // player的父视图tag
            playerModel.fatherViewTag    = weakCell.picView.tag;
            
            // 设置播放控制层和model
            [weakSelf.playerView playerControlView:nil playerModel:playerModel];
            // 下载功能
            weakSelf.playerView.hasDownload = NO;
            // 自动播放
            [weakSelf.playerView autoPlayTheVideo];
        };
        
        return cell;
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //    NSLog(@"这是第%ld行",path.row);
    
    if (scrollView.contentOffset.y < 0) {
        
        _canScroll = NO;
        
        // tableView的滚动
        _tableView.scrollEnabled = _canScroll;
        
        // 发送通知,用于修改资料
        // 创建消息中心
        NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
        // 在消息中心发布自己的消息
        [notiCenter postNotificationName:@"xiugaiScrollMine64" object:@"64"];
        // 在消息中心发布自己的消息
        [notiCenter postNotificationName:@"xiugaitableViewScrollForOther66" object:@"66"];
    }
}

// 举报
- (void) jubaoBtnBy:(SearchTieZiWithKeyWordModel *)model {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"举报该帖子"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"色情、政治敏感",@"广告、无聊",@"内容侵权、剽窃",@"其它违规",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
    actionSheet.delegate = self;
    actionSheet.tag = 111;
    
    // 把当前模型加进去
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 存储时直接把最外层数组转成NSData类型
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    [user setValue:data forKey:@"jubaoModel"];
}
// 动态
- (void) dongtaiBtnBy:(SearchTieZiWithKeyWordModel *)model {
    DongTaiViewController * vc = [[DongTaiViewController alloc] init];
    [vc setHidesBottomBarWhenPushed:YES];
    vc.noteId = model.id1;
    [self.navigationController pushViewController:vc animated:YES];
}

// 取消分享点击事件
- (void) cancleBtnClick:(UIButton *)btn {
    [self.zh_popupController dismiss];
}
- (void) jubaoBtnClick:(UIButton *)jubaoBtn {
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    SearchTieZiWithKeyWordModel *model1 = [NSKeyedUnarchiver unarchiveObjectWithData:[user valueForKey:@"jubaoModel"]];
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([model1.uid isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        
        // 自己
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"这是您自己发的帖子哟~"];
        
    }else {
        
        // 不是自己
        // 先消失
        [self.zh_popupController dismiss];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"举报该帖子"
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"色情、政治敏感",@"广告、无聊",@"内容侵权、剽窃",@"其它违规",nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
        
        actionSheet.delegate = self;
        actionSheet.tag = 111;
    }
}
// 添加不喜欢用户
- (void) disLikeBtnClick:(UIButton *)btn {
    
    // 动画
    [self createLoadingForBtnClick];
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    SearchTieZiWithKeyWordModel *model1 = [NSKeyedUnarchiver unarchiveObjectWithData:[user valueForKey:@"jubaoModel"]];
    
    // 获取用户加密相关
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    NSDictionary *dic = @{@"uid":model1.uid};
    NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
    
    NSLog(@"********%@",dicData);
    
    // 进行数据请求
    HttpRequest *http = [[HttpRequest alloc] init];
    // 进行不喜欢数据请求
    [http PostAddDislikeUserWithDic:dicData Success:^(id userInfo) {
        
        [_HUD hide:YES];
        
        if ([userInfo isEqualToString:@"0"]) {
            
            
        }else {
            
            // 先消失弹出框
            [self.zh_popupController dismiss];
            // 提示
            [http GetHttpDefeatAlert:userInfo];
            // 删除用户单例
            [user removeObjectForKey:@"jubaoModel"];
            
            for (int i = 0; i < _tableViewArr.count; i++) {
                SearchTieZiWithKeyWordModel *model = _tableViewArr[i];
                if ([model1.uid isEqualToString:model.uid]) {
                    [_tableViewArr removeObjectAtIndex:i];
                    i --;
                }
            }
            
            [self.tableView reloadData];
            
            
            // 做一个单例 用于修改发现页面的推荐用户
            if ([UserDefaults valueForKey:@"FollowUserOrBlacklistUser"] == nil) {
                NSMutableArray *tempArr = [NSMutableArray array];
                [tempArr addObject:model1.uid];
                [UserDefaults setValue:tempArr forKey:@"FollowUserOrBlacklistUser"];
            }else {
                NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"FollowUserOrBlacklistUser"]];
                [tempArr addObject:model1.uid];
                [UserDefaults setValue:tempArr forKey:@"FollowUserOrBlacklistUser"];
            }
        }
        
    } failure:^(NSError *error) {
        
        [_HUD hide:YES];
    }];
}
// 分享的Block触发的事件
- (void) shareBtnBy:(SearchTieZiWithKeyWordModel *)model {
    
    ShareAndOtherView *vc = [[ShareAndOtherView alloc] initWithFrame:CGRectMake(0, 0, W, 309)];
    [vc.cancleBtn addTarget:self action:@selector(cancleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [vc.jubaoBtn addTarget:self action:@selector(jubaoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [vc.disLikeBtn addTarget:self action:@selector(disLikeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.zh_popupController = [zhPopupController new];
    self.zh_popupController.layoutType = zhPopupLayoutTypeBottom;
    [self.zh_popupController presentContentView:vc];
    
    
    // 把当前模型加进去
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 存储时直接把最外层数组转成NSData类型
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    [user setValue:data forKey:@"jubaoModel"];
}
// 评论的block
- (void) pinglunBtnBy:(SearchTieZiWithKeyWordModel *)model {
    PingLunViewController *vc = [[PingLunViewController alloc] init];
    [vc setHidesBottomBarWhenPushed:YES];
    vc.targetUid = model.uid;
    vc.noteId = model.id1;
    [self.navigationController pushViewController:vc animated:YES];
}
// 展示图片点击
- (void) showImgViewBy:(NSArray *)imgArr {
    [XLPhotoBrowser showPhotoBrowserWithImages:imgArr currentImageIndex:0];
}
// 右侧按钮的Block触发事件
- (void) rightButtonBy:(NSIndexPath *)indexPath {
    
    // 拿到模型数据
    SearchTieZiWithKeyWordModel *model = _tableViewArr[indexPath.row];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"操作"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"修改本条帖子",@"删除本条帖子",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
    actionSheet.delegate = self;
    actionSheet.tag = 222;
    
    // 当前要删除的帖子的id
    _strCurrentDelId = model.id1;
    // 当前要删除的帖子的排序
    _strCurrentDelPaiXu = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    // 把当前模型加进去
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 存储时直接把最外层数组转成NSData类型
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    [user setValue:data forKey:@"rightBtnModel"];
}

// 点击事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 222) {
        // 右侧点击
        if (buttonIndex == 0) {
            
            // 用户单例
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            SearchTieZiWithKeyWordModel *model1 = [NSKeyedUnarchiver unarchiveObjectWithData:[user valueForKey:@"rightBtnModel"]];
            
            if ([model1.type isEqualToString:@"0"]) {
                // 纯文字
                // 跳转  传过去参数
                PublishTextViewController *vc = [[PublishTextViewController alloc] init];
                vc.model = model1;
                [self presentViewController:vc animated:YES completion:nil];
            }else if ([model1.type isEqualToString:@"1"]){
                // 图片
                // 跳转到修改页面  传过去参数
                PublishPhotoViewController *vc = [[PublishPhotoViewController alloc] init];
                vc.model = model1;
                [self presentViewController:vc animated:YES completion:nil];
            }else {
                // 视频
                PublishVideoViewController *vc = [[PublishVideoViewController alloc] init];
                vc.model = model1;
                [self presentViewController:vc animated:YES completion:nil];
            }
            
            // 删除用户单例
            [user removeObjectForKey:@"rightBtnModel"];
            
            
        }else if (buttonIndex == 1) {
            
            // 图片
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"帖子删除后不可恢复,是否删除" delegate:self cancelButtonTitle:@"删除" otherButtonTitles:@"取消", nil];
            alert.delegate = self;
            alert.tag = 321;
            [alert show];
            
        }else {
            // 取消
            NSLog(@"点击了取消");
            _strCurrentDelId = @"";
            _strCurrentDelPaiXu = @"";
        }
    }
    
    
    if (actionSheet.tag == 111) {
        // 用户单例
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        SearchTieZiWithKeyWordModel *model1 = [NSKeyedUnarchiver unarchiveObjectWithData:[user valueForKey:@"jubaoModel"]];
        NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
        HttpRequest *http = [[HttpRequest alloc] init];
        
        if (buttonIndex == 0) {
            
            NSDictionary *dicForData = @{@"noteId":model1.id1,@"type":@"1",@"content":@""};
            NSString *strData = [[MakeJson createJson:dicForData] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dic = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            [http PostAccusationNoteWithDic:dic Success:^(id userInfo) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            } failure:^(NSError *error) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            }];
            
        }else if (buttonIndex == 1) {
            
            NSDictionary *dicForData = @{@"noteId":model1.id1,@"type":@"2",@"content":@""};
            NSString *strData = [[MakeJson createJson:dicForData] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dic = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            [http PostAccusationNoteWithDic:dic Success:^(id userInfo) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            } failure:^(NSError *error) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            }];
            
        }else if (buttonIndex == 2){
            
            NSDictionary *dicForData = @{@"noteId":model1.id1,@"type":@"3",@"content":@""};
            NSString *strData = [[MakeJson createJson:dicForData] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dic = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            [http PostAccusationNoteWithDic:dic Success:^(id userInfo) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            } failure:^(NSError *error) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            }];
            
        }else if (buttonIndex == 3) {
            
            NSDictionary *dicForData = @{@"noteId":model1.id1,@"type":@"0",@"content":@""};
            NSString *strData = [[MakeJson createJson:dicForData] AES128EncryptWithKey:userJiaMiArr[3]];
            NSDictionary *dic = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
            [http PostAccusationNoteWithDic:dic Success:^(id userInfo) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            } failure:^(NSError *error) {
                // 删除用户单例
                [user removeObjectForKey:@"jubaoModel"];
            }];
            
        }else {
            // 取消
            NSLog(@"点击了取消");
        }
    }
}

// 弹出代理事件
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 321) {
        if (buttonIndex == 0) {
            
            // 创建动画
            [self createLoadingForBtnClick];
            // 0.5秒后，执行删除
            [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(DelTieZiEvent) userInfo:nil repeats:NO];
            
        }else {
            NSLog(@"没删除");
        }
    }
}

// 删除帖子操作
- (void) DelTieZiEvent {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 获取用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    NSDictionary *dic = @{@"id":_strCurrentDelId};
    NSLog(@"_strCurrentDelId::%@",_strCurrentDelId);
    NSString *strData = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSLog(@"strData::::::%@",strData);
    
    NSDictionary *dicForData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strData};
    NSLog(@"dicForData:::::::%@",dicForData);
    [http PostDelNoteWithDic:dicForData Success:^(id userInfo) {
        
        // 请求成功
        if ([userInfo isEqualToString:@"0"]) {
            // 删除失败
            // 结束动画
            [_HUD hide:YES];
        }else {
            
            
            // 结束动画
            [_HUD hide:YES];
            // 删除成功
            [MBHUDView hudWithBody:@"删除成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
            
            // 做一个单例 用于删除首页数据
            if ([UserDefaults valueForKey:@"DelTieZiForShouYe"] == nil) {
                NSMutableArray *tempArr = [NSMutableArray array];
                [tempArr addObject:_strCurrentDelId];
                [UserDefaults setValue:tempArr forKey:@"DelTieZiForShouYe"];
            }else {
                NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelTieZiForShouYe"]];
                [tempArr addObject:_strCurrentDelId];
                [UserDefaults setValue:tempArr forKey:@"DelTieZiForShouYe"];
            }
            
            // 做一个单例 用于删除首页数据
            if ([UserDefaults valueForKey:@"DelTieZiForMine"] == nil) {
                NSMutableArray *tempArr = [NSMutableArray array];
                [tempArr addObject:_strCurrentDelId];
                [UserDefaults setValue:tempArr forKey:@"DelTieZiForMine"];
            }else {
                NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelTieZiForMine"]];
                [tempArr addObject:_strCurrentDelId];
                [UserDefaults setValue:tempArr forKey:@"DelTieZiForMine"];
            }
            
            // 从当前数组删除这一条，并刷新列表
            SearchTieZiWithKeyWordModel *model = _tableViewArr[[_strCurrentDelPaiXu integerValue]];
            [_tableViewArr removeObject:model];
            [_tableView reloadData];
        }
        
        
        _strCurrentDelId = @"";
        _strCurrentDelPaiXu = @"";
        
    } failure:^(NSError *error) {
        
        // 结束动画
        [_HUD hide:YES];
        // 请求失败
        _strCurrentDelId = @"";
        _strCurrentDelPaiXu = @"";
    }];
}

// 喜欢按钮的Block触发事件
- (void)loveButtonBy:(NSIndexPath*)indexPath {
    
    // 数据请求对象
    HttpRequest *http = [[HttpRequest alloc] init];
    // 用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    
    // 点击时候的震动反馈
    AudioServicesPlaySystemSound(1519);
    
    // 拿到模型
    SearchTieZiWithKeyWordModel *model = _tableViewArr[indexPath.row];
    
    // 喜欢动画设置
    [self playAnimation:indexPath];
    
    
    NSDictionary *idDic = @{@"noteId":model.id1};
    NSString *dataStr = [[MakeJson createJson:idDic] AES128EncryptWithKey:userJiaMiArr[3]];
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStr};
    NSLog(@"ertyuiodfghjkxbnm%@",dicData);
    
    
    // 原始的动态数
    //    NSInteger activeNum = [model.active_num integerValue];
    
    
    // 修改状态
    if ([model.type isEqualToString:@"1"]) {
        SearchImgDetailTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        cell.praiseBtn.userInteractionEnabled = NO;
        if (cell.praiseBtn.selected == NO) {
            //            // 修改动态数
            //            [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%ld 动态",activeNum+1] forState:UIControlStateNormal];
            //            // 改变数据模型
            //            [model setValue:[NSString stringWithFormat:@"%ld",activeNum+1] forKey:@"active_num"];
            // 进行喜欢数据请求
            [http PostAddLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"喜欢帖子失败");
                }else {
                    NSLog(@"喜欢帖子成功");
                    model.isLike = @"YES";
                    
                    // 做一个单例 喜欢帖子对首页的影响
                    if ([UserDefaults valueForKey:@"LoveTieZiForReviseHome"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseHome"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"LoveTieZiForReviseHome"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseHome"];
                    }
                    
                    // 做一个单例 喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"LoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"LoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }else {
            //            // 修改动态数
            //            [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%ld 动态",activeNum-1] forState:UIControlStateNormal];
            //            // 改变数据模型
            //            [model setValue:[NSString stringWithFormat:@"%ld",activeNum-1] forKey:@"active_num"];
            // 进行喜欢数据请求
            [http PostDelLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"删除喜欢帖子失败");
                }else {
                    NSLog(@"删除喜欢帖子成功");
                    model.isLike = @"NO";
                    
                    // 做一个单例 取消喜欢帖子对首页的影响
                    if ([UserDefaults valueForKey:@"DelLoveTieZiForReviseHome"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseHome"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelLoveTieZiForReviseHome"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseHome"];
                    }
                    
                    // 做一个单例 取消喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }
        cell.praiseBtn.selected = !cell.praiseBtn.selected;
        
    }else if ([model.type isEqualToString:@"0"]) {
        SearchDetailTextCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        cell.praiseBtn.userInteractionEnabled = NO;
        if (cell.praiseBtn.selected == NO) {
            //            // 修改动态数
            //            [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%ld 动态",activeNum+1] forState:UIControlStateNormal];
            //            // 改变数据模型
            //            [model setValue:[NSString stringWithFormat:@"%ld",activeNum+1] forKey:@"active_num"];
            // 进行喜欢数据请求
            [http PostAddLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"喜欢帖子失败");
                }else {
                    NSLog(@"喜欢帖子成功");
                    model.isLike = @"YES";
                    
                    // 做一个单例 喜欢帖子对首页的影响
                    if ([UserDefaults valueForKey:@"LoveTieZiForReviseHome"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseHome"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"LoveTieZiForReviseHome"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseHome"];
                    }
                    
                    // 做一个单例 喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"LoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"LoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }else {
            //            // 修改动态数
            //            [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%ld 动态",activeNum-1] forState:UIControlStateNormal];
            //            // 改变数据模型
            //            [model setValue:[NSString stringWithFormat:@"%ld",activeNum-1] forKey:@"active_num"];
            // 进行喜欢数据请求
            [http PostDelLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"删除喜欢帖子失败");
                }else {
                    NSLog(@"删除喜欢帖子成功");
                    model.isLike = @"NO";
                    
                    // 做一个单例 取消喜欢帖子对首页的影响
                    if ([UserDefaults valueForKey:@"DelLoveTieZiForReviseHome"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseHome"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelLoveTieZiForReviseHome"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseHome"];
                    }
                    
                    // 做一个单例 取消喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }
        cell.praiseBtn.selected = !cell.praiseBtn.selected;
    }else {
        SearchZFPlayerCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        cell.praiseBtn.userInteractionEnabled = NO;
        if (cell.praiseBtn.selected == NO) {
            //            // 修改动态数
            //            [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%ld 动态",activeNum+1] forState:UIControlStateNormal];
            //            // 改变数据模型
            //            [model setValue:[NSString stringWithFormat:@"%ld",activeNum+1] forKey:@"active_num"];
            // 进行喜欢数据请求
            [http PostAddLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"喜欢帖子失败");
                }else {
                    NSLog(@"喜欢帖子成功");
                    model.isLike = @"YES";
                    
                    // 做一个单例 喜欢帖子对首页的影响
                    if ([UserDefaults valueForKey:@"LoveTieZiForReviseHome"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseHome"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"LoveTieZiForReviseHome"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseHome"];
                    }
                    
                    // 做一个单例 喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"LoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"LoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"LoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }else {
            //            // 修改动态数
            //            [cell.dongtaiBtn setTitle:[NSString stringWithFormat:@"%ld 动态",activeNum-1] forState:UIControlStateNormal];
            //            // 改变数据模型
            //            [model setValue:[NSString stringWithFormat:@"%ld",activeNum-1] forKey:@"active_num"];
            // 进行喜欢数据请求
            [http PostDelLoveNoteWithDic:dicData Success:^(id userInfo) {
                // 数据请求成功
                if ([userInfo isEqualToString:@"0"]) {
                    NSLog(@"删除喜欢帖子失败");
                }else {
                    NSLog(@"删除喜欢帖子成功");
                    model.isLike = @"NO";
                    
                    // 做一个单例 取消喜欢帖子对首页的影响
                    if ([UserDefaults valueForKey:@"DelLoveTieZiForReviseHome"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseHome"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelLoveTieZiForReviseHome"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseHome"];
                    }
                    
                    // 做一个单例 取消喜欢帖子对我的页面的影响
                    if ([UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"] == nil) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }else {
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[UserDefaults valueForKey:@"DelLoveTieZiForReviseMine"]];
                        [tempArr addObject:model.id1];
                        [UserDefaults setValue:tempArr forKey:@"DelLoveTieZiForReviseMine"];
                    }
                }
            } failure:^(NSError *error) {
                // 数据请求失败
            }];
        }
        cell.praiseBtn.selected = !cell.praiseBtn.selected;
    }
}

-(void)playAnimation:(NSIndexPath*)indexpath{
    
    // 拿到模型
    SearchTieZiWithKeyWordModel *model = _tableViewArr[indexpath.row];
    
    // 原始的动态数
    NSInteger activeNum = [model.active_num integerValue];
    
    if ([model.type isEqualToString:@"1"]) {
        SearchImgDetailTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section]];
        if (!cell.praiseBtn.selected) {
            cell.coverBtn.alpha = 1;
            [UIView animateWithDuration:1.0f animations:^{
                cell.coverBtn.frame = CGRectMake(cell.praiseBtn.frame.origin.x, cell.praiseBtn.frame.origin.y-70, KPraiseBtnWH*2, KPraiseBtnWH*2);
                
                CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
                NSValue *value1 = [NSNumber numberWithFloat:-M_PI/180*5];
                NSValue *value2 = [NSNumber numberWithFloat:M_PI/180*5];
                NSValue *value3 = [NSNumber numberWithFloat:-M_PI/180*5];
                anima.values = @[value1,value2,value3];
                anima.repeatCount = MAXFLOAT;
                [cell.coverBtn.layer addAnimation:anima forKey:nil];
                
                cell.coverBtn.alpha = 0;
                cell.coverBtn.centerX = cell.praiseBtn.centerX;
            } completion:^(BOOL finished) {
                cell.coverBtn.frame = cell.praiseBtn.frame;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
            
            // 改变数据模型
            [model setValue:[NSString stringWithFormat:@"%ld",activeNum+1] forKey:@"active_num"];
            // 刷新某一行
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
            
        } else {
            cell.cancelPraiseImg.hidden = NO;
            NSArray *imgArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"icon_like_broken1"],[UIImage imageNamed:@"icon_like_broken2"],[UIImage imageNamed:@"icon_like_broken3"],[UIImage imageNamed:@"icon_like_broken4"], nil];
            cell.cancelPraiseImg.animationImages = imgArr;
            cell.cancelPraiseImg.animationDuration = KBorkenTime;
            cell.cancelPraiseImg.animationRepeatCount = 1;
            [cell.cancelPraiseImg startAnimating];
            
            [UIView animateWithDuration:KBorkenTime animations:^{
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 0;
            }completion:^(BOOL finished) {
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y-40, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 1;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
            
            // 改变数据模型
            [model setValue:[NSString stringWithFormat:@"%ld",activeNum-1] forKey:@"active_num"];
            // 刷新某一行
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
            
        }
    }else if ([model.type isEqualToString:@"0"]) {
        SearchDetailTextCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section]];
        if (!cell.praiseBtn.selected) {
            cell.coverBtn.alpha = 1;
            [UIView animateWithDuration:1.0f animations:^{
                cell.coverBtn.frame = CGRectMake(cell.praiseBtn.frame.origin.x, cell.praiseBtn.frame.origin.y-70, KPraiseBtnWH*2, KPraiseBtnWH*2);
                
                CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
                NSValue *value1 = [NSNumber numberWithFloat:-M_PI/180*5];
                NSValue *value2 = [NSNumber numberWithFloat:M_PI/180*5];
                NSValue *value3 = [NSNumber numberWithFloat:-M_PI/180*5];
                anima.values = @[value1,value2,value3];
                anima.repeatCount = MAXFLOAT;
                [cell.coverBtn.layer addAnimation:anima forKey:nil];
                
                cell.coverBtn.alpha = 0;
                cell.coverBtn.centerX = cell.praiseBtn.centerX;
            } completion:^(BOOL finished) {
                cell.coverBtn.frame = cell.praiseBtn.frame;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
//            // 改变数据模型
//            [model setValue:[NSString stringWithFormat:@"%ld",activeNum+1] forKey:@"active_num"];
//            // 刷新某一行
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
            
        } else {
            cell.cancelPraiseImg.hidden = NO;
            NSArray *imgArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"icon_like_broken1"],[UIImage imageNamed:@"icon_like_broken2"],[UIImage imageNamed:@"icon_like_broken3"],[UIImage imageNamed:@"icon_like_broken4"], nil];
            cell.cancelPraiseImg.animationImages = imgArr;
            cell.cancelPraiseImg.animationDuration = KBorkenTime;
            cell.cancelPraiseImg.animationRepeatCount = 1;
            [cell.cancelPraiseImg startAnimating];
            
            [UIView animateWithDuration:KBorkenTime animations:^{
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 0;
            }completion:^(BOOL finished) {
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y-40, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 1;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
            // 改变数据模型
//            [model setValue:[NSString stringWithFormat:@"%ld",activeNum-1] forKey:@"active_num"];
//            // 刷新某一行
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
            
        }
        
    }else {
        
        SearchZFPlayerCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section]];
        if (!cell.praiseBtn.selected) {
            cell.coverBtn.alpha = 1;
            [UIView animateWithDuration:1.0f animations:^{
                cell.coverBtn.frame = CGRectMake(cell.praiseBtn.frame.origin.x, cell.praiseBtn.frame.origin.y-70, KPraiseBtnWH*2, KPraiseBtnWH*2);
                
                CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
                NSValue *value1 = [NSNumber numberWithFloat:-M_PI/180*5];
                NSValue *value2 = [NSNumber numberWithFloat:M_PI/180*5];
                NSValue *value3 = [NSNumber numberWithFloat:-M_PI/180*5];
                anima.values = @[value1,value2,value3];
                anima.repeatCount = MAXFLOAT;
                [cell.coverBtn.layer addAnimation:anima forKey:nil];
                
                cell.coverBtn.alpha = 0;
                cell.coverBtn.centerX = cell.praiseBtn.centerX;
            } completion:^(BOOL finished) {
                cell.coverBtn.frame = cell.praiseBtn.frame;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
            
            // 改变数据模型
            [model setValue:[NSString stringWithFormat:@"%ld",activeNum+1] forKey:@"active_num"];
            // 刷新某一行
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
            
        } else {
            cell.cancelPraiseImg.hidden = NO;
            NSArray *imgArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"icon_like_broken1"],[UIImage imageNamed:@"icon_like_broken2"],[UIImage imageNamed:@"icon_like_broken3"],[UIImage imageNamed:@"icon_like_broken4"], nil];
            cell.cancelPraiseImg.animationImages = imgArr;
            cell.cancelPraiseImg.animationDuration = KBorkenTime;
            cell.cancelPraiseImg.animationRepeatCount = 1;
            [cell.cancelPraiseImg startAnimating];
            
            [UIView animateWithDuration:KBorkenTime animations:^{
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 0;
            }completion:^(BOOL finished) {
                cell.cancelPraiseImg.frame = CGRectMake(cell.praiseBtn.frame.origin.x-15, cell.praiseBtn.frame.origin.y-40, KPraiseBtnWH*2, KPraiseBtnWH*2*KToBrokenHeartWH);
                cell.cancelPraiseImg.alpha = 1;
                cell.praiseBtn.userInteractionEnabled = YES;
            }];
            
            // 改变数据模型
            [model setValue:[NSString stringWithFormat:@"%ld",activeNum-1] forKey:@"active_num"];
            // 刷新某一行
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section], nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
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

// tableView的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 打印当前行
    NSLog(@"didSelectRowAtIndexPath---%zd",indexPath.row);
}


- (ZFPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [ZFPlayerView sharedPlayerView];
        _playerView.delegate = self;
        
        // 当cell播放视频由全屏变为小屏时候，不回到中间位置
        _playerView.cellPlayerOnCenter = NO;
        // 当cell划出屏幕的时候停止播放
        _playerView.stopPlayWhileCellNotVisable = YES;
        //（可选设置）可以设置视频的填充模式，默认为（等比例填充，直到一个维度到达区域边界）
        //         _playerView.playerLayerGravity = ZFPlayerLayerGravityResizeAspect;
        // 静音
        _playerView.mute = NO;
    }
    
    return _playerView;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [[ZFPlayerControlView alloc] init];
    }
    return _controlView;
}

#pragma mark - ZFPlayerDelegate

//- (void)zf_playerDownload:(NSString *)url {
//    // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
//    NSString *name = [url lastPathComponent];
//    [[ZFDownloadManager sharedDownloadManager] downFileUrl:url filename:name fileimage:nil];
//    // 设置最多同时下载个数（默认是3）
//    [ZFDownloadManager sharedDownloadManager].maxCount = 4;
//}


// 监听处理事件
- (void)listen:(NSNotification *)noti {
    
    NSString *strNoti = noti.object;
    
    
    // 用于修改tableView的滚动
    if ([strNoti isEqualToString:@"61"]) {
        
        _canScroll = YES;
        
        // 重新获取用户资料数据
        _tableView.scrollEnabled = _canScroll;
        
        
        // 创建消息中心
        NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
        // 在消息中心发布自己的消息
        [notiCenter postNotificationName:@"xiugaiScrollMineNo65" object:@"65"];
    }
    
    if ([strNoti isEqualToString:@"67"]) {
        
        _canScroll = NO;
        
        [_tableView setContentOffset:CGPointMake(0,0) animated:NO];
        
        // 重新获取用户资料数据
        _tableView.scrollEnabled = _canScroll;
    }
    
    if ([strNoti isEqualToString:@"68"]) {
        
        _canScroll = NO;
        
        [_tableView setContentOffset:CGPointMake(0,0) animated:NO];
        
        // 重新获取用户资料数据
        _tableView.scrollEnabled = _canScroll;
    }
    
    // 修改成功
    if ([strNoti isEqualToString:@"6666"]) {
        
        NSDictionary *dicForAfter = noti.userInfo;
        
        for (int i = 0; i < _tableViewArr.count; i++) {
            SearchTieZiWithKeyWordModel *tempModel = _tableViewArr[i];
            if ([tempModel.id1 isEqualToString:[dicForAfter valueForKey:@"id"]]) {
                
                tempModel.content = [dicForAfter valueForKey:@"content"];
                tempModel.private_flag = [dicForAfter valueForKey:@"privateFlag"];
                tempModel.kwList = [dicForAfter valueForKey:@"keywords"];
            }
        }
        
        [self.tableView reloadData];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    
    self.tableView.contentOffset = CGPointMake(0, -1);
}

// 页面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    // 接收消息
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    // 侧栏退出
    [notiCenter addObserver:self selector:@selector(listen:) name:@"xiugaiScroll61" object:@"61"];
    // 侧栏退出
    [notiCenter addObserver:self selector:@selector(listen:) name:@"xiugaitableViewScrollForOther67" object:@"67"];
    // 修改滚动
    [notiCenter addObserver:self selector:@selector(listen:) name:@"xiugaitableViewScrollForOther68" object:@"68"];
    // 修改帖子成功
    [notiCenter addObserver:self selector:@selector(listen:) name:@"reviseTieZiSuccess" object:@"6666"];
}

// 页面消失时候
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.playerView resetPlayer];
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
