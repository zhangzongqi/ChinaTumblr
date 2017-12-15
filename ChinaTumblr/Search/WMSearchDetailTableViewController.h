//
//  WMSearchDetailTableViewController.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/6.
//  Copyright © 2017年 张宗琦. All rights reserved.
//  搜索标签的详情页

#import <UIKit/UIKit.h>

@interface WMSearchDetailTableViewController : UIViewController

@property (nonatomic, copy) NSString *biaoqianId; // 标签Id(根据标签来搜索帖子)
@property (nonatomic, copy) NSString *guanjianciStr; // 关键词（标签）
@property (nonatomic, copy) NSString *oderByStr; // 排序方式

@end
