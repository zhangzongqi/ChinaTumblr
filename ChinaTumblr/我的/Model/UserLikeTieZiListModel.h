//
//  UserLikeTieZiListModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/17.
//  Copyright © 2017年 张宗琦. All rights reserved.
//  用户喜欢帖子

#import "JSONModel.h"

@interface UserLikeTieZiListModel : JSONModel


@property (nonatomic, copy) NSString *isLike; // 是否喜欢
@property (nonatomic, copy) NSString *love_time; // 喜欢帖子记录时间
@property (nonatomic, copy) NSString *id1; //帖子编号
@property (nonatomic, copy) NSString *uid; //发帖人编号
@property (nonatomic, copy) NSString *nickname; //发帖人昵称
@property (nonatomic, copy) NSString *icon; //发帖人头像图片url
@property (nonatomic, copy) NSString *type; //帖子内容类型
@property (nonatomic, copy) NSString *content; //帖子内容
@property (nonatomic, copy) NSArray *files; // 帖子关联文件地址url字符串列表
@property (nonatomic, copy) NSString *position; //发帖地点（为空或不存在时不显示)
@property (nonatomic, copy) NSString *active_num; //动态数量
@property (nonatomic, copy) NSString *comment_num; //评论数量
@property (nonatomic, copy) NSString *create_time; //发帖时间
@property (nonatomic, copy) NSString *update_time; //更新时间
@property (nonatomic, copy) NSString *kwIdList; //帖子关联关键词编号列表,编号间用英文逗号分隔
@property (nonatomic, copy) NSString *kwList; //帖子关联关键词列表,关键词间用英文逗号分隔
@property (nonatomic, copy) NSString *private_flag; // 用户是否公开
@property (nonatomic, copy) NSString *isfollowUser; // 是否已关注发帖人


@end
