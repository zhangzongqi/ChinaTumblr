//
//  UrlcodeAndBase64.h
//  EasyLink
//
//  Created by 琦琦 on 2017/5/10.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlcodeAndBase64 : NSObject

// 拿到的数据先经过urlcode解码在进行base64解码
+ (NSString *)jiemaurlDecodeAndBase64String:(NSString *)str;

// 上传数据时，先base64进行编码  再进行urlcode编码
+ (NSString *)bianmaurlCodeAndBase64String:(NSString *)str;

@end
