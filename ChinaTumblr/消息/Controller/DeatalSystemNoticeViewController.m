//
//  DeatalSystemNoticeViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/11/1.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "DeatalSystemNoticeViewController.h"
#import "ZhuanTiDetailModel.h" // 专题详情模型

@interface DeatalSystemNoticeViewController () {
    
    NSMutableArray *_currentViewData; // 当前页面数据
    
    // 网页
    UIWebView *_webview;
}

@property (nonatomic, copy) MBProgressHUD *HUD; // 动画

@end

@implementation DeatalSystemNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 设置导航栏标题
    UILabel *lbItemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    lbItemTitle.text = @"专题详情";
    lbItemTitle.textColor = [UIColor blackColor];
    lbItemTitle.textAlignment = NSTextAlignmentCenter;
    lbItemTitle.font = [UIFont boldSystemFontOfSize:18];
    self.navigationItem.titleView = lbItemTitle;
    
    // 初始化数组
    [self initArr];
    
    // 获取数据
    [self initData];
}

// 初始化数组
- (void) initArr {
    
    _currentViewData = [NSMutableArray array];
}

// 获取数据
- (void) initData {
    
    // 创建动画
    _HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 展示
    [_HUD show:YES];
    
    // 创建请求头
    HttpRequest *http = [[HttpRequest alloc] init];
    
    // 获取数据
    [http GetSpecialEventDetailWithId:_idStr Success:^(id arrForDetail) {
        
        if ([arrForDetail isKindOfClass:[NSString class]]) {
            // 提示获取失败并退出此页
//            [http GetHttpDefeatAlert:@"获取详情失败"];
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            
            // 拿到数据了，去保存成全局,然后创建UI
            _currentViewData = arrForDetail;
            
            [self createUI];
            
            ZhuanTiDetailModel *model = _currentViewData[0];
            
            if ([model.type isEqualToString:@"0"]) {
                
                // 设置webView的本地路径
                NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"detail.html"];
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
                [_webview loadRequest:request];
                
                self.context = [_webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
                // 打印异常
                self.context.exceptionHandler =
                ^(JSContext *context, JSValue *exceptionValue)
                {
                    context.exception = exceptionValue;
                    NSLog(@"%@", exceptionValue);
                };
                
                // 以 JSExport 协议关联 obj 的方法
                self.context[@"obj"] = self;
                
            }else {
                
                // 直接网页加载，不用做任何操作
            }
        }
        
        // 让动画消失
        [_HUD hide:YES];
        
    } failure:^(NSError *error) {
        
        // 让动画消失,并返回上一个页面
        [_HUD hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
}

// html内部加载完成方法
- (void) loadData {
    
    ZhuanTiDetailModel *model = _currentViewData[0];
    
    NSString *str1 = [NSString stringWithFormat:@"showDetail('%@')",model.content];
    
    NSString *alertJS=str1; //准备执行的js代码
    [self.context evaluateScript:alertJS];//通过oc方法调用js的方法
}


// 创建UI
- (void) createUI {
    
    // 模型
    ZhuanTiDetailModel *model = _currentViewData[0];
    
    if ([model.type isEqualToString:@"0"]) {
        
        // 加载本地模板
        UIView * vc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, 0.5)];
        [self.view addSubview:vc];
        vc.backgroundColor = FUIColorFromRGB(0xeeeeee);
        
        // 网页加载
        _webview = [[UIWebView alloc] init];
        [self.view addSubview:_webview];
        [_webview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(0.5);
            make.left.equalTo(self.view).with.offset(15);
            make.width.equalTo(@(W - 24));
            make.height.equalTo(@(H - 0.5));
        }];
        
        _webview.delegate = self;
        _webview.backgroundColor = FUIColorFromRGB(0xffffff);
        _webview.scrollView.showsVerticalScrollIndicator = NO;
        _webview.scrollView.showsHorizontalScrollIndicator = NO;
    }else {
        
        // 加载本地模板
        UIView * vc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, 0.5)];
        [self.view addSubview:vc];
        vc.backgroundColor = FUIColorFromRGB(0xeeeeee);
        
        // 网页加载
        _webview = [[UIWebView alloc] init];
        [self.view addSubview:_webview];
        [_webview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(0.5);
            make.left.equalTo(self.view);
            make.width.equalTo(@(W));
            make.height.equalTo(@(H - 0.5));
        }];
        
        NSURL* url = [NSURL URLWithString:model.content];//创建URL
        NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
        [_webview loadRequest:request];//加载
        
        _webview.delegate = self;
        _webview.backgroundColor = FUIColorFromRGB(0xffffff);
        _webview.scrollView.showsVerticalScrollIndicator = NO;
        _webview.scrollView.showsHorizontalScrollIndicator = NO;
    }
    
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
