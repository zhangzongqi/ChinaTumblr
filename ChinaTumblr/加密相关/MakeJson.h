//
//  MakeJson.h
//  EasyLink
//
//  Created by 琦琦 on 2017/5/10.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MakeJson : NSObject

// 将字典转换成字符串
+ (NSString*)createJson:(NSDictionary*)dic;

// 将json字符串转换成字典
+ (NSDictionary *)createDictionaryWithJsonString:(NSString *)jsonString;

// 将json字符串转换成数组
+ (NSArray *)createArrWithJsonString:(NSString *)jsonString;

@end
