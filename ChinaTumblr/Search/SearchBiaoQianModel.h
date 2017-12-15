//
//  SearchBiaoQianModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/16.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface SearchBiaoQianModel : JSONModel

@property (nonatomic, copy) NSString *id1; // 编号
@property (nonatomic, copy) NSString *title; // 标题
@property (nonatomic, copy) NSString *follow_num; // 粉丝数量
@property (nonatomic, copy) NSString *note_num; // 发帖数量

@end
