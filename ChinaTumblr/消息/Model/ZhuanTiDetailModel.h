//
//  ZhuanTiDetailModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/11/1.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface ZhuanTiDetailModel : JSONModel


@property (nonatomic, copy) NSString *id1; // 编号
@property (nonatomic, copy) NSString *img; // 图片
@property (nonatomic, copy) NSString *title; // 标题
@property (nonatomic, copy) NSString *type; // 类型
@property (nonatomic, copy) NSString *content; // 内容详情
@property (nonatomic, copy) NSString *create_time; // 创建时间
@property (nonatomic, copy) NSString *update_time; // 更新时间


@end
