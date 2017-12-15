//
//  ZhuanTiDetailModel.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/11/1.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "ZhuanTiDetailModel.h"

@implementation ZhuanTiDetailModel

// 属性是否可选
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    
    return YES;
}

// 重写此方法 解决借口名字和系统名字冲突问题
+(JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"id1"}];
}

@end
