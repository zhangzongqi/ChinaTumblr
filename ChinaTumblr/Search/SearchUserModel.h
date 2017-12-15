//
//  SearchUserModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/15.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface SearchUserModel : JSONModel

@property (nonatomic, copy) NSString *id1; // 用户编号
@property (nonatomic, copy) NSDictionary *img; // 用户图组
@property (nonatomic, copy) NSString *nickname; // 昵称
@property (nonatomic, copy) NSString *sign; // 签名
@property (nonatomic, copy) NSString *followNum; // 粉丝数量
@property (nonatomic, copy) NSString *noteNum; // 发帖数量
@property (nonatomic, copy) NSArray *topNotes; // 热门帖子


@end
