//
//  AllTieZiLingYuModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/12.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface AllTieZiLingYuModel : JSONModel


@property (nonatomic, copy) NSString *isSelected; // 是否选中
@property (nonatomic, copy) NSString *title; // 名称
@property (nonatomic, copy) NSString *id1; // 数据编号
@property (nonatomic, copy) NSString *follow_num; // 订阅人数
@property (nonatomic, copy) NSString *sort; // 排序
@property (nonatomic, copy) NSString *note_num; // 关联发帖数


@end
