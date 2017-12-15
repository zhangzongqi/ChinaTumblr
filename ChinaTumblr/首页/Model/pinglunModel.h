//
//  pinglunModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/18.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface pinglunModel : JSONModel

@property (nonatomic, copy) NSString *id1; // 评论编号
@property (nonatomic, copy) NSString *pid; // 被回复评论编号
@property (nonatomic, copy) NSString *noteId; // 被评论帖子编号
@property (nonatomic, copy) NSString *nickname; // 发表评论人昵称
@property (nonatomic, copy) NSString *create_time; // 评论时间
@property (nonatomic, copy) NSString *uid; // 发表评论人编号
@property (nonatomic, copy) NSString *content; // 内容
@property (nonatomic, copy) NSString *icon; // 发表评论人头像图片url
@property (nonatomic, copy) NSString *rootId; // 顶级评论编号
@property (nonatomic, copy) NSString *targetUid; // 被回复人编号
@property (nonatomic, copy) NSString *targetNickname; // 被回复人昵称


@end
