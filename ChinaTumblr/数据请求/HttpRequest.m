//
//  HttpRequest.m
//  EasyLink
//
//  Created by 琦琦 on 2017/5/2.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import "HttpRequest.h"
#import "LoginViewController.h" // 登录页面
#import "AppDelegate.h"
#import "JPUSHService.h" // 极光推送

@implementation HttpRequest {
    
    MBProgressHUD *_HUD;
    
}

+ (void)postWithURL:(NSString *)str andDic:(NSDictionary *)dic success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure {
    
    //1.创建请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    
    manager.requestSerializer.timeoutInterval = 7.f;
    
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager POST:str parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(error);
        }
    }];
}

// 获取公共rsa公钥
- (void) GetRSAPublicKeySuccess:(void(^)(id strPublickey))success failure:(void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/System/getRsaPublicKey"];
    
    [HttpRequest postWithURL:str andDic:nil success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *strPublicKey = [[NSString alloc]init];
            
            if (success) {
                
                success(strPublicKey);
            }
            
        }else {
            
            NSDictionary *DataDic = [dic objectForKey:@"data"];
            
            NSString *strPublicKey = [DataDic objectForKey:@"rsa_public_key"];
            
            if (success) {
                
                success(strPublicKey);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];

        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取公钥接口请求失败");
    }];
}


// 获取验证码
- (void) PostPhoneCodeWithDic:(NSDictionary *)datedic Success:(void(^)(id status))success failure:(void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/sendSmsVerifyCode"];
    
    [HttpRequest postWithURL:str andDic:datedic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            HttpRequest *http = [[HttpRequest alloc] init];
            
            NSString *message = [dic objectForKey:@"msg"];
            NSLog(@"message:%@",message);
            NSString *errorCode = [dic objectForKey:@"errorCode"];
            NSLog(@"errorCode:%@",errorCode);
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
            switch ([errorCode integerValue]) {
                case 1002: {
                    
                    [http GetHttpDefeatAlert:message];
                }
                    break;
                case 1003: {
                    
                    [http GetHttpDefeatAlert:message];
                }
                    break;
                case 1004: {
                    
                    [http GetHttpDefeatAlert:message];
                }
                    break;
                case 1005: {
                    
                    [http GetHttpDefeatAlert:message];
                }
                    break;
                case 1009: {
                    
                    [http GetHttpDefeatAlert:message];
                }
                    break;
                    
                default:{
                    
                    [http GetHttpDefeatAlert:@"获取验证码失败,请稍后再试"];
                }
                    break;
            }
            
        }else {
            
            NSString *message = [dic objectForKey:@"msg"];
            
            if (success) {
                
                success(message);
            }
        }
        
    } failure:^(NSError *error) {
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取验证码接口请求失败");
    }];

}


// 注册
- (void) PostRegisterWithDic:(NSDictionary *)datedic Success:(void(^)(id userDataJsonStr))success failure:(void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/regist"];
    
    [HttpRequest postWithURL:str andDic:datedic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *message = [dic valueForKey:@"msg"];
            NSLog(@"message:%@",message);
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorCode:%@",errorCode);
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
                
                NSLog(@"message:%@",message);
                
            }
            
            // 提示注册失败
            HttpRequest *http = [[HttpRequest alloc] init];
            [http GetHttpDefeatAlert:message];
            
        }else {
            
            NSString *message = [dic objectForKey:@"msg"];
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [dataDic objectForKey:@"key"];
            //
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [dataDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            
            
            if (success) {
                
                success(userData2);
                
                NSLog(@"message:%@",message);
                
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"注册接口请求失败");
    }];
}


// 登录
- (void) PostLoginWithDic:(NSDictionary *)datedic Success:(void(^)(id userDataJsonStr))success failure:(void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/login"];
    
    [HttpRequest postWithURL:str andDic:datedic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *message = [dic valueForKey:@"msg"];
            HttpRequest *alert = [[HttpRequest alloc] init];
            [alert GetHttpDefeatAlert:message];
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorCode:%@",errorCode);
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
                
                NSLog(@"message:%@",message);
                
            }
            
            
        }else {
            
            NSString *message = [dic objectForKey:@"msg"];
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [dataDic objectForKey:@"key"];
            //
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            NSLog(@"keyForSever:%@",keyForSever);
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [dataDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            
            
            if (success) {
                
                success(userData2);
                
                NSLog(@"message:%@",message);
                
            }
        }
        
    } failure:^(NSError *error) {
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"登录接口请求失败");
    }];
}

// 核对验证码
- (void) PostCheckCodeWithDic:(NSDictionary *)datedic Success:(void(^)(id confirmCode))success failure:(void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/checkSmsVerifyCode"];
    
    [HttpRequest postWithURL:str andDic:datedic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *message = [[NSString alloc]init];
            NSLog(@"message:%@",message);
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorCode:%@",errorCode);
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
                
                NSLog(@"message:%@",message);
                
            }
            
            switch ([errorCode integerValue]) {
                case 1006:
                {
                    
                    // 提示验证失败
                    HttpRequest *http = [[HttpRequest alloc] init];
                    [http GetHttpDefeatAlert:@"验证码错误,请重试"];
                }
                    break;
                
                    
                default: {
                    
                    // 提示验证失败
                    HttpRequest *http = [[HttpRequest alloc] init];
                    [http GetHttpDefeatAlert:@"验证失败,请稍后重试"];
                }
                    break;
            }
            
            
        }else {
            
            NSString *message = [dic objectForKey:@"msg"];
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            
            NSString *strCode1 = [dataDic objectForKey:@"confirm_code"];
            NSLog(@"strcode:%@",strCode1);
            
            
            // 获取到请求时保留的AES的key进行解密
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSLog(@"aesKey:%@",[user objectForKey:@"aesKey"]);
            NSString *strCode = [strCode1 AES128DecryptWithKey:[user objectForKey:@"aesKey"]];
            NSLog(@"strCode:%@",strCode);
            
            if (success) {
                
                success(strCode);
                
                NSLog(@"message:%@",message);
                
            }
        }
        
    } failure:^(NSError *error) {
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"核对验证码接口请求失败");
    }];
}


// 重置密码
- (void) PostResetPassWordWithDic:(NSDictionary *)datadic Success:(void(^)(id resetMessage))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/resetPwd"];
    
    [HttpRequest postWithURL:str andDic:datadic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *message = [dic objectForKey:@"msg"];
            NSLog(@"message:%@",message);
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorCode:%@",errorCode);
            
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
                
                NSLog(@"message:%@",message);
            }
            
            // 提示密码重置失败
            HttpRequest *http = [[HttpRequest alloc] init];
            [http GetHttpDefeatAlert:message];
            
        }else {
            
            NSString *message = [dic objectForKey:@"msg"];
            
            
            if (success) {
                
                success(message);
                
                NSLog(@"message:%@",message);
                
            }
        }
        
    } failure:^(NSError *error) {
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"重置密码接口请求失败");
    }];
}


// 修改密码
- (void) PostRevisePassWordWithDic:(NSDictionary *)datadic Success:(void(^)(id resetMessage))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/modifyPwd"];
    
    [HttpRequest postWithURL:str andDic:datadic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *message = [dic valueForKey:@"msg"];
//            NSLog(@"message:%@",message);
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorCode:%@",errorCode);
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
                
                NSLog(@"message:%@",message);
                
            }
            
            // 提示密码重置失败
            HttpRequest *http = [[HttpRequest alloc] init];
            [http GetHttpDefeatAlert:message];
            
        }else {
            
            NSString *message = [dic objectForKey:@"msg"];
            
            
            if (success) {
                
                success(message);
                
                NSLog(@"message:%@",message);
                
            }
        }
        
    } failure:^(NSError *error) {
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"修改密码接口请求失败");
    }];
}

// 获取城市
- (void) GetAddressWithPid:(NSString *)strPid Success:(void(^)(id addressMessage))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *str = [NSString stringWithFormat:@"/System/getRegionList?pid=%ld",[strPid integerValue]];
    
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,str];
    
    [HttpRequest postWithURL:path andDic:nil success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:@"获取城市列表失败"];
            
            NSString *str = [[NSString alloc]init];
            
            if (success) {
                
                success(str);
            }
            
        }else {
            
            NSMutableArray *mutarrForData = [[NSMutableArray alloc] init];
            
            NSArray *arrForData = [dic valueForKey:@"data"];
            
            for (int i = 0; i<arrForData.count; i++) {
                
                NSDictionary *dicForData = [arrForData objectAtIndex:i];
                
                [mutarrForData addObject:dicForData];
            }
            
            NSMutableArray *arrForAddress = [AddressModel arrayOfModelsFromDictionaries:mutarrForData error:nil];
            
            if (success) {
                
                success(arrForAddress);
            }
        }
    } failure:^(NSError *error) {
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        // 提示获取数据失败
        NSLog(@"获取城市接口请求失败");
        
    }];
}

// 获取用户资料
- (void) PostUserInfoWithDic:(NSDictionary *)userInfoDic Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/getUserInfo"];
    
    [HttpRequest postWithURL:path andDic:userInfoDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        
        if (statusInt == 0) {
            
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            
            NSLog(@"userData2:%@",userData2);
            
            if (success) {
                
                success(userData2);
            }
        }
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络请求错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户资料网络请求失败");
    }];
}


// 修改用户图像
- (void)testUploadImageWithPost:(NSDictionary *)dic andImg:(UIImage *)image Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure{
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/modifyUserImg"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain", nil];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //    NSString *imagePath = [[NSBundle mainBundle]pathForResource:@"hehe.jpg" ofType:nil];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    //    NSData *data = [NSData dataWithContentsOfFile:image];
    
    [manager POST:path parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData name:@"img" fileName:@"test.jpg"mimeType:@"image/jpg"];
        
    }success:^(NSURLSessionDataTask *operation,id responseObject) {
        
        NSLog(@"==============%@",responseObject);
        NSString *str = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"msg"]];
        NSLog(@"====%@",str);
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"status"]] isEqualToString:@"0"]) {
            
            
            NSString *errorCode = [responseObject objectForKey:@"errorCode"];
            
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            if (success) {
                success([NSString stringWithFormat:@"%@",[responseObject objectForKey:@"status"]]);
            }
            
        }else {
            
            if (success) {
                success(responseObject);
            }
        }
        
        
    }failure:^(NSURLSessionDataTask *operation,NSError *error) {
        
        NSLog(@"#######upload error%@", error);
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"上传头像网络请求失败");
    }];
    
}


// 上传图片
- (void) PostImgToServerWithUserInfo:(NSDictionary *)dic andImg:(UIImage *)image Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/System/uploadPic"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain", nil];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [manager POST:path parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
        
        [formData appendPartWithFileData:imageData name:@"img" fileName:@"test.jpg"mimeType:@"image/jpg"];
        
    }success:^(NSURLSessionDataTask *operation,id responseObject) {
        
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"status"]] isEqualToString:@"0"]) {
            
            NSString *errorCode = [responseObject objectForKey:@"errorCode"];
            NSLog(@"errorCode,%@",errorCode);
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 上传失败，提示信息
            HttpRequest *httpAlert = [[HttpRequest  alloc] init];
            [httpAlert GetHttpDefeatAlert:@"图片上传失败,请稍后再试"];
            
            if (success) {
                success(@"false");
            }
            
        }else {
            
            NSDictionary *dic = [responseObject objectForKey:@"data"];
            NSString *str = [dic objectForKey:@"id"];
            
            // 上传成功
            if (success) {
                success(str);
            }
        }
        
    }failure:^(NSURLSessionDataTask *operation,NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        NSLog(@"#######upload error%@", error);
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"上传图片接口请求失败");
    }];
}


// 上传视频
- (void) PostVideoToServerWithUserInfo:(NSDictionary *)dic andImg:(UIImage *)image andVideo:(NSURL *)videoURL Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure; {
    
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/System/uploadVideo"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain", nil];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    
    
    
    [manager POST:path parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData name:@"cover" fileName:@"test.jpg"mimeType:@"image/jpg"];
        [formData appendPartWithFileData:videoData name:@"video" fileName:@"video.mp4" mimeType:@"video/mpeg"];
        
    }success:^(NSURLSessionDataTask *operation,id responseObject) {
        
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"status"]] isEqualToString:@"0"]) {
            
            NSString *errorCode = [responseObject objectForKey:@"errorCode"];
            NSLog(@"errorCode,%@",errorCode);
            NSString *msg = [responseObject objectForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 上传失败，提示信息
            HttpRequest *httpAlert = [[HttpRequest  alloc] init];
            [httpAlert GetHttpDefeatAlert:msg];
            NSLog(@"*********%@",msg);
            
            if (success) {
                success(@"false");
            }
            
        }else {
            
            NSDictionary *dic = [responseObject objectForKey:@"data"];
            NSString *str = [dic objectForKey:@"id"];
            
            NSLog(@"成功，成功，成功");
            
            NSLog(@"%@",dic);
            
            // 上传成功
            if (success) {
                success(str);
            }
        }
        
    }failure:^(NSURLSessionDataTask *operation,NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        NSLog(@"#######upload error%@", error);
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"上传图片接口请求失败");
    }];
}


// 上传评价
- (void) PostAddPingjiaWithDic:(NSDictionary *)userInfoDic Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Order_addComment"];

    
    [HttpRequest postWithURL:path andDic:userInfoDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        
        if (statusInt == 0) {
            
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示上传评价失败
            [alert GetHttpDefeatAlert:msg];
            
            
            if (success) {
                
                
            }
            
        }else {
            
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            
//            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示上传评价成功
//            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success(@"1");
            }
        }
    } failure:^(NSError *error) {
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"上传评价接口请求失败");
    }];

}


// 修改用户资料
- (void) PostReviseUserInfoWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/modifyUserInfo"];
    
    [HttpRequest postWithURL:path andDic:userInfoData success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            
            if (success) {
                
                success(msg);
            }
            
        }else {
            
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            
            
            NSLog(@"userData2:%@",userData2);
            
            
            if (success) {
                
                success(userData2);
            }
        }
    } failure:^(NSError *error) {
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"修改用户资料接口请求失败");
        
    }];
}

// 获取用户中心可见页面配置参数
- (void) PostGetShowPageTabConfigWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/getShowPageTabConfig"];
    
    [HttpRequest postWithURL:path andDic:userInfoData success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 弹出提示
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            NSLog(@"msg:%@",msg);
            
            
            if (success) {
                
                success(@"flase");
            }
            
        }else {
            
            // 字典
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            
            
            NSLog(@"userData2:%@",userData2);
            
            NSString *jieguo = [[MakeJson createDictionaryWithJsonString:userData2] valueForKey:@"showPage"];
            
            
            if (success) {
                
                success(jieguo);
            }
        }
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户中心可见页面配置参数接口请求失败");
        
    }];
}

// 配置用户中心可见页面
- (void) PostSetShowPageTabConfigWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/setShowPageTabConfig"];
    
    [HttpRequest postWithURL:path andDic:userInfoData success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 弹出提示
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            
            if (success) {
                
                // 失败
                success(@"0");
            }
            
        }else {
            
            
            if (success) {
                
                // 成功
                success(@"1");
            }
        }
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"配置用户中心可见页面接口请求失败");
        
    }];
}


// 添加用户关注
- (void) PostAddFollowUserWithDic:(NSDictionary *)userInfoDic Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/addFollowUser"];
    
    [HttpRequest postWithURL:path andDic:userInfoDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        
        if (statusInt == 0) {
            
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"添加用户关注msg:%@",msg);
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示信息
            [alert GetHttpDefeatAlert:msg];
            
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            if (success) {
                
                success(@"1");
            }
        }
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"添加用户关注接口请求失败");
    }];
}

// 添加不喜欢用户
- (void) PostAddDislikeUserWithDic:(NSDictionary *)userInfoDic Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/addDislikeUser"];
    
    [HttpRequest postWithURL:path andDic:userInfoDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        
        if (statusInt == 0) {
            
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"添加添加不喜欢用户msg:%@",msg);
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示信息
            [alert GetHttpDefeatAlert:msg];
            
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            if (success) {
                
                success(msg);
            }
        }
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"添加不喜欢用户接口请求失败");
    }];
}

// 移除不喜欢用户
- (void) PostDelDislikeUserWithDic:(NSDictionary *)userInfoDic Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure {
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/delDislikeUser"];
    
    [HttpRequest postWithURL:path andDic:userInfoDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        
        if (statusInt == 0) {
            
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"添加添加不喜欢用户msg:%@",msg);
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示信息
            [alert GetHttpDefeatAlert:msg];
            
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            if (success) {
                
                success(@"1");
            }
        }
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"移除不喜欢用户接口请求失败");
    }];
}

// 移除用户关注
- (void) PostDelFollowUserWithDic:(NSDictionary *)userInfoDic Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/delFollowUser"];
    
    [HttpRequest postWithURL:path andDic:userInfoDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        
        if (statusInt == 0) {
            
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"移除用户关注msg:%@",msg);
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示信息
            [alert GetHttpDefeatAlert:msg];
            
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            if (success) {
                
                success(@"1");
            }
        }
    } failure:^(NSError *error) {
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"移除用户关注接口请求失败");
    }];
}


// 获取用户所有关注的用户的编号
- (void) PostGetAllFollowUserIdListWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/getAllFollowUserIdList"];
    
    [HttpRequest postWithURL:path andDic:userInfoData success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
//            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
//            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success(@"error");
            }
            
        }else {
            
            
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            NSLog(@"userData2:%@",userData2);
            
            
            if (success) {
                
                success(userData2);
            }
        }
        
    } failure:^(NSError *error) {
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户所有关注的用户的编号接口请求失败");
    }];
}


// 获取关注的用户信息列表
- (void) PostGetFollowUserInfoListWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/getFollowUserInfoList"];
    
    [HttpRequest postWithURL:path andDic:userInfoData success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            NSArray *arr = [NSArray array];
            
            if (success) {
                
                success(arr);
            }
            
        }else {
            
            
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            NSLog(@"userData2:%@",userData2);
            
            
            NSArray *arrData = [MakeJson createArrWithJsonString:userData2];
            
            
            // 最终拿到的数据
            NSMutableArray *arrSearchUserInfoList = [FollowUserInfoListModel arrayOfModelsFromDictionaries:arrData error:nil];
            
            if (success) {
                
                success(arrSearchUserInfoList);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取关注的用户信息列表接口请求失败");
    }];
    
}


// 获取指定用户所关注的用户列表分页数据 ***
- (void) PostGetFollowUserInfoListForUcenterWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/getFollowUserInfoListForUcenter"];
    
    [HttpRequest postWithURL:path andDic:userInfoData success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            NSArray *arr = [NSArray array];
            
            if (success) {
                
                success(arr);
            }
            
        }else {
            
            
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            NSLog(@"拿到的公钥：%@",strSeverKey);
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            NSLog(@"userData2:%@",userData2);
            
            
            NSArray *arrData = [MakeJson createArrWithJsonString:userData2];
            
            
            // 最终拿到的数据
            NSMutableArray *arrSearchUserInfoList = [FollowUserInfoListModel arrayOfModelsFromDictionaries:arrData error:nil];
            
            if (success) {
                
                success(arrSearchUserInfoList);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
        //        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取指定用户所关注的用户列表分页数据接口请求失败");
    }];
    
}


// 获取粉丝信息列表
- (void) PostGetFollowerUserInfoListWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/getFollowerUserInfoList"];
    
    [HttpRequest postWithURL:path andDic:userInfoData success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            NSLog(@"userData2:%@",userData2);
            
            
            if (success) {
                
                success(userData2);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取获取粉丝信息列表接口请求失败");
    }];
}

// 获取用户不喜欢的用户
- (void) PostGetDislikeUserInfoListWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/getDislikeUserInfoList"];
    
    [HttpRequest postWithURL:path andDic:userInfoData success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            NSLog(@"userData2:%@",userData2);
            
            
            if (success) {
                
                success(userData2);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户不喜欢的用户接口请求失败");
    }];
}


// 添加用户意见反馈
- (void) PostAddUserFeedbackWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/addUserFeedback"];
    
    [HttpRequest postWithURL:path andDic:userInfoData success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 提示消息
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 提示消息
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success(@"1");
            }
        }
        
    } failure:^(NSError *error) {
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"添加用户意见反馈接口请求失败");
    }];
}

// 搜索用户
- (void) PostSearchUserWithKeyword:(NSString *)keyword andPageStart:(NSString *)pageStart andPageSize:(NSString *)pageSize Success:(void(^)(id userListInfo))success failure:(void(^)(NSError *error))failure {
    
    NSString *str = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *StrUrl = [NSString stringWithFormat:@"/User/getUserListLike?keyword=%@&pageStart=%@&pageSize=%@",str,pageStart,pageSize];
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,StrUrl];
    
    [HttpRequest postWithURL:path andDic:nil success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 提示消息
//            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
//            [alert GetHttpDefeatAlert:msg];
            NSLog(@"%@",msg);
            
            NSArray *arr = [NSArray array];
            
            if (success) {
                
                success(arr);
            }
            
        }else {
            
            // 拿到的数据
            NSArray *UserListArr = [dic objectForKey:@"data"];
            
            NSMutableArray *arrSearchUserInfoList = [SearchUserModel arrayOfModelsFromDictionaries:UserListArr error:nil];
            
            if (success) {
                
                success(arrSearchUserInfoList);
            }
        }
        
    } failure:^(NSError *error) {
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"搜索用户接口请求失败");
    }];
}


// 获取搜索结果页面推荐用户列表
- (void) PostGetUserListRecommendForSearchWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/getUserListRecommendForSearch"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 提示消息
//            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
//            [alert GetHttpDefeatAlert:msg];
            NSLog(@"%@",msg);
            
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            
            // 拿到的数据
            NSDictionary *UserListDic = [dic objectForKey:@"data"];
            
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [UserListDic objectForKey:@"key"];
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [UserListDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            NSLog(@"userData2:%@",userData2);
            NSArray *arr = [MakeJson createArrWithJsonString:userData2];
            
            // 最终拿到的数据数组
            NSArray *arrSearchTuijianUserInfoList = [SearchUserModel arrayOfModelsFromDictionaries:arr error:nil];
            
            if (success) {
                
                success(arrSearchTuijianUserInfoList);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取搜索结果页面推荐用户列表接口请求失败");
    }];
}


// 获取所有帖子领域
- (void) GetFieldListSuccess:(void(^)(id fieldList))success failure:(void (^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/KeyWords/getFieldList"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:nil success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            if (success) {
                
                success(status);
            }
            
        }else {
            
            // 拿到的数据
            NSArray *FieldListArr = [dic objectForKey:@"data"];
            
            NSMutableArray *arrFieldList = [AllTieZiLingYuModel arrayOfModelsFromDictionaries:FieldListArr error:nil];
            
            if (success) {
                
                success(arrFieldList);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取所有帖子领域失败接口请求失败");
    }];
}

// 获取用户所订阅的所有领域的编号
- (void) PostGetAllFollowFieldIdListWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/KeyWords/getAllFollowFieldIdList"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
//            NSLog(@"请求失败啦");
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            if (success) {
                success(@"false");
            }
            
        }else {
            
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            NSLog(@"userData2:%@",userData2);
            
            
            if (success) {
                
                success(userData2);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
 
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户所订阅的所有领域的编号接口请求失败");
    }];
}


// 绑定用户喜欢领域
- (void) PostBindFieldWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/KeyWords/bindField"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            HttpRequest *httpAlert = [[HttpRequest alloc] init];
            [httpAlert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            if (success) {
                
                success(@"1");
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"绑定用户喜欢领域接口请求失败");
    }];
}


// 获取用户订阅的所有关键词编号
- (void) PostGetAllFollowKeywordIdListWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/KeyWords/getAllFollowKeywordIdList"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            NSArray *arr = [NSArray array];
            
            // 传入空数组
            if (success) {
                success(arr);
            }
            
        }else {
            
            
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            NSLog(@"userData2:%@",userData2);
            
            NSArray *arr = [userData2 componentsSeparatedByString:@","];
            
            if (success) {
                
                success(arr);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户订阅的所有关键词编号接口请求失败");
    }];
}


// 获取用户所有订阅关键词
- (void) PostGetAllFollowKeywordListWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/KeyWords/getAllFollowKeywordList"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 提示消息
            HttpRequest *httpAlert = [[HttpRequest alloc] init];
            [httpAlert GetHttpDefeatAlert:msg];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            if (success) {
                success(@"0");
            }
            
        }else {
            
            
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            NSLog(@"userData2:%@",userData2);
            
            
            NSArray *endGetArr = [MakeJson createArrWithJsonString:userData2];
            
            NSMutableArray *arrFieldList = [AllTieZiLingYuModel arrayOfModelsFromDictionaries:endGetArr error:nil];
            
            
            if (success) {
                
                success(arrFieldList);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户所有订阅关键词接口请求失败");
    }];
}


// 用户订阅关键词
- (void) PostFollowKeywordWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/KeyWords/followKeyword"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            HttpRequest *httpAlert = [[HttpRequest alloc] init];
            [httpAlert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            // 订阅成功
            
            if (success) {
                
                success(@"1");
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"用户订阅关键词接口请求失败");
    }];
}

// 用户取消关键词订阅
- (void) PostRemoveFollowKeywordWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/KeyWords/removeFollowKeyword"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            HttpRequest *httpAlert = [[HttpRequest alloc] init];
            [httpAlert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            // 取消订阅成功
            if (success) {
                
                success(@"1");
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"用户取消关键词订阅接口请求失败");
    }];
}

// 获取检索相关关键词结果
- (void) GetKeyWordListLikeWithKeyword:(NSString *)keyword andPageStart:(NSString *)pageStart andPageSize:(NSString *)pageSize Success:(void(^)(id userListInfo))success failure:(void(^)(NSError *error))failure {
    
    NSString *str = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *StrUrl = [NSString stringWithFormat:@"/KeyWords/getKeyWordListLike?keyword=%@&pageStart=%@&pageSize=%@",str,pageStart,pageSize];
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,StrUrl];
    
    [HttpRequest postWithURL:path andDic:nil success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 提示消息
            //            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            //            [alert GetHttpDefeatAlert:msg];
            NSLog(@"%@",msg);
            
            NSArray *arr = [NSArray array];
            
            if (success) {
                
                success(arr);
            }
            
        }else {
            
            // 拿到的数据
            NSArray *UserListArr = [dic objectForKey:@"data"];
            
            NSMutableArray *arrSearchUserInfoList = [SearchBiaoQianModel arrayOfModelsFromDictionaries:UserListArr error:nil];
            
            if (success) {
                
                success(arrSearchUserInfoList);
            }
        }
        
    } failure:^(NSError *error) {
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"搜索用户接口请求失败");
    }];
}


// 发布帖子
- (void) PostAddNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/addNote"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 发帖失败
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            HttpRequest *httpAlert = [[HttpRequest alloc] init];
            [httpAlert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            // 发帖成功
            if (success) {
                
                success(@"1");
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"发布帖子接口请求失败");
    }];
}


// 修改帖子
- (void) PostEditNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/editNote"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 发帖失败
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            HttpRequest *httpAlert = [[HttpRequest alloc] init];
            [httpAlert GetHttpDefeatAlert:msg];
            NSLog(@"msg:%@",msg);
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            // 发帖成功
            if (success) {
                
                success(@"1");
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"修改帖子接口请求失败");
    }];
}


// 删除帖子
- (void) PostDelNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/delNote"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 删除失败
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            HttpRequest *httpAlert = [[HttpRequest alloc] init];
            [httpAlert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            // 删除成功
            if (success) {
                
                success(@"1");
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"删除帖子接口请求失败");
    }];
}

// 获取帖子详情
- (void) PostShowNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/showNote"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            NSArray *arr =[NSArray array];
            
            if (success) {
                
                success(arr);
            }
            
        }else {
            
            
            NSDictionary *dic1 = [dic valueForKey:@"data"];
            
            NSLog(@"::::::::::::::::%@",dic1);
            
            NSArray *arr = @[dic1];
            
            // 帖子详情模型
            NSMutableArray *endDataArr = [TieZiDetail arrayOfModelsFromDictionaries:arr error:nil];
            
            if (success) {
                
                success(endDataArr);
            }
            
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取帖子详情接口请求失败");
    }];
}

// 获取用户所有喜欢的帖子编号
- (void) PostGetAllLoveNoteIdListWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/getAllLoveNoteIdList"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 打印提示
            NSLog(@"msg:%@",msg);
            
            if (success) {
                
                success(@"error");
            }
            
        }else {
            
            
            NSDictionary *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [arrForDic objectForKey:@"key"];
            
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [arrForDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            NSLog(@"userData2:%@",userData2);
            
            
            if (success) {
                
                success(userData2);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        
        NSLog(@"获取用户所有喜欢的帖子编号接口请求失败");
    }];
}

// 获取用户喜欢帖子
- (void) PostGetLoveNoteListWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/getLoveNoteList"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            
            NSArray *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 用户喜欢帖子的Model还没有
            NSMutableArray *endDataArr = [UserLikeTieZiListModel arrayOfModelsFromDictionaries:arrForDic error:nil];
            
            if (success) {
                
                success(endDataArr);
            }
            
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户喜欢帖子接口请求失败");
    }];
}


// 获取用户喜欢帖子列表分页数据 ***
- (void) PostGetLoveNoteListForUcenterWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/getLoveNoteListForUcenter"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            
            NSArray *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 用户喜欢帖子的Model
            NSMutableArray *endDataArr = [UserLikeTieZiListModel arrayOfModelsFromDictionaries:arrForDic error:nil];
            
            if (success) {
                
                success(endDataArr);
            }
            
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        //        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户喜欢帖子列表分页数据接口请求失败");
    }];
}



// 获取用户发布的帖子
- (void) PostGetNoteListByUserWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {

    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/getNoteListByUser"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            
            NSArray *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 用户喜欢帖子的Model还没有
            NSMutableArray *endDataArr = [SearchTieZiWithKeyWordModel arrayOfModelsFromDictionaries:arrForDic error:nil];
            
            if (success) {
                
                success(endDataArr);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户发布的帖子接口请求失败");
    }];
    
}


// 获取用户发布的帖子列表分页数据 ***
- (void) PostGetNoteListByUserForUcenterWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/getNoteListByUserForUcenter"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            
            NSArray *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 用户喜欢帖子的Model还没有
            NSMutableArray *endDataArr = [SearchTieZiWithKeyWordModel arrayOfModelsFromDictionaries:arrForDic error:nil];
            
            if (success) {
                
                success(endDataArr);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        //        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户发布的帖子列表分页数据接口请求失败");
    }];
    
}


// 获取当前用户首页关注的用户和自己发布的帖子
- (void) PostGetNoteListByFollowUserWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/getNoteListByFollowUser"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
//            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
//            [alert GetHttpDefeatAlert:msg];
            NSLog(@"msg%@",msg);
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            
            NSArray *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 用户喜欢帖子的Model
            NSMutableArray *endDataArr = [UserLikeTieZiListModel arrayOfModelsFromDictionaries:arrForDic error:nil];
            
            if (success) {
                
                success(endDataArr);
            }
            
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取当前用户首页关注的用户和自己发布的帖子接口请求失败");
    }];
}


// 获取当前用户首页中帖子列表分页数据 ***
- (void) PostGetNoteListPageForHomeWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/getNoteListPageForHome"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            //
            //            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            //            [alert GetHttpDefeatAlert:msg];
            NSLog(@"msg%@",msg);
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            
            NSArray *arrForDic = [dic valueForKey:@"data"];
            
            NSLog(@"arrForDic:%@",arrForDic);
            
            // 用户喜欢帖子的Model
            NSMutableArray *endDataArr = [UserLikeTieZiListModel arrayOfModelsFromDictionaries:arrForDic error:nil];
            
            if (success) {
                
                success(endDataArr);
            }
            
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        //        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取当前用户首页中帖子列表分页数据接口请求失败");
    }];
}



// 获取关键词绑定帖子
- (void) PostGetNoteListByKeywordWithDataDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/getNoteListByKeyword"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSLog(@"*********%@",status);
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 提示消息
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            NSLog(@"%@",msg);
            
            NSDictionary *dic = @{@"kwId":@"flase"};
            
            if (success) {
                
                success(dic);
            }
            
        }else {
            
            // 拿到的数据
            NSDictionary *UserListDic = [dic objectForKey:@"data"];
            
            if (success) {
                success(UserListDic);
            }
            
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取关键词绑定帖子接口请求失败");
    }];
}


// 获取检索相关帖子结果
- (void) PostGetNoteListLikeWithdicData:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/getNoteListLike"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 提示消息
//            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
//            [alert GetHttpDefeatAlert:msg];
            NSLog(@"%@",msg);
            
            NSArray *arr = [NSArray array];
            
            if (success) {
                
                success(arr);
            }
            
        }else {
            
            NSLog(@"fiawoefnoeiwnfowe:%@",[dic objectForKey:@"data"]);
            
            // 拿到的数据
            NSArray *UserListArr = [dic objectForKey:@"data"];
            
            NSMutableArray *arrSearchUserInfoList = [SearchTieZiModel arrayOfModelsFromDictionaries:UserListArr error:nil];
            
            if (success) {
                
                success(arrSearchUserInfoList);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取关键词绑定帖子接口请求失败");
    }];
}

// 发布评论或回复评论
- (void) PostFabuAndHuiFuPingLunWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Message/comment"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 发布评论或回复评论失败
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
//            HttpRequest *httpAlert = [[HttpRequest alloc] init];
//            [httpAlert GetHttpDefeatAlert:msg];
            NSLog(@"msg:%@",msg);
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            // 发布评论或回复评论成功
            if (success) {
                
                success(@"1");
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"发布或回复评论接口请求失败");
    }];
}

// 获取评论
- (void) GetCommentListWithnoteId:(NSString *)noteid andpageStart:(NSString *)pageStart andpageSize:(NSString *)pageSize Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    NSString *StrUrl = [NSString stringWithFormat:@"/Message/getCommentList?noteId=%@&pageStart=%@&pageSize=%@",noteid,pageStart,pageSize];
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,StrUrl];
    
    [HttpRequest postWithURL:path andDic:nil success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"%@",msg);
            
            if (success) {
                
                success(msg);
            }
            
        }else {
            
            // 拿到的数据
            NSArray *UserListArr = [dic objectForKey:@"data"];
            
            NSMutableArray *arrSearchUserInfoList = [pinglunModel arrayOfModelsFromDictionaries:UserListArr error:nil];
            
            if (success) {
                
                success(arrSearchUserInfoList);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取评论接口请求失败");
    }];
}


// 标记喜欢帖子
- (void) PostAddLoveNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Message/addLoveNote"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 标记喜欢帖子失败
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 打印提示错误
            NSLog(@"msg:%@",msg);
            
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            // 标记喜欢帖子成功
            if (success) {
                
                success(@"1");
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        NSLog(@"标记喜欢帖子接口请求失败");
    }];
}


// 移除喜欢帖子
- (void) PostDelLoveNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Message/delLoveNote"];
    
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 移除喜欢帖子失败
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 打印提示错误
            NSLog(@"msg:%@",msg);
            
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            // 移除喜欢帖子成功
            if (success) {
                
                success(@"1");
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        NSLog(@"移除喜欢帖子接口请求失败");
    }];
}

// 用户举报帖子
- (void) PostAccusationNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/accusationNote"];
    // 进行网络请求
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSString *errorCode = [dic valueForKey:@"errorCode"];
        NSLog(@"errorcode:%@",errorCode);
        NSString *msg = [dic valueForKey:@"msg"];
        NSLog(@"msg:%@",msg);
        
        if (statusInt == 0) {
            
            // 移除喜欢帖子失败
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 打印提示错误
            NSLog(@"msg:%@",msg);
            
            HttpRequest *alert = [[HttpRequest alloc] init];
            [alert GetHttpDefeatAlert:msg];
            
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            HttpRequest *alert = [[HttpRequest alloc] init];
            [alert GetHttpDefeatAlert:msg];
            
            // 移除喜欢帖子成功
            if (success) {
                
                success(@"1");
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"网络请求失败"];
        
        // 网络请求失败
        //        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        NSLog(@"用户举报帖子接口请求失败");
    }];
}

// 获取当前帖子的用户动态
- (void) PostGetUserActivityByNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Message/getUserActivityByNote"];
    
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 提示消息
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 打印提示
            NSLog(@"msg:%@",msg);
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            
            NSString *UserListStr = [dic valueForKey:@"data"];
            
            if (success) {
                
                success(UserListStr);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        
        NSLog(@"获取当前帖子的用户动态接口请求失败");
    }];
}


// 获取通知消息
- (void) PostGetMessageWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Message/getMessage"];
    
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 提示消息
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 打印提示
            NSLog(@"msg:%@",msg);
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            
            NSString *UserListStr = [dic valueForKey:@"data"];
            
            if (success) {
                
                success(UserListStr);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        
        NSLog(@"获取通知消息接口请求失败");
    }];
}

// 获取通知消息列表分页数据 ***
- (void) PostGetMessageForPageWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Message/getMessageForPage"];
    
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 提示消息
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 打印提示
            NSLog(@"msg:%@",msg);
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            
            NSString *UserListStr = [dic valueForKey:@"data"];
            
            if (success) {
                
                success(UserListStr);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
        //        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        
        NSLog(@"获取通知消息列表分页数据接口请求失败");
    }];
}

// 获取关注用户动态
- (void) PostGetFollowUserActivityWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    
    // 请求的数据接口
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Message/getFollowUserActivity"];
    
    [HttpRequest postWithURL:str andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 提示消息
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 打印提示
            NSLog(@"msg:%@",msg);
            
            NSDictionary *dic = [NSDictionary dictionary];
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            
            NSString *UserListStr = [dic valueForKey:@"data"];
            
            NSArray *UserListArr = [MakeJson createArrWithJsonString:UserListStr];
            
            NSLog(@"qwertyuasdfghjxfghj::::%@",UserListArr);
            
            NSMutableArray *arrSearchUserInfoList = [TrendsModel arrayOfModelsFromDictionaries:UserListArr error:nil];
            
            if (success) {
                
                success(UserListStr);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取关注用户动态接口请求失败");
    }];
    
}

// 获取推荐用户列表
- (void) PostGetUserListRecommendWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/getUserListRecommend"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 提示消息
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            NSLog(@"msg:%@",msg);
            
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            
            // 拿到的数据
            NSDictionary *UserListDic = [dic objectForKey:@"data"];
            
            
            // 拿到服务器给的key（里面有用我自己公钥加密后的后台的aes的key）
            NSString *strSeverKey = [UserListDic objectForKey:@"key"];
            
            // 再用本地保留的私钥进行rsa解密获取服务器的key，此过程已提前完成url解码和base64解码
            NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
            NSString *keyForSever = [RSAEncryptor decryptString:strSeverKey privateKeyWithContentsOfFile:private_key_path password:@"123456easylink"];
            
            // 拿到实际的后台返回的key后，解析后台返回的加密的数据
            // 先拿到加密及编码的data
            NSString *userData = [UserListDic objectForKey:@"data"];
            // 再用刚刚得到的后台的key对其进行aes解密得到data的Json字符串，此过程已提前完成url解码和base64解码
            NSString *userData2 = [userData AES128DecryptWithKey:keyForSever];
            NSLog(@"userData2:%@",userData2);
            
            NSDictionary *dicData = [MakeJson createDictionaryWithJsonString:userData2];
            
            if (success) {
                
                success(dicData);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取推荐用户列表接口请求失败");
    }];
}


// 获取用户喜好相关订阅关键词
- (void) PostGetKeywordListForUserLikeWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/KeyWords/getKeywordListForUserLike"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 提示消息
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            
            // 拿到的数据
            NSDictionary *UserListDic = [dic objectForKey:@"data"];
            
            if (success) {
                
                success(UserListDic);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户喜好相关订阅关键词接口请求失败");
    }];
}


// 获取用户喜好相关订阅关键词分页数据(带关联帖子列表) ***
- (void) PostGetKeywordListForUserLikeWithNotesWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/KeyWords/getKeywordListForUserLikeWithNotes"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 提示消息
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            
            // 拿到的数据
            NSDictionary *UserListDic = [dic objectForKey:@"data"];
            
            if (success) {
                
                success(UserListDic);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
        //        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户喜好相关订阅关键词接口请求失败");
    }];
}


// 获取搜索结果页推荐关键词
- (void) PostgetKeywordListRecommendForSearchWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/KeyWords/getKeywordListRecommendForSearch"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            // 提示消息
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            
            if (success) {
                
                success([NSString stringWithFormat:@"%ld",statusInt]);
            }
            
        }else {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            
            
            // 拿到的数据
            NSDictionary *UserListDic = [dic objectForKey:@"data"];
            
            if (success) {
                
                success(UserListDic);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取搜索结果页推荐关键词接口请求失败");
    }];
}


// 获取关键词推荐的绑定帖子
- (void) PostGetNoteListByKeywordRecommendWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/Note/getNoteListByKeywordRecommend"];
    
    [HttpRequest postWithURL:path andDic:dataDic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        
        NSLog(@"*********%@",status);
        
        if (statusInt == 0) {
            
            NSString *errorCode = [dic valueForKey:@"errorCode"];
            NSLog(@"errorcode:%@",errorCode);
            NSString *msg = [dic valueForKey:@"msg"];
            
            // 提示消息
            //            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            //            [alert GetHttpDefeatAlert:msg];
            NSLog(@"%@",msg);
            
            NSDictionary *dic = @{@"kwId":@"flase"};
            
            if (success) {
                
                success(dic);
            }
            
        }else {
            
            // 拿到的数据
            NSDictionary *UserListDic = [dic objectForKey:@"data"];
            
            if (success) {
                success(UserListDic);
            }
            
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取关键词推荐的绑定帖子接口请求失败");
    }];
    
}


// 获取专题活动列表 ***
- (void) GetSpecialEventListWithpageStart:(NSString *)pagestart andpageSize:(NSString *)pagesize Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *str = [NSString stringWithFormat:@"/System/getSpecialEventList?pageStart=%@&pageSize=%@",pagestart,pagesize];
    
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,str];
    
    [HttpRequest postWithURL:path andDic:nil success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSString *msg = [dic valueForKey:@"msg"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            // 提示弹出
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            NSArray *arrForData = [dic valueForKey:@"data"];
            
            NSMutableArray *arrForZhuanTi = [ZhuanTiModel arrayOfModelsFromDictionaries:arrForData error:nil];
            
            if (success) {
                
                success(arrForZhuanTi);
            }
        }
    } failure:^(NSError *error) {
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        // 提示获取数据失败
        NSLog(@"获取专题活动列表接口请求失败");
        
    }];
}


// 获取专题活动详情 ***
- (void) GetSpecialEventDetailWithId:(NSString *)idStr Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *str = [NSString stringWithFormat:@"/System/getSpecialEventDetail?id=%@",idStr];
    
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,str];
    
    [HttpRequest postWithURL:path andDic:nil success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSString *msg = [dic valueForKey:@"msg"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            // 提示弹出
            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            NSDictionary *arrForData = [dic valueForKey:@"data"];
            
            NSMutableArray *arrTemp = [NSMutableArray array];
            
            [arrTemp addObject:arrForData];
            
            NSMutableArray *arrForZhuanTi = [ZhuanTiDetailModel arrayOfModelsFromDictionaries:arrTemp error:nil];
            
            if (success) {
                
                success(arrForZhuanTi);
            }
        }
    } failure:^(NSError *error) {
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        // 提示获取数据失败
        NSLog(@"获取专题活动详情接口请求失败");
        
    }];
}

// 获取Banner数据列表 ***
- (void) GetBannerListWithPosition:(NSString *)position Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *str = [NSString stringWithFormat:@"/System/getBannerList?position=%@",position];
    
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,str];
    
    [HttpRequest postWithURL:path andDic:nil success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSString *msg = [dic valueForKey:@"msg"];
        NSInteger statusInt = [status integerValue];
        
        if (statusInt == 0) {
            
            // 提示弹出
//            HttpRequest *alert = [[HttpRequest alloc] init];
            // 提示获取失败
//            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                
                success(@"0");
            }
            
        }else {
            
            NSArray *arrForData = [dic valueForKey:@"data"];
            
            NSMutableArray *arrForZhuanTi = [BannerModel arrayOfModelsFromDictionaries:arrForData error:nil];
            
            if (success) {
                
                success(arrForZhuanTi);
            }
        }
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        HttpRequest *alert = [[HttpRequest alloc] init];
//        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        // 提示获取数据失败
//        NSLog(@"获取Banner数据列表接口请求失败");
        
    }];
}


// 获取用户注册协议
- (void) GetRegistrationAgreementSuccess:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:@"%@%@",STRPATH,@"/System/getRegistrationAgreement"];
    
    [HttpRequest postWithURL:str andDic:nil success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic valueForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        NSString *msg = [dic valueForKey:@"msg"];
        
        if (statusInt == 0) {
            
            HttpRequest *alert = [[HttpRequest alloc] init];
            [alert GetHttpDefeatAlert:msg];
            
            if (success) {
                success(@"0");
            }
            
        }else {
            
            NSString *dataStr = [dic objectForKey:@"data"];
            
            if (success) {
                
                success(dataStr);
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            
            failure(error);
        }
        
        // 网络请求失败
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"获取用户注册协议接口请求失败");
    }];
}



// 判断用户是否登录超时
- (void) PostPanduanUserTimeOutWithDic:(NSDictionary *)dic Success:(void (^)(id statusInfo))success failure:(void (^)(NSError *error))failure {
    
    // 请求地址
    NSString *path = [NSString stringWithFormat:@"%@%@",STRPATH,@"/User/checkIfLongTimeNoUse"];
    
    // 请求数据
    [HttpRequest postWithURL:path andDic:dic success:^(id responseObj) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        
        NSString *status = [dic objectForKey:@"status"];
        NSInteger statusInt = [status integerValue];
        NSString *msg = [dic objectForKey:@"msg"];
        NSString *errorcode = [dic objectForKey:@"errorCode"];
        
        
        if (statusInt == 0) {
            
            // 登录超时
            
            NSString *errorCode = [dic objectForKey:@"errorCode"];
            NSLog(@"ceshichaoshierrorCode%@",errorCode);
            NSString *msg = [dic objectForKey:@"msg"];
            NSLog(@"ceshichaoshimsg%@",msg);
            
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSDictionary *dicc = @{@"status":status,@"msg":msg,@"errorcode":errorCode};
            [user setValue:dicc forKey:@"ceshiChaoShifanhuijieguo"];

            
            // 判断是否登录超时，并进行处理
            [self LoginOvertime:errorCode];
            
            if (success) {
                
                // 不做任何操作
                success(@"error");
            }
            
        }else {
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSDictionary *dicc = @{@"status":status};
            [user setValue:dicc forKey:@"ceshiChaoShifanhuijieguo"];
            
            if (success) {
                // 不做任何操作
                success(@"weichaoshi");
            }
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        [MBHUDView hudWithBody:@"网络错误" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];

        HttpRequest *alert = [[HttpRequest alloc] init];
        [alert GetHttpDefeatAlert:@"请求失败,请检查您的网络"];
        
        NSLog(@"请求判断用户是否登录超时接口失败");
    }];
}

// 登录超时
- (void) LoginOvertime:(NSString *)strCode {
    
    if ([strCode isEqualToString:@"1022"] || [strCode isEqualToString:@"1021"]) {
        
        // 极光推送删除绑定用户
        [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
            
        } seq:0];
    
        // 提示登录超时
        [MBHUDView hudWithBody:@"登录超时" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
        // 清除当前用户信息
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user removeObjectForKey:@"token"];
        [user removeObjectForKey:@"severPublicKey"];
        [user removeObjectForKey:@"userInfo"];
        
        // 删除单例
        // 首页处理
        [UserDefaults removeObjectForKey:@"LoveTieZiForReviseHome"];
        [UserDefaults removeObjectForKey:@"DelLoveTieZiForReviseHome"];
        [UserDefaults removeObjectForKey:@"DelTieZiForShouYe"];
        // 发现页处理
        [UserDefaults removeObjectForKey:@"FollowUserOrBlacklistUser"];
        [UserDefaults removeObjectForKey:@"CancleFollowUser"];
        [UserDefaults removeObjectForKey:@"RemoveDisLikeUser"];
        // 消息页处理
        [UserDefaults removeObjectForKey:@"FollowUserForNews"];
        [UserDefaults removeObjectForKey:@"CancleFollowUserForNews"];
        // 我的页面处理
        [UserDefaults removeObjectForKey:@"LoveTieZiForReviseMine"];
        [UserDefaults removeObjectForKey:@"DelLoveTieZiForReviseMine"];
        [UserDefaults removeObjectForKey:@"DelTieZiForMine"];
    
        // 登录页面
        LoginViewController *logVc = [[LoginViewController alloc] init];

        // 获取delegate
        AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // 隐藏底边栏
        [logVc setHidesBottomBarWhenPushed:YES];
        
        tempAppDelegate.mainTabbarController.selectedIndex = 0;
        // 跳转到登录页面
        [tempAppDelegate.mainTabbarController.viewControllers[0] pushViewController:logVc animated:YES];
    }
}


// 转换时间戳方法
- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}


// 获取当前页面
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

// 获取数据失败
- (void) GetHttpDefeatAlert:(NSString *)str {
    
    
    _HUD = [[MBProgressHUD alloc] initWithView:[self getCurrentVC].view];
    [[self getCurrentVC].view addSubview:_HUD];
    _HUD.labelText = str;
    _HUD.mode = MBProgressHUDModeText;
    _HUD.userInteractionEnabled = NO;
    
    //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
//    if (iPhone5S) {
//    
//    }else {
//        _HUD.yOffset = 100.0f;
//    }
    //    HUD.xOffset = 100.0f;
    
    [_HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1.5f);
    } completionBlock:^{
        [_HUD removeFromSuperview];
        _HUD = nil;
    }];
    
    
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
//    [alert show];
//    
//    [NSTimer scheduledTimerWithTimeInterval:1.5f
//                                     target:self
//                                   selector:@selector(timerFireMethod:)
//                                   userInfo:alert
//                                    repeats:YES];
}



//弹出框消失的方法
- (void)timerFireMethod:(NSTimer*)theTimer
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
    promptAlert = NULL;
    
    [theTimer invalidate]; // 销毁
}



@end
