//
//  PingLunViewController.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/10.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "BackViewController.h"

@interface PingLunViewController : BackViewController

@property (nonatomic, copy) NSString *noteId;  // 帖子Id
@property (nonatomic, copy) NSString *targetUid; // 被回复人编号

@end
