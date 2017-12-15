//
//  DongTaiModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/20.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface DongTaiModel : JSONModel


@property (nonatomic, copy) NSString *isFocus; // 已关注

@property (nonatomic, copy) NSString *msgId; // 消息编号
@property (nonatomic, copy) NSString *uid;  // 用户编号
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *activityType; // 动作类型
@property (nonatomic, copy) NSString *create_time; // 消息触发时间
@property (nonatomic, copy) NSString *listenUid;

@property (nonatomic, copy) NSString *noteId; // 帖子编号
@property (nonatomic, copy) NSString *noteType; // 帖子类型
@property (nonatomic, copy) NSString *noteFile; // 帖子图片/视频截图 图片的url
@property (nonatomic, copy) NSString *noteContent; // 帖子内容

@property (nonatomic, copy) NSString *commentId; // 评论编号
@property (nonatomic, copy) NSString *commentContent; // 评论内容


@end
