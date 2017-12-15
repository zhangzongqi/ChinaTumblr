//
//  TieZiModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/16.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface TieZiModel : JSONModel

@property (nonatomic, copy) NSString *id1; // 帖子编号
@property (nonatomic, copy) NSString *uid; // 发帖人编号
@property (nonatomic, copy) NSString *icon; // 发帖人头像
@property (nonatomic, copy) NSString *type; // 帖子类型
@property (nonatomic, copy) NSString *content; // 帖子内容
@property (nonatomic, copy) NSString *files; // 帖子关联文件
@property (nonatomic, copy) NSString *position; // 发帖地点
@property (nonatomic, copy) NSString *active_num; // 动态数量
@property (nonatomic, copy) NSString *comment_num; // 评论数量

@end
