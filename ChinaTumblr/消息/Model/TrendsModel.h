//
//  TrendsModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/20.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface TrendsModel : JSONModel


@property (nonatomic, copy) NSString *uid; // 用户编号
@property (nonatomic, copy) NSString *nickname; // 用户昵称
@property (nonatomic, copy) NSString *icon;  // 用户头像图片url
@property (nonatomic, copy) NSString *activityType; // 动作类型
@property (nonatomic, copy) NSString *create_time; // 动态时间
@property (nonatomic, copy) NSArray *actionTargetList; // 动态操作对象信息列表


@end
