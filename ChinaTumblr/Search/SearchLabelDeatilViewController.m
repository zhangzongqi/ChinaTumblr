//
//  SearchLabelDeatilViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/6.
//  Copyright © 2017年 张宗琦. All rights reserved.
//  搜索标签详情页

#import "SearchLabelDeatilViewController.h"
#import "WMSearchDetailTableViewController.h" // 搜索标签的详情页面

#import "SearchDBManage.h" // 数据库

// 最大存储的搜索历史 条数
#define MAX_COUNT 4

@interface SearchLabelDeatilViewController () <UISearchBarDelegate> {
    
    NSString *_labelID; // 当前关键词id
}

/**
 *  SearchBar
 */
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, copy) MBProgressHUD *HUD;

@end

@implementation SearchLabelDeatilViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置不透明
    self.navigationController.navigationBar.translucent = NO;
    
    // 背景色
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 布局UI
    [self createUI];
    
    // 动画
    [self createLoadingForBtnClick];
    
    // 请求数据放在页面将要加载的时候
}

// 上拉下拉刷新动画
- (void) createLoadingForBtnClick {
    
    // 动画
    _HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 展示
    [_HUD show:YES];
}

// 请求数据
- (void) initData {
    
    // 用户加密数据
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    NSDictionary *dicData = @{@"keyword":_strDeatil,@"pageStart":@"0",@"pageSize":@"10",@"orderBy":@"0"};
    NSString *strJiaMi = [[MakeJson createJson:dicData] AES128EncryptWithKey:userJiaMiArr[3]];
    
    // dic
    NSDictionary *dicDataForJiaMi = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":strJiaMi};
    
    //
    NSLog(@"dicDataForJiaMi:%@",dicDataForJiaMi);
    
    
    // 创建数据请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 数据请求
    [http PostGetNoteListByKeywordWithDataDic:dicDataForJiaMi Success:^(id userInfo) {
        
        if ([[userInfo valueForKey:@"kwId"] isEqualToString:@"flase"]) {
            
            // 结束动画
            [_HUD hide:YES];
            
//            // 没有此关键词
//            [MBHUDView hudWithBody:@"暂无该关键词" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
            
            UIButton *menuBtn = [self.navigationController.view viewWithTag:888];
            menuBtn.selected = NO;
            menuBtn.userInteractionEnabled = NO;
            menuBtn.backgroundColor = FUIColorFromRGB(0x999999);
            
        }else {
            
            // 当前关键词Id
            _labelID = [userInfo valueForKey:@"kwId"];
            
            // 判断该关键词是否已关注
            // 获取用户关注关键词单例,并进行处理
            [self ToDealWithFocusKeyWord];
            
        }
        
    } failure:^(NSError *error) {
        
        // 结束动画
        [_HUD hide:YES];
        
        // 网络错误,不让点
        UIButton *menuBtn = [self.navigationController.view viewWithTag:888];
        menuBtn.userInteractionEnabled = NO;
        menuBtn.backgroundColor = FUIColorFromRGB(0x999999);
    }];
}


// 获取用户关注关键词单例,并进行处理
- (void) ToDealWithFocusKeyWord {
    
    
    UIButton *menuBtn = [self.navigationController.view viewWithTag:888];
    menuBtn.userInteractionEnabled = YES;
    menuBtn.backgroundColor = FUIColorFromRGB(0xfeaa0a);
    menuBtn.hidden = NO;
    
    HttpRequest *http = [[HttpRequest alloc] init];
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSArray *arrForAllFollowKeyWordId = [user valueForKey:@"AllFollowKeyWordId"];
    
    NSLog(@"******************%@",_labelID);
    NSLog(@"##################%@",arrForAllFollowKeyWordId);
    
    // 判断之前有没有这个单利
    if ([user valueForKey:@"AllFollowKeyWordId"] == nil) {
        
        NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2]};
        [http PostGetAllFollowKeywordIdListWithDic:dicData Success:^(id userInfo) {
            
            // 保存单利
            [user setValue:userInfo forKey:@"AllFollowKeyWordId"];
            
            // 返回的所有喜欢数组id包含当前的id
            if ([userInfo containsObject:_labelID]) {
                // 已关注
                menuBtn.selected = YES;
                menuBtn.backgroundColor = FUIColorFromRGB(0x999999);
            }else {
                menuBtn.selected = NO;
                menuBtn.backgroundColor = FUIColorFromRGB(0xfeaa0a);
            }
            
            // 结束动画
            [_HUD hide:YES];
            
        } failure:^(NSError *error) {
            
            // 结束动画
            [_HUD hide:YES];
            // 网络错误,
            menuBtn.selected = NO;
        }];
        
    }else {
        
        // 返回的所有喜欢数组id包含当前的id
        if ([arrForAllFollowKeyWordId containsObject:_labelID]) {
            // 已关注
            menuBtn.selected = YES;
            menuBtn.backgroundColor = FUIColorFromRGB(0x999999);
        }else {
            menuBtn.selected = NO;
            menuBtn.backgroundColor = FUIColorFromRGB(0xfeaa0a);
        }
        
        // 结束动画
        [_HUD hide:YES];
    }
}


// 标题们
- (NSArray <NSString *> *)titles {
    
    return @[@"最新发布",@"近期热门",@"历史榜单"];
}

// 一些属性
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    
    // 已修改MenuView的Frame  具体搜索MenuViewframe
    // 已修改lineWidth 具体搜索LineWidth
    self.menuItemWidth = W / 3;
    self.menuViewStyle = WMMenuViewStyleLine;
    self.progressViewBottomSpace = 0;
    self.progressHeight = 1.5;
    self.menuHeight = 32;
    self.titleColorNormal = FUIColorFromRGB(0x999999);
    self.titleColorSelected = FUIColorFromRGB(0xfeaa0a);
    self.titleSizeNormal = 12;
    self.titleSizeSelected = 14;
    self.showOnNavigationBar = NO;
    
    // 分栏选择条背景色
    self.menuBGColor = FUIColorFromRGB(0x151515);
    
    // 哪一个
    //    self.selectIndex = [_strSelectIndex intValue];
    
    return self.titles.count;
}


// page
- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
        {
            // 最新发布
            WMSearchDetailTableViewController *vc = [[WMSearchDetailTableViewController alloc] init];
            vc.guanjianciStr = _strDeatil;
            vc.oderByStr = @"0";
            return vc;
        }
            break;
        case 1:
        {
            // 近期热门
            WMSearchDetailTableViewController *vc = [[WMSearchDetailTableViewController alloc] init];
            vc.guanjianciStr = _strDeatil;
            vc.oderByStr = @"1";
            return vc;
        }
            break;
        case 2:
        {
            // 历史榜单
            WMSearchDetailTableViewController *vc = [[WMSearchDetailTableViewController alloc] init];
            vc.guanjianciStr = _strDeatil;
            vc.oderByStr = @"2";
            return vc;
        }
            break;
            
        default:
        {
            
            return nil;
        }
            break;
    }
}



// 布局UI
- (void) createUI {
    
    // 返回按钮
    [self createBackBtn];
    
    // 创建搜索栏
    [self setNavTitleView];
    
    // 导航栏右侧关注按钮
    [self createRightBtn];
}

// 创建导航栏右侧关注按钮
- (void) createRightBtn {
    
    // 右侧关注按钮
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 70, 30);
    [menuBtn setTitle:@"＋订阅" forState:UIControlStateNormal];
    [menuBtn setTitle:@"已订阅" forState:UIControlStateSelected];
    [menuBtn setTitleColor:FUIColorFromRGB(0x212121) forState:UIControlStateNormal];
    menuBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    menuBtn.backgroundColor = FUIColorFromRGB(0x999999);
    menuBtn.layer.cornerRadius = 15;
    menuBtn.clipsToBounds = YES;
    menuBtn.tag = 888;
    [menuBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    menuBtn.selected = NO;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = backItem;
    
    if (([[[ UIDevice currentDevice ] systemVersion ] floatValue ]>= 7.0 ? 20 : 0 )) {
        
        UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        
        negativeSpacer.width = - 10 ;//这个数值可以根据情况自由变化
        
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,backItem] ;
        
    } else {
        self.navigationItem.rightBarButtonItem = backItem;
    }
}

// 导航栏右侧按钮点击事件
- (void)rightBtnClick:(UIButton *)menuBtn {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 用户加密数据
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    if (menuBtn.selected == NO) {
        
        // 在这里面请求接口,记得先禁用用户交互,请求完成或失败，打开用户交互
        menuBtn.userInteractionEnabled = NO;
        NSDictionary *dic = @{@"kwdId":_labelID};
        NSString *dataStr = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
        NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStr};
        [http PostFollowKeywordWithDic:dicData Success:^(id userInfo) {
            
            menuBtn.userInteractionEnabled = YES;
            
            if ([userInfo isEqualToString:@"0"]) {
                
                // 订阅失败
                
            }else {
                
                [MBHUDView hudWithBody:@"订阅成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                // 订阅成功，改变按钮状态
                menuBtn.backgroundColor = FUIColorFromRGB(0x999999);
                menuBtn.selected = YES;
                
                // 把订阅的id加入所有订阅的单利里面
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSArray *tempArr = [user valueForKey:@"AllFollowKeyWordId"];
                NSMutableArray *NewIdArr = [NSMutableArray arrayWithArray:tempArr];
                [NewIdArr addObject:_labelID];
                [user setValue:NewIdArr forKey:@"AllFollowKeyWordId"];
                
                // 发送消息通知
                // 创建消息中心
                NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
                // 在消息中心发布自己的消息
                [notiCenter postNotificationName:@"reviseBiaoQian" object:nil];
                
            }
            
        } failure:^(NSError *error) {
            
            // 打开用户交互
            menuBtn.userInteractionEnabled = YES;
        }];
        
    }else {
        
        // 在这里面请求接口,记得先禁用用户交互,请求完成或失败，打开用户交互
        menuBtn.userInteractionEnabled = NO;
        NSDictionary *dic = @{@"kwdIds":_labelID};
        NSString *dataStr = [[MakeJson createJson:dic] AES128EncryptWithKey:userJiaMiArr[3]];
        NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStr};
        [http PostRemoveFollowKeywordWithDic:dicData Success:^(id userInfo) {
            
            menuBtn.userInteractionEnabled = YES;
            
            if ([userInfo isEqualToString:@"0"]) {
                
                // 取消订阅失败
                
            }else {
                
                [MBHUDView hudWithBody:@"取消订阅成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                // 取消订阅成功，改变按钮状态
                menuBtn.selected = NO;
                menuBtn.backgroundColor = FUIColorFromRGB(0xfeaa0a);
                
                // 从单利中移除
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSArray *tempArr = [user valueForKey:@"AllFollowKeyWordId"];
                NSMutableArray *NewIdArr = [NSMutableArray arrayWithArray:tempArr];
                [NewIdArr removeObject:_labelID];
                [user setValue:NewIdArr forKey:@"AllFollowKeyWordId"];
                
                
                // 发送消息通知
                // 创建消息中心
                NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
                // 在消息中心发布自己的消息
                [notiCenter postNotificationName:@"reviseBiaoQian" object:nil];
            }
            
        } failure:^(NSError *error) {
            
            // 打开用户交互
            menuBtn.userInteractionEnabled = YES;
        }];
    }
}


/**
 *  设置导航搜索框
 */
- (void)setNavTitleView {
    
    //加上 搜索栏
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W - 120, 35)];
    titleView.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    
    searchBar.delegate = self;
    searchBar.frame = CGRectMake(0, 1, W - 120, 32);
    searchBar.backgroundColor = [UIColor colorWithRed:239/255.0 green:240/255.0 blue:241/255.0 alpha:1.0];
    searchBar.layer.cornerRadius = 16;
    searchBar.layer.masksToBounds = YES;
    searchBar.placeholder = @" 请输入关键字";
    searchBar.text = _strDeatil;
    UITextField*searchField = [searchBar valueForKey:@"_searchField"];
    searchField.textColor = FUIColorFromRGB(0xffffff);
    self.searchBar = searchBar;
    [titleView addSubview:searchBar];
    
    
    //Set to titleView
    [self.navigationItem.titleView sizeToFit];
    self.navigationItem.titleView = titleView;
    
    UIImage* searchBarBg = [self GetImageWithColor:[UIColor colorWithRed:41/255.0 green:42/255.0 blue:43/255.0 alpha:1.0] andHeight:32.0f];
    //设置背景图片
    [_searchBar setBackgroundImage:searchBarBg];
    //设置背景色
    [_searchBar setBackgroundColor:[UIColor clearColor]];
    //设置文本框背景
    [_searchBar setSearchFieldBackgroundImage:searchBarBg forState:UIControlStateNormal];
}

// 用颜色做图片
- (UIImage*) GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

// 返回按钮
- (void) createBackBtn {
    
    // 返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 0, 10.4, 18.4);
    
    [backBtn setImage:[UIImage imageNamed:@"details_return"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    //    self.navigationItem.leftBarButtonItem = backItem;
    
    if (([[[ UIDevice currentDevice ] systemVersion ] floatValue ]>= 7.0 ? 20 : 0 ))
        
    {
        
        UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ] initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace
                                           
                                                                                          target : nil action : nil ];
        
        negativeSpacer.width = - 5 ;//这个数值可以根据情况自由变化
        
        self.navigationItem.leftBarButtonItems = @[ negativeSpacer,  backItem] ;
        
    } else {
        self . navigationItem . leftBarButtonItem = backItem;
    }
    
}

// 返回按钮点击事件
- (void) doBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


// 页面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // 不隐藏导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // 设置导航栏背景色
    [self.navigationController.navigationBar setBarTintColor:FUIColorFromRGB(0x151515)];
    
    // 进行数据请求
    [self initData];
//    // 刷新下面的tableView
//    [self reloadData];
}


//// 页面已经显示
//- (void) viewDidAppear:(BOOL)animated {
//    
//    // 获取用户关注关键词单例,并进行处理
//    [self ToDealWithFocusKeyWord];
//}



/**
 *  点击搜索时, 历史记录插入数据库
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    // 修改关键词
    _strDeatil = searchBar.text;
    // 重新网络请求
    [self initData];
    // 刷新下面的tableView
    [self reloadData];
    
    // 插入数据库
    [self insterDBData:searchBar.text];
    
    //取消第一响应者状态, 键盘消失
    [searchBar resignFirstResponder];
    
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
