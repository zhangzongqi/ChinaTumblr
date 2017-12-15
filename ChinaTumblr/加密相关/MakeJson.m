//
//  MakeJson.m
//  EasyLink
//
//  Created by 琦琦 on 2017/5/10.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import "MakeJson.h"

@implementation MakeJson

// 将字典转换成字符串
+ (NSString *)createJson:(NSDictionary *)dic {
        
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    
    // 去掉两端空格
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *str = [[NSString alloc]initWithString:[mutStr stringByTrimmingCharactersInSet:whiteSpace]];
    
//        NSRange range = {0,jsonString.length};
        //去掉字符串中的空格
//        [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//        
//        NSRange range2 = {0,mutStr.length};
//        
//        //去掉字符串中的换行符
//        [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
        return str;
        
}

// 将json字符串转换成字典
+ (NSDictionary *)createDictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSArray *)createArrWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
}

@end
