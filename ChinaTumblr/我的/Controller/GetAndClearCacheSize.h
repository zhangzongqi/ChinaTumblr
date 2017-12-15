//
//  GetAndClearCacheSize.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/15.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetAndClearCacheSize : NSObject

// 读取缓存
- (float)readCacheSize;

// 清空缓存
- (void)clearFile;

@end
