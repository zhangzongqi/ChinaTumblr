//
//  NSString+AES.m
//  iOS_AES
//
//  Created by 琦琦 on 2017/5/8.
//  Copyright © 2017年 cong. All rights reserved.
//

#import "NSString+AES.h"
#import "NSData+AES.h"
#import "NSString+URL.h"
#import "GTMBase64.h"

@implementation NSString(AES)


/**
 *  随机生成16位key
 *
 *  @param size 1
 *
 *  @return 1
 */

+ (NSString *)set32bitString:(int)size

{
    char data[size];
    for (int x=0;x<size;x++)
    {
        int randomint = arc4random_uniform(2);
        if (randomint == 0) {
            data[x] = (char)('a' + (arc4random_uniform(26)));
        }
        else
        {
            data[x] = (char)('0' + (arc4random_uniform(9)));
        }
        
    }
    
    return [[NSString alloc] initWithBytes:data length:size encoding:NSUTF8StringEncoding];
    
}


// 加密   密文已经进行urlencode编码
- (NSString *)AES128EncryptWithKey:(NSString *)key {
    
    NSData *data1 = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    data1 = [data1 AES128EncryptWithKey:key iv:NULL];
    
    
    
    NSString *str = [[NSString alloc] initWithData:[GTMBase64 encodeData:data1] encoding:NSUTF8StringEncoding];
    
    // 进行urlencode编码
//    NSLog(@"加密后密文:%@", [str URLEncodedString]);
    
    return [str URLEncodedString];
}

// 解密
- (NSString *)AES128DecryptWithKey:(NSString *)key {
    
    // 先进行转码
    NSString *str = [self URLDecodedString];
    
    // 转换成NSData
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    // base64
    data = [GTMBase64 decodeData:data];
    
    NSData *data2 = [data AES128DecryptWithKey:key iv:NULL];
    NSString *str2 = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
//    NSLog(@"解密后明文:%@", str2);
    
    return str2;
}

@end
