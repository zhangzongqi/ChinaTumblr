//
//  NSString+AES.h
//  iOS_AES
//
//  Created by 琦琦 on 2017/5/8.
//  Copyright © 2017年 cong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(AES)

//加密
- (NSString *)AES128EncryptWithKey:(NSString *)key;


//解密
- (NSString *)AES128DecryptWithKey:(NSString *)key;


// 生成key
+ (NSString *)set32bitString:(int)size;

@end
