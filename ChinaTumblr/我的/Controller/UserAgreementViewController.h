//
//  UserAgreementViewController.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/10/10.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestJSExport <JSExport>

// html内部加载完成方法
- (void)loadData;

@end

@interface UserAgreementViewController : BackViewController
<UIWebViewDelegate,TestJSExport>

@property (strong, nonatomic) JSContext *context;

@end
