//
//  TieZiDetail.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/21.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface TieZiDetail : JSONModel


@property (nonatomic, copy) NSString *isfollowUser; // 是否已关注发帖人
@property (nonatomic, copy) NSString *isLike; // 是否已经喜欢

@property (nonatomic, copy) NSString *id1;  // 用户编号
@property (nonatomic, copy) NSString *uid; // 用户编号
@property (nonatomic, copy) NSString *nickname; // 昵称
@property (nonatomic, copy) NSString *icon; // 头像
@property (nonatomic, copy) NSString *type; // 动作类型
@property (nonatomic, copy) NSString *content; // 内容
@property (nonatomic, copy) NSArray *files;

@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *active_num; //
@property (nonatomic, copy) NSString *comment_num;
@property (nonatomic, copy) NSString *private_flag; //

@property (nonatomic, copy) NSString *create_time; //
@property (nonatomic, copy) NSString *kwIdList; //
@property (nonatomic, copy) NSString *kwList;



//"active_num" = 0;
//"comment_num" = 0;
//content = 1234;
//"create_time" = 1505875352;
//files = 681;
//id = 73;
//img = "{\"icon\":\"633\",\"background\":\"634\"}";
//kwIdList = 5;
//kwList = "\U97f3\U4e50";
//nickname = "\U897f\U53e4\U5f00\U6e90";
//position = "\U9752\U5c9b\U5e02";
//"private_flag" = 0;
//type = 1;
//uid = 11;


@end
