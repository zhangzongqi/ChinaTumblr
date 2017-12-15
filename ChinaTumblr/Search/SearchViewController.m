//
//  SearchViewController.m
//  Sesame
//
//  Created by 杨卢青 on 16/5/20.
//  Copyright © 2016年 杨卢青. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchDBManage.h"
#import "WMSearchLabelViewController.h" // 分类搜索标签页面
#import "WMSearchUserViewController.h" // 搜索用户页面
#import "WMSearchTieZiViewController.h" // 分类搜索帖子页面


// 最大存储的搜索历史 条数
#define MAX_COUNT 4

@interface SearchViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,CAAnimationDelegate>

/**
 *  搜索历史数据表单
 */
@property (nonatomic, strong) UITableView *tableView;
/**
 *  数据集合
 */
@property (nonatomic, strong) NSMutableArray *dataArray;
/**
 *  SearchBar
 */
@property (nonatomic, strong) UISearchBar *searchBar;


@property (nonatomic, assign, setter = setHasCentredPlaceholder:) BOOL hasCentredPlaceholder;

@end


@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    
    // 设置不透明
    self.navigationController.navigationBar.translucent = NO;
    
    // 背景色
    self.view.backgroundColor = [UIColor colorWithRed:237/255.0 green:239/255.0 blue:240/255.0 alpha:1.0];
    
    // 返回按钮
    [self createBackBtn];
    
    //初始化数据
    [self initData];
    
    // 创建搜索栏
    [self setNavTitleView];
    
    // 创建tableView
    [self initTableView];
    
}


// 返回按钮
- (void) createBackBtn {
    
    // 返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor colorWithRed:121/255.0 green:122/255.0 blue:123/255.0 alpha:1.0] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = backItem;
    
    if (([[[ UIDevice currentDevice ] systemVersion ] floatValue ]>= 7.0 ? 20 : 0 ))
        
    {
        
        UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        
        negativeSpacer.width = - 10 ;//这个数值可以根据情况自由变化
        
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,backItem] ;
        
    } else {
        self.navigationItem.rightBarButtonItem = backItem;
    }
}


// 标题们
- (NSArray <NSString *> *)titles {
    
    return @[@"标签",@"用户",@"帖子"];
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
    self.titleColorNormal = FUIColorFromRGB(0x212121);
    self.titleColorSelected = [UIColor colorWithRed:250/255.0 green:170/255.0 blue:44/255.0 alpha:1.0];
    self.titleSizeNormal = 12;
    self.titleSizeSelected = 14;
    self.showOnNavigationBar = NO;
    
    // 分栏选择条背景色
    self.menuBGColor = FUIColorFromRGB(0xffffff);
    
    // 哪一个
//    self.selectIndex = [_strSelectIndex intValue];
    
    return self.titles.count;
}


// page
- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
        {
            // 标签
            WMSearchLabelViewController *vc = [[WMSearchLabelViewController alloc] init];
            
            vc.str = self.searchBar.text;
            
            return vc;
        }
            break;
        case 1:
        {
            // 用户
            WMSearchUserViewController *vc = [[WMSearchUserViewController alloc] init];
            
            vc.str = self.searchBar.text;
            
            return vc;
        }
            break;
        case 2:
        {
            // 帖子
            WMSearchTieZiViewController *vc = [[WMSearchTieZiViewController alloc] init];
            
            vc.str = self.searchBar.text;
            
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


#pragma mark - Helper
/**
 *  数据初始化
 */
- (void)initData
{
    self.dataArray = [[NSMutableArray alloc] init];
    //获取数据库里面的全部数据
    self.dataArray = [[SearchDBManage shareSearchDBManage] selectAllSearchModel];
}

/**
 *  设置导航搜索框
 */
- (void)setNavTitleView
{
    
//    self.searchBar = [[UISearchBar alloc] init];
//    _searchBar.frame = CGRectMake(0, 0, 140, 30);
//    _searchBar.delegate = self;
//    _searchBar.placeholder = @"请输入关键字                                    ";
////    [_searchBar setBackgroundColor:[UIColor grayColor]];
//    self.navigationItem.titleView = self.searchBar;
//    self.searchBar.layer.cornerRadius = 15;
//    self.searchBar.clipsToBounds = YES;
    
    
    //加上 搜索栏
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(- 10, 0, W - 65, 35)];
    titleView.backgroundColor = [UIColor whiteColor];
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    
    searchBar.delegate = self;
    searchBar.frame = CGRectMake(-10, 1.5, W - 65, 32);
    searchBar.backgroundColor = [UIColor colorWithRed:239/255.0 green:240/255.0 blue:241/255.0 alpha:1.0];
    searchBar.layer.cornerRadius = 16;
    searchBar.layer.masksToBounds = YES;
//    [searchBar.layer setBorderWidth:8];
//    [searchBar.layer setBorderColor:[UIColor clearColor].CGColor];  //设置边框为白色
    searchBar.placeholder = @"请输入关键字";
    self.searchBar = searchBar;
    [titleView addSubview:searchBar];
    
    //Set to titleView
    [self.navigationItem.titleView sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:titleView];
    self.navigationItem.leftBarButtonItem = item;
    
    UIImage* searchBarBg = [self GetImageWithColor:[UIColor colorWithRed:239/255.0 green:240/255.0 blue:241/255.0 alpha:1.0] andHeight:32.0f];
    //设置背景图片
    [_searchBar setBackgroundImage:searchBarBg];
    //设置背景色
    [_searchBar setBackgroundColor:[UIColor clearColor]];
    //设置文本框背景
    [_searchBar setSearchFieldBackgroundImage:searchBarBg forState:UIControlStateNormal];
    
    [_searchBar becomeFirstResponder];
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


/**
 *  设置搜索历史显示表格
 */
- (void)initTableView
{

    // tableview创建
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, 0, W, H);
//    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor whiteColor];
    
    // 隐藏多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - TableViewDelegate, dataSource
// 每个tableview的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

// 返回的分组数
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    
    if (self.dataArray.count == 0) {
            
        return 1;
            
    }else {
            
        return 2;
    }
}

// 返回的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.dataArray.count == 0) {
        
        // 没有历史搜索
        // 直接显示推荐的行数
        
        return 1;
        
    }else {
        
        // 有历史搜索
        // 显示历史
        switch (section) {
            case 0:
            {
                
                // 有历史搜索
                // 显示历史
                return _dataArray.count;
            }
                break;
            case 1:
            {
                // 现在推荐
                return 1;
            }
                break;
                
            default:
            {
                return 0;
            }
                break;
        }
    }
}

// 绑定数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (self.dataArray.count == 0) {
        
        // 没有历史搜索
        // 直接显示推荐
        static NSString *identifier = @"identifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor whiteColor];
        }
        cell.textLabel.text = @"暂无更多推荐~";
        cell.textLabel.textColor = [UIColor grayColor];
        
        // 选中无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }else {
        
        switch (indexPath.section) {
            case 0:
            {
                // 有历史搜索
                // 显示历史
                static NSString *identifier = @"identifier";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
                    cell.backgroundColor = [UIColor whiteColor];
                }
                SearchModel *model = (SearchModel *)[self exchangeArray:_dataArray][indexPath.row];
                cell.textLabel.text = model.keyWord;
                cell.textLabel.textColor = [UIColor grayColor];
                //                cell.detailTextLabel.text = model.currentTime;
                //                cell.detailTextLabel.textColor = [UIColor colorWithRed:66/255.0 green:67/255.0 blue:68/255.0 alpha:1.0];
                
                //                cell.imageView.image = [UIImage imageNamed:@"s搜索03"];
                // 右测箭头
                //                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                return cell;
            }
                break;
            case 1:
            {
                static NSString *identifier = @"identifier";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
                    cell.backgroundColor = [UIColor whiteColor];
                }
                cell.textLabel.text = @"暂无更多推荐~";
                cell.textLabel.textColor = [UIColor grayColor];
                
                // 选中无效果
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            }
                break;
                
            default:{
                
                return nil;
            }
                break;
        }
    }
}

// 自定义分区表头和表尾
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, 0)];
    uv.backgroundColor = [UIColor whiteColor];
    
    
    if (_dataArray.count == 0) {
        
        // 文字
        UILabel *lbCls = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 120, 35)];
        lbCls.textColor = [UIColor colorWithRed:249/255.0 green:170/255.0 blue:49/255.0 alpha:1.0];
        lbCls.text = @"推荐";
        lbCls.font = [UIFont systemFontOfSize:15];
        [uv addSubview:lbCls];
        
    }else {
        
        if (section == 0) {
            
            // 文字
            UILabel *lbCls = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 120, 35)];
            lbCls.textColor = FUIColorFromRGB(0x212121);
            lbCls.text = @"最近";
            lbCls.font = [UIFont systemFontOfSize:15];
            [uv addSubview:lbCls];
            
        }else {
            
            // 文字
            UILabel *lbCls = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 120, 35)];
            lbCls.textColor = [UIColor colorWithRed:249/255.0 green:170/255.0 blue:49/255.0 alpha:1.0];
            lbCls.text = @"推荐";
            lbCls.font = [UIFont systemFontOfSize:15];
            [uv addSubview:lbCls];
            
            //
            UILabel *lbFenge = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, W - 20, 1)];
            lbFenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
            [uv addSubview:lbFenge];
        }
    }
    
    return uv;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 35;
}



/**
 *  数组逆序
 *
 *  @param array 需要逆序的数组
 *
 *  @return 逆序后的输出
 */
- (NSMutableArray *)exchangeArray:(NSMutableArray *)array{
    NSInteger num = array.count;
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSInteger i = num - 1; i >= 0; i --) {
        [temp addObject:[array objectAtIndex:i]];
        
    }
    return temp;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 释放第一响应者
    [_searchBar resignFirstResponder];

}

// tableview的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 反选
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (_dataArray.count == 0) {
        
        // 没有历史搜索
//        self.searchBar.text = @"这里是推荐的内容";
//        // 点击搜索时, 历史记录插入数据库
//        [self searchBarSearchButtonClicked:self.searchBar];
        
        // 改变Tbv
//        [_tableView removeFromSuperview];
//        // 刷新WMPageController
//        [self reloadData];
        
        
    }else {
        
        if (indexPath.section == 0) {
            
            SearchModel *model = (SearchModel *)[self exchangeArray:self.dataArray][indexPath.row];
            
            self.searchBar.text = model.keyWord;
            
            // 点击搜索时, 历史记录插入数据库
            [self searchBarSearchButtonClicked:self.searchBar];
            
            // 改变Tbv
            [_tableView removeFromSuperview];
            // 刷新WMPageController
            [self reloadData];
            
        }else {
            
//            // 没有历史搜索
//            self.searchBar.text = @"这里是推荐的内容";
//            // 点击搜索时, 历史记录插入数据库
//            [self searchBarSearchButtonClicked:self.searchBar];
//            
//            // 改变Tbv
//            [_tableView removeFromSuperview];
//            // 刷新WMPageController
//            [self reloadData];
        }
    }
    
}

#pragma mark - UISearchBarDelegate

//输入文本实时更新时调用
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText

{
    
    if (searchText.length == 0) {
        
        NSLog(@"东西被清空了");
        
        // 还原Tbv
        [self.view addSubview:_tableView];
        
        
    }else {
        
        // 改变Tbv
        [_tableView removeFromSuperview];

        // 刷新WMPageController
        [self reloadData];
        
        NSLog(@"输入东西了");
        
    }
}

// 将要输入
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"呵呵呵呵呵,开始输入");
    
    return YES;
}

// 开始输入
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    
}

// 结束输入
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    NSLog(@"哈哈哈哈，结束");
}

/**
 *  点击搜索时, 历史记录插入数据库
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    // 插入数据库
    [self insterDBData:searchBar.text];
    
    //取消第一响应者状态, 键盘消失
    [searchBar resignFirstResponder];
    
}

/**
 *  点击取消按钮
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //插入数据库
    [self insterDBData:searchBar.text];
    [searchBar resignFirstResponder];
}

/**
 *  关键词插入数据库
 *
 *  @param keyword 关键词
 */
- (BOOL)insterDBData:(NSString *)keyword{
    if (keyword.length == 0) {
        return NO;
    }
    else{//搜索历史插入数据库
        //先删除数据库中相同的数据
        [self removeSameData:keyword];
        //再插入数据库
        [self moreThan20Data:keyword];
        // 读取数据库里面的数据
        self.dataArray = [[SearchDBManage shareSearchDBManage] selectAllSearchModel];
        [self.tableView reloadData];
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
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
        [temp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SearchModel *model = (SearchModel *)obj; // 取出 数组里面的搜索模型
            [[SearchDBManage shareSearchDBManage] insterSearchModel:model]; // 插入数据库
        }];
    }
    else if (array.count <= MAX_COUNT - 1){ // 小于等于19 就把第20条插入数据库
        [[SearchDBManage shareSearchDBManage] insterSearchModel:[SearchModel creatSearchModel:keyword currentTime:[self getCurrentTime]]];
    }
}


// 页面将要消失
- (void) viewWillDisappear:(BOOL)animated {
    
    // 设置导航栏背景色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0]];
    //这个接口可以动画的改变statusBar的前景色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    // 释放第一响应者
    [self.searchBar resignFirstResponder];
}

// 页面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // 设置导航栏背景色
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    //这个接口可以动画的改变statusBar的前景色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    
    // 成为第一响应者
//    [self.searchBar becomeFirstResponder];
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

- (void)doBack:(id)sender
{
    
    [_searchBar resignFirstResponder];
    
    // 设置跳转的样式
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.3f;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionFade;
////    transition.subtype = kCATransitionFromRight;
//    transition.delegate = self;
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    // 跳转，动画设置为NO
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
