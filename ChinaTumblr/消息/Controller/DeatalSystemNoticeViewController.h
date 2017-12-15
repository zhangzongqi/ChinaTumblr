//
//  DeatalSystemNoticeViewController.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/11/1.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestJSExport <JSExport>

// html内部加载完成方法
- (void)loadData;

@end


@interface DeatalSystemNoticeViewController : BackViewController
<UIWebViewDelegate,TestJSExport>

@property (strong, nonatomic) JSContext *context;

// 此页的id
@property (nonatomic, copy) NSString *idStr;

@end
