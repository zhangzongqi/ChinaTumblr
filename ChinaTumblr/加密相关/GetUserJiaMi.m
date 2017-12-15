//
//  GetUserJiaMi.m
//  EasyLink
//
//  Created by 琦琦 on 2017/5/24.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import "GetUserJiaMi.h"

@implementation GetUserJiaMi

+ (NSArray *)getUserTokenAndCgAndKey {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    // 创建单例,获取到用户RSAKey
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *userRsaPublicKey = [user objectForKey:@"severPublicKey"];
    
    // 生成一个16位的AES的key,并保存用于解密服务器返回的信息
    NSString *strAESkey = [NSString set32bitString:16];
    [user setObject:strAESkey forKey:@"aesKey"];
    // 最终加密好的key参数的密文
    NSString *keyMiWenStr = [RSAEncryptor encryptString:strAESkey publicKey:userRsaPublicKey];
    NSLog(@"keyMiWenStr:%@",keyMiWenStr);
    
    
    // 获取当前时间戳，转换成json类型，并用AES进行加密,并做了base64及urlcode转码处理
    NSDate *senddate = [NSDate date];
    NSString *date2 = [NSString stringWithFormat:@"%ld", (long)[senddate timeIntervalSince1970]];
    NSDictionary *cgDic = @{@"requestTime":date2};
    // 最终加密好的cg参数的密文
    NSString *cgMiWenStr = [[MakeJson createJson:cgDic] AES128EncryptWithKey:strAESkey];
    
    NSLog(@"cgMiWenStr:%@",cgMiWenStr);
    
    // 用户token
    NSString *userToken = [user objectForKey:@"token"];
    NSLog(@"userToken%@",userToken);
    
    // 加入数组
    [arr addObject:userToken]; // token
    [arr addObject:keyMiWenStr]; // 加密好的aesKey
    [arr addObject:cgMiWenStr]; // 加密好的cg
    [arr addObject:strAESkey]; // aes密钥
    
    
    return arr;
}

@end
