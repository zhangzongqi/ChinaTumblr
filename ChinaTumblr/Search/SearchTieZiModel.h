//
//  SearchTieZiModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/18.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface SearchTieZiModel : JSONModel

@property (nonatomic, copy) NSString *id1; // 编号
@property (nonatomic, copy) NSString *uid; // 用户编号
@property (nonatomic, copy) NSString *nickname; // 用户昵称
@property (nonatomic, copy) NSString *type; // 帖子类型
@property (nonatomic, copy) NSString *content; // 内容
@property (nonatomic, copy) NSString *files; // 相关文件
@property (nonatomic, copy) NSString *create_time; // 创建时间

@end
