//
//  MineFlagViewController.h
//  ChinaTumblr
//
//  Created by 张志鹏 on 2017/9/11.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "BaseViewController.h"

@interface MineFlagViewController : BaseViewController
@property (nonatomic,assign) NSInteger currentIndex;

@property (nonatomic,assign)BOOL isEdit;


@property (nonatomic,copy) void (^currnetSelectedIndex)(NSInteger index);
@end
