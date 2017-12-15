//
//  ZhuanTiModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/10/30.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface ZhuanTiModel : JSONModel

@property (nonatomic, copy) NSString *id1; // 专题编号
@property (nonatomic, copy) NSString *img; // 专题背景图
@property (nonatomic, copy) NSString *title;  // 专题标题
@property (nonatomic, copy) NSString *create_time; // 创建时间
@property (nonatomic, copy) NSString *update_time; // 更新时间

@end
