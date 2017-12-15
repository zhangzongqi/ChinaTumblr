//
//  TipIsYourSelf.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/29.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "TipIsYourSelf.h"

@implementation TipIsYourSelf

+ (void) tipIsYourSelf {
    
    HttpRequest *alert = [[HttpRequest alloc] init];
    [alert GetHttpDefeatAlert:@"这是你自己哟~"];
}

@end
