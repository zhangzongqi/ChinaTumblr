//
//  UrlcodeAndBase64.m
//  EasyLink
//
//  Created by 琦琦 on 2017/5/10.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import "UrlcodeAndBase64.h"

@implementation UrlcodeAndBase64

// 拿到的数据先经过urlcode解码再进行base64解码
+ (NSString *)jiemaurlDecodeAndBase64String:(NSString *)str {
    
    NSString *strAfterUrlDecode = [str URLDecodedString];
    
    NSData *data = [GTMBase64 decodeData:[strAfterUrlDecode dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *strJiema = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return strJiema;
}

// 上传数据时，先base64进行编码  再进行urlcode编码
//- (NSString *)bianmaurlCodeAndBase64String:(NSString *)str {
//    
//    
//}

@end
