//
//  UserAgreementViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/10/10.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "UserAgreementViewController.h"

@interface UserAgreementViewController () {
    
    // 保存请求到的数据
    NSString *_webDetailStr;
    
    // 网页
    UIWebView *_webview;
}

@end

@implementation UserAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 页面背景色
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 设置导航栏标题
    UILabel *lbItemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    lbItemTitle.text = @"《嘚瑟用户协议》";
    lbItemTitle.textColor = [UIColor blackColor];
    lbItemTitle.textAlignment = NSTextAlignmentCenter;
    lbItemTitle.font = [UIFont boldSystemFontOfSize:18];
    self.navigationItem.titleView = lbItemTitle;
    
    
    // 获取数据
    [self initData];
}


// 获取数据
- (void)initData {
    
    // 创建请求对象
    HttpRequest *http = [[HttpRequest alloc] init];
    // 发起请求
    [http GetRegistrationAgreementSuccess:^(id arrForDetail) {
        
        // 把拿到的数据保存到全局字典
        _webDetailStr = arrForDetail;
        
        // 布局页面
        [self layoutViews];
        
        
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
        
    } failure:^(NSError *error) {
        
        NSLog(@"失败了");
    }];
    
}

// html内部加载完成方法
- (void) loadData {
    
    NSLog(@"*************%@",_webDetailStr);
    
    NSString *str1 = [NSString stringWithFormat:@"showDetail('%@')",_webDetailStr];
    
    NSString *alertJS=str1; //准备执行的js代码
    [self.context evaluateScript:alertJS];//通过oc方法调用js的方法
}


// 布局页面
- (void) layoutViews {
    
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
    
//    NSURL* url = [NSURL URLWithString:@"https://blog.huopinb.com/test.html"];//创建URL
//    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
//    [_webview loadRequest:request];//加载
    
    _webview.delegate = self;
    _webview.backgroundColor = FUIColorFromRGB(0xffffff);
    _webview.scrollView.showsVerticalScrollIndicator = NO;
    _webview.scrollView.showsHorizontalScrollIndicator = NO;
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
