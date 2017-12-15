//
//  SearchTieZiWithIdModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/18.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface SearchTieZiWithKeyWordModel : JSONModel

@property (nonatomic, copy) NSString *isfollowUser; // 是否已关注发帖人
@property (nonatomic, copy) NSString *isLike; // 是否已经喜欢
@property (nonatomic, copy) NSString *id1; // 编号
@property (nonatomic, copy) NSString *uid; // 用户编号
@property (nonatomic, copy) NSString *nickname; // 用户昵称
@property (nonatomic, copy) NSString *type; // 帖子类型
@property (nonatomic, copy) NSString *content; // 内容
@property (nonatomic, copy) NSArray *files; // 相关文件
@property (nonatomic, copy) NSString *position; // 地点
@property (nonatomic, copy) NSString *active_num; // 动态数量
@property (nonatomic, copy) NSString *comment_num; // 评论数量
@property (nonatomic, copy) NSString *kwList; // 帖子关联关键词列表
@property (nonatomic, copy) NSString *icon; // 发帖人头像
@property (nonatomic, copy) NSString *create_time; // 创建时间
@property (nonatomic, copy) NSString *update_time; // 更新时间
@property (nonatomic, copy) NSString *private_flag; // 用户是否公开


@end
