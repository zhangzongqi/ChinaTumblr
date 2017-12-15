//
//  PublishTextViewController.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/7.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchTieZiWithKeyWordModel.h" // 要删除的帖子的数据模型

@interface PublishTextViewController : UIViewController

@property (nonatomic, copy) SearchTieZiWithKeyWordModel *model;

@end
