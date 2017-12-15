//
//  AddressModel.h
//  EasyLink
//
//  Created by 琦琦 on 2017/5/13.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface AddressModel : JSONModel

@property (nonatomic, copy) NSString *title; // 城市名
@property (nonatomic, copy) NSString *id1; // 数据编号
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *pid;
@property (nonatomic, copy) NSString *path;

@end
