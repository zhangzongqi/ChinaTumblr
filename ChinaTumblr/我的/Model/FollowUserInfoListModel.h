//
//  FollowUserInfoListModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/19.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface FollowUserInfoListModel : JSONModel

@property (nonatomic, copy) NSString *isfollowUser; // 是否已关注
@property (nonatomic, copy) NSString *followTime; // 被关注记录时间
@property (nonatomic, copy) NSString *id1; //用户编号
@property (nonatomic, copy) NSDictionary *img; //用户图片集合
@property (nonatomic, copy) NSString *nickname; //用户昵称
@property (nonatomic, copy) NSString *sign; //个性签名
@property (nonatomic, copy) NSString *followNum; //粉丝数量
@property (nonatomic, copy) NSString *noteNum; // 发帖数量


@end
