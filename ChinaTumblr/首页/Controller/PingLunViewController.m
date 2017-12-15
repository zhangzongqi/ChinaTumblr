//
//  PingLunViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/10.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "PingLunViewController.h"
#import "PingLunCell.h" // 评论cell
#import "pinglunModel.h" // 评论Model
#import "OtherMineViewController.h"

@interface PingLunViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
    
    NSInteger pageStart; // 请求数据开始位置
    NSInteger pageSize; // 一页的数量
    
    NSMutableDictionary *_dicData; // 最终发表评论时需要的加密数据

    
    // 顶级评论编号
    NSString *_strRootId;
    // 被回复评论编号
    NSString *_strPid;
    // 评论内容
    NSString *_content;
    // 被回复人编号
    NSString *_strTargetUid;
}

@property (nonatomic, strong) NSMutableArray *tableViewArr;
// tableView
@property (nonatomic, copy)UITableView *tableView;

@property (nonatomic, copy) MBProgressHUD *HUD; // 动画

// 底部视图
@property (nonatomic, copy) UIView *bottomView;

// 评论框
@property (nonatomic, copy) UITextField *tf;

@end

@implementation PingLunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置导航栏标题
    UILabel *lbItemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    lbItemTitle.text = @"评论";
    lbItemTitle.textColor = FUIColorFromRGB(0x212121);
    lbItemTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = lbItemTitle;
    
    
    // 初始化数组
    [self initArr];
    
    // 布局TableView
    [self createTbv];
    
    // 请求数据
    [self initData];
}

// 初始化数组
- (void) initArr {
    
    
    _strTargetUid = _targetUid;
    _strPid = @"0";
    _strRootId = @"0";
    
    // 初始化
    pageStart = 0;
    pageSize = 10;
    
    // tableViewArr
    _tableViewArr = [NSMutableArray array];
    
    // dataDic数据
    _dicData = [NSMutableDictionary dictionary];
    
    
    // 在本页面始终不会改变,帖子id
    [_dicData setValue:_noteId forKey:@"noteId"];
}

// 请求数据
- (void)initData {
    
    // 数据请求
    HttpRequest *http = [[HttpRequest alloc] init];
    
    // 第0页
    if (pageStart == 0) {
        
        [http GetCommentListWithnoteId:_noteId andpageStart:[NSString stringWithFormat:@"%ld",pageStart] andpageSize:[NSString stringWithFormat:@"%ld",pageSize] Success:^(id userInfo) {
            
            
            if ([userInfo isKindOfClass:[NSString class]]) {
                // 获取失败
                // 提示消息
                [http GetHttpDefeatAlert:userInfo];
            }else {
                // 清空数组
                [_tableViewArr removeAllObjects];
                
                NSInteger count = [userInfo count] - 1;
                
                for (int i = 0; i < [userInfo count]; i++) {
                    
                    [_tableViewArr addObject:userInfo[count]];
                    
                    count -- ;
                }
            }
            
            // 刷新列表
            [self.tableView reloadData];
            // 让tableView滚动到最后一行
            [self scrollToTableBottom];
            
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            
        } failure:^(NSError *error) {
            
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
        }];
        
    }else {
        
        
        [http GetCommentListWithnoteId:_noteId andpageStart:[NSString stringWithFormat:@"%ld",pageStart] andpageSize:[NSString stringWithFormat:@"%ld",pageSize] Success:^(id userInfo) {
            
            if ([userInfo isKindOfClass:[NSString class]]) {
                // 获取失败
                [http GetHttpDefeatAlert:userInfo];
                
            }else {
                
                // 成功
                for (int i = 0; i < [userInfo count]; i++) {
                    
                    [_tableViewArr insertObject:userInfo[i] atIndex:0];
                }
                // 刷新列表
                [self.tableView reloadData];
                
                
                if ([userInfo count] == 0) {
                    
                    // 没有拿到更多数据
                    
                }else {
                    
                    // 拿到了更多数据,滚动到拿到的数据那一行
                    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:[userInfo count] inSection:0];
                    [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            }
            
            
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            
        } failure:^(NSError *error) {
            
            // 结束动画
            [_HUD hide:YES];
            // 表格刷新完毕,结束上下刷新视图
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
        }];
        
    }
}

// 滚动到最后一行
- (void)scrollToTableBottom {
    
    NSInteger lastRow = self.tableViewArr.count - 1;
    
    if (lastRow < 0) return;
    
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// 布局tableView
- (void) createTbv {
    
    // 导航栏分隔线
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, W, 0.5)];
    [self.view addSubview:lb];
    lb.backgroundColor = FUIColorFromRGB(0xeeeeee);
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0.5, W, H - 64.5 - 55 - 150) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // 隐藏掉分隔线
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 隐藏多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
//    [_tableView registerClass:[PingLunCell class] forCellReuseIdentifier:@"cell"];
    
    // 隐藏cell间的分隔线
    self.tableView.estimatedRowHeight = 100.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // 继续配置_tableView;
    // 创建一个下拉刷新的头
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 调用下拉刷新方法
        [self downRefresh];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    // 设置_tableView的顶头
    self.tableView.mj_header = header;
    
    
    UILabel *lbDeSe = [[UILabel alloc] init];
    [self.view addSubview:lbDeSe];
    [lbDeSe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_tableView.mas_bottom).with.offset(70);
    }];
    lbDeSe.text = @"嘚瑟出你的想法~";
    lbDeSe.textColor = FUIColorFromRGB(0x4e4e4e);
    lbDeSe.font = [UIFont systemFontOfSize:15];
    
    
    // 底部视图
    _bottomView = [[UIView alloc] init];
    [self.view addSubview:_bottomView];
    _bottomView.frame = CGRectMake(0, H - 64 - 49, W, 49);
    _bottomView.backgroundColor = FUIColorFromRGB(0xffffff);
    // 底部分隔线
    UILabel *lbFenge = [[UILabel alloc] init];
    [_bottomView addSubview:lbFenge];
    [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bottomView);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(1));
    }];
    lbFenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
    // 评论图标
    UIImageView *bottomImgView = [[UIImageView alloc] init];
    [_bottomView addSubview:bottomImgView];
    [bottomImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_bottomView);
        make.left.equalTo(_bottomView).with.offset(15);
        make.height.equalTo(@(20));
        make.width.equalTo(@(20));
    }];
    bottomImgView.image = [UIImage imageNamed:@"review_icon1"];
    // 评论框
    _tf = [[UITextField alloc] init];
    [_bottomView addSubview:_tf];
    [_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomImgView.mas_right).with.offset(10);
        make.centerY.equalTo(_bottomView);
        make.width.equalTo(@(W - 35 - 71 - 10));
    }];
    _tf.placeholder = @"说点什么吧...";
    _tf.font = [UIFont systemFontOfSize:14];
    self.tf.delegate = self;

    // 添加通知监听见键盘弹出/退出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction1:) name:UIKeyboardWillShowNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillChangeFrameNotification object:nil];//在这里注册通知

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction2:) name:UIKeyboardWillHideNotification object:nil];
    
    
    
    // 发表评论按钮
    UIButton *fabiaoPingLunBtn = [[UIButton alloc] init];
    [_bottomView addSubview:fabiaoPingLunBtn];
    [fabiaoPingLunBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_bottomView);
        make.right.equalTo(_bottomView).with.offset(-10);
    }];
    [fabiaoPingLunBtn setTitle:@"发表评论" forState:UIControlStateNormal];
    [fabiaoPingLunBtn setTitleColor:FUIColorFromRGB(0xfeaa0a) forState:UIControlStateNormal];
    fabiaoPingLunBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [fabiaoPingLunBtn addTarget:self action:@selector(fabiaoPingLunBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

// 下拉刷新方法
- (void)downRefresh {
    
    // 起始位置
    pageStart = _tableViewArr.count;
    
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


// 点击非TextField区域取消第一响应者
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    [self.tf resignFirstResponder];
    
    self.tf.placeholder = @"说点什么吧...";
    _strRootId = @"0";
    _strPid = @"0";
    _strTargetUid = _targetUid;
    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.tf resignFirstResponder];
}


// 键盘监听事件
- (void)keyboardAction1:(NSNotification*)sender{
    
        // 通过通知对象获取键盘frame: [value CGRectValue]
        NSDictionary *userInfo = [sender userInfo];
        
        CGRect beginKeyboardRect = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect endKeyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGFloat yOffset = endKeyboardRect.origin.y - beginKeyboardRect.origin.y;
        
        _bottomView.center = CGPointMake(_bottomView.center.x, _bottomView.center.y + yOffset);
        
}

// 键盘监听事件
- (void)keyboardAction2:(NSNotification*)sender{
    
    // 通过通知对象获取键盘frame: [value CGRectValue]
    NSDictionary *userInfo = [sender userInfo];
    
    CGRect beginKeyboardRect = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endKeyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat yOffset = endKeyboardRect.origin.y - beginKeyboardRect.origin.y;
    
    
    _bottomView.center = CGPointMake(_bottomView.center.x, _bottomView.center.y + yOffset);
}




// 发表评论的点击事件
- (void) fabiaoPingLunBtnClick:(UIButton *)fabiaoPingLunBtn {
    
    // 释放第一响应者
    [self.tf resignFirstResponder];
    
    // 回复的内容
    _content = self.tf.text;
    
    // 禁用用户交互
    fabiaoPingLunBtn.userInteractionEnabled = NO;
    
    NSLog(@"评论点击");
    
    // 用户加密相关
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    
    // 回复的内容
    [_dicData setValue:_content forKey:@"content"];
    
    // 回复的人的Id
    [_dicData setValue:_strPid forKey:@"pid"];
    // 回复的人的rootId
    [_dicData setValue:_strRootId forKey:@"rootId"];
    // 被回复人编号
    [_dicData setValue:_strTargetUid forKey:@"targetUid"];
    
    
    NSLog(@"_dicData:%@",_dicData);
    
    
    NSString *dataStr = [[MakeJson createJson:_dicData] AES128EncryptWithKey:userJiaMiArr[3]];
    
//    NSLog(@"**********%@",[MakeJson createDictionaryWithJsonString:[dataStr AES128DecryptWithKey:userJiaMiArr[3]]]);
    
    
    // 最终请求时需要的参数
    NSDictionary *dicDataJiaMi = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStr};
    NSLog(@"aaaaaaa:%@",dicDataJiaMi);
    
    
    if ([[_content stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        
        // 内容
        [MBHUDView hudWithBody:@"说点什么吧" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        // 打开用户交互
        fabiaoPingLunBtn.userInteractionEnabled = YES;
        
    }else {
        
        // 请求发评论或回复评论
        [http PostFabuAndHuiFuPingLunWithDic:dicDataJiaMi Success:^(id userInfo) {
            
            // 打开用户交互
            fabiaoPingLunBtn.userInteractionEnabled = YES;
            
            if ([userInfo isEqualToString:@"0"]) {
                
                // 网络请求失败
                [MBHUDView hudWithBody:@"评论失败" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                
            }else {
                // 网络请求失败
                [MBHUDView hudWithBody:@"评论成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                
                // 清空已经输入内容
                self.tf.text = @"";
                
                
                self.tf.placeholder = @"说点什么吧...";
                _strRootId = @"0";
                _strPid = @"0";
                _strTargetUid = _targetUid;
                
                
                // 重头开始
                pageStart = 0;
                // 重新请求数据
                [self initData];
            }
            
        } failure:^(NSError *error) {
            
            // 请求失败
            // 打开用户交互
            fabiaoPingLunBtn.userInteractionEnabled = YES;
        }];
    }
    
}

#pragma mark --- UITableViewDelegate,UITableViewDataSource ---
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _tableViewArr.count;
}

// 绑定数据
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    pinglunModel *model = _tableViewArr[indexPath.row];
    
//    PingLunCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"Cell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
    PingLunCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
    if (cell == nil) {
        cell = [[PingLunCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 拿到用户id
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([model.uid isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:model];
        };
        
    }else {
        
        // 头像点击block
        cell.iconImgViewClick = ^{
            [self iconImgViewBy:model];
        };
    }
    
    // 选中无效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
    cell.nickNameLb.text = model.nickname;
    cell.lbText.attributedText = [self getAttributedStringWithString:model.content lineSpace:5];
    // 时间label
    cell.timeLb.text = [TimeZhuanHuan timeFromTimestamp:[model.create_time integerValue]];
    
    if ([model.pid isEqualToString:@"0"]) {
        cell.lbHuiFuLe.hidden = YES;
    }else {
        cell.lbHuiFuLe.hidden = NO;
//        cell.lbTargetNickName.text = model.targetNickname == nil ? @"" : model.targetNickname;
        cell.lbTargetNickName.text = model.targetNickname;
    }
    
    return cell;
}


// 头像点击block触发事件
- (void) iconImgViewBy:(pinglunModel *)model {
    
    // 用户单例
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    // 拿到用户id
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([model.uid isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        [TipIsYourSelf tipIsYourSelf];
    }else {
        // 跳转到他人主页
        OtherMineViewController *vc = [[OtherMineViewController alloc] init];
        [vc setHidesBottomBarWhenPushed:YES];
        vc.userId = model.uid;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// tableview的点击
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 拿到数据模型
    pinglunModel *model = _tableViewArr[indexPath.row];
    
    // 变成第一响应者
    [self.tf becomeFirstResponder];
    
    self.tf.text = @"";
    // 传给self.tf 一些值
    self.tf.placeholder = [NSString stringWithFormat:@"回复:%@",model.nickname];
    
    // 修改两个参数
    if ([model.pid isEqualToString:@"0"]) {
        _strRootId = model.id1;
    }else {
        _strRootId = model.rootId;
    }
    
    _strPid = model.id1;
    _strTargetUid = model.uid;
    
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
