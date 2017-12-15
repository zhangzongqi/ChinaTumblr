//
//  TimeZhuanHuan.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/21.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeZhuanHuan : NSObject

// 时间戳转换成距离时间
+ (NSString *)timeFromTimestamp:(NSInteger)timestamp;

@end
