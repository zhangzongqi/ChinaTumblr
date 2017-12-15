//
//  KeJianViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/18.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "KeJianViewController.h"

@interface KeJianViewController ()

@property (nonatomic,copy) NSMutableArray *arrForKeJian;

@property (nonatomic, copy) MBProgressHUD *HUD;

@end

@implementation KeJianViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置导航栏标题
    UILabel *lbItemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    lbItemTitle.text = @"可见页面";
    lbItemTitle.textColor = FUIColorFromRGB(0x212121);
    lbItemTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = lbItemTitle;
    
    // 初始化数据源
    [self initDataSource];
    
    // 布局UI
    [self createUI];
    
    // 加载动画
    [self createLoadingHUD];
    
    // 获取数据
    [self initData];
}

// 刷新动画
- (void) createLoadingHUD {
    
    // 动画
    _HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 展示
    [_HUD show:YES];
}


// 初始化数据源
- (void) initDataSource {
    
    
    _arrForKeJian = [NSMutableArray array];
}

// 获取数据
- (void) initData {
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 拿到用户相关加密数据
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    NSDictionary *dicData = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2]};
    
    UISwitch *likeSwitch = [self.view viewWithTag:666];
    UISwitch *guanzhuSwitch = [self.view viewWithTag:667];
    
    // 进行请求
    [http PostGetShowPageTabConfigWithDic:dicData Success:^(id userInfo) {
        
        // 结束动画
        [_HUD hide:YES];
        
        if ([userInfo isEqualToString:@"flase"]) {
            
            // 获取失败
            NSLog(@"获取失败");
        }else {
            
            switch ([userInfo integerValue]) {
                case 0: {
                    likeSwitch.on = NO;
                    guanzhuSwitch.on = NO;
                }
                    break;
                case 2: {
                    likeSwitch.on = YES;
                    guanzhuSwitch.on = NO;
                }
                    break;
                case 4: {
                    likeSwitch.on = NO;
                    guanzhuSwitch.on = YES;
                }
                    break;
                case 6: {
                    likeSwitch.on = YES;
                    guanzhuSwitch.on = YES;
                }
                    break;
                    
                default:
                    break;
            }
        }
        
    } failure:^(NSError *error) {
        
        // 结束动画
        [_HUD hide:YES];
        
        NSLog(@"网络错误");
    }];
}


// 布局UI
- (void) createUI {
    
    NSArray *titleNameArr = @[@"喜欢",@"关注"];
    NSArray *detailNameArr = @[@"你喜欢的帖子",@"你关注的人"];
    
    // 分隔线 标题
    for (int i = 0; i < 2; i++) {
        
        // 分隔线
        UILabel *lbFenGe = [[UILabel alloc] init];
        [self.view addSubview:lbFenGe];
        [lbFenGe mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(60 * (i + 1));
            make.left.equalTo(self.view).with.offset(20);
            make.right.equalTo(self.view);
            make.height.equalTo(@(0.5));
        }];
        lbFenGe.backgroundColor = FUIColorFromRGB(0xeeeeee);
        
        // title
        UILabel *titleLb = [[UILabel alloc] init];
        [self.view addSubview:titleLb];
        [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lbFenGe);
            make.bottom.equalTo(lbFenGe).with.offset(-15);
            make.height.equalTo(@(16));
        }];
        titleLb.textColor = FUIColorFromRGB(0x212121);
        titleLb.font = [UIFont systemFontOfSize:16];
        titleLb.text = titleNameArr[i];
        
        // 说明
        UILabel *detailLb = [[UILabel alloc] init];
        [self.view addSubview:detailLb];
        [detailLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(titleLb);
            make.left.equalTo(titleLb.mas_right).with.offset(10);
            make.height.equalTo(@(14));
        }];
        detailLb.textColor = FUIColorFromRGB(0x999999);
        detailLb.font = [UIFont systemFontOfSize:14];
        detailLb.text = detailNameArr[i];
        
        // 开关按妞
        UISwitch *kejianSwitch = [[UISwitch alloc] init];
        [self.view addSubview:kejianSwitch];
        [kejianSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).with.offset(-20);
            make.centerY.equalTo(titleLb);
        }];
        //设置开启状态的风格颜色
        [kejianSwitch setOnTintColor:FUIColorFromRGB(0xfeaa0a)];
        //设置整体风格颜色,按钮的白色是整个父布局的背景颜色
        [kejianSwitch setTintColor:[UIColor colorWithRed:228/255.0 green:232/255.0 blue:235/255.0 alpha:1.0]];
        [kejianSwitch setBackgroundColor:[UIColor colorWithRed:228/255.0 green:232/255.0 blue:235/255.0 alpha:1.0]];
        kejianSwitch.layer.cornerRadius = kejianSwitch.height / 2;
        kejianSwitch.clipsToBounds = YES;
        kejianSwitch.tag = 666+i;
        [kejianSwitch addTarget:self action:@selector(swChange:) forControlEvents:UIControlEventValueChanged];
    }
}

// 选择器触发事件
- (void) swChange:(UISwitch *)kejianSwitch {
    
    // 开始动画
    [self createLoadingHUD];
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    // 获取用户加密数据
    NSArray *userJiaMi = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    NSString *strShowPageData;
    
    UISwitch *likeSwitch = [self.view viewWithTag:666];
    UISwitch *guanzhuSwitch = [self.view viewWithTag:667];
    likeSwitch.userInteractionEnabled = NO;
    guanzhuSwitch.userInteractionEnabled = NO;
    
    if (likeSwitch.on == NO && guanzhuSwitch.on == NO) {
        strShowPageData = @"0";
    }else if (likeSwitch.on == YES && guanzhuSwitch.on == NO) {
        strShowPageData = @"2";
    }else if (likeSwitch.on == NO && guanzhuSwitch.on == YES) {
        strShowPageData = @"4";
    }else {
        strShowPageData = @"6";
    }
    
    NSLog(@"intShowPageData %@",strShowPageData);
        
    NSDictionary *dicdata = @{@"showPage":strShowPageData};
    NSString *strForData = [[MakeJson createJson:dicdata] AES128EncryptWithKey:userJiaMi[3]];
    NSDictionary *dicDataJiaMi = @{@"tk":userJiaMi[0],@"key":userJiaMi[1],@"cg":userJiaMi[2],@"data":strForData};
    
    [http PostSetShowPageTabConfigWithDic:dicDataJiaMi Success:^(id userInfo) {
        
        // 结束动画
        [_HUD hide:YES];
        // 打开用户操作
        likeSwitch.userInteractionEnabled = YES;
        guanzhuSwitch.userInteractionEnabled = YES;
        
        if ([userInfo isEqualToString:@"0"]) {
            
            NSLog(@"修改失败");
            
        }else {
            
            NSLog(@"修改成功");
        }
        
    } failure:^(NSError *error) {
        
        // 结束动画
        [_HUD hide:YES];
        // 打开用户操作
        likeSwitch.userInteractionEnabled = YES;
        guanzhuSwitch.userInteractionEnabled = YES;
        NSLog(@"网络错误");
    }];
    
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
