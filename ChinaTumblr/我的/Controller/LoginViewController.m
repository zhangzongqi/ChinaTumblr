//
//  LoginViewController.m
//  EasyLink
//
//  Created by 琦琦 on 16/10/20.
//  Copyright © 2016年 fengdian. All rights reserved.
//

#import "LoginViewController.h"
#import "ForgetPassViewController.h" // 忘记密码
#import "RegisterViewController.h" // 注册页面
#import "JPUSHService.h" // JPush

@interface LoginViewController () {
    
    NSString *_ServePublicKeyStr; // 服务器的公共RSA公钥
}

@property (nonatomic,copy) MBProgressHUD *HUD;

@property (nonatomic,copy) UITextField *tfCountryId; // 国家手机编号

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 布局页面
    [self createUI];
}

// 布局页面
- (void) createUI {
    
    // 背景图
    UIImageView *backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, W, H)];
    backImgView.image = [UIImage imageNamed:@"login_bg"];
    [self.view addSubview:backImgView];
    backImgView.userInteractionEnabled = YES;
    
    // 返回按钮
//    UIButton *backBtn = [[UIButton alloc] init];
//    [backImgView addSubview:backBtn];
//    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(backImgView).with.offset(20);
//        make.left.equalTo(backImgView).with.offset(5);
//        make.width.equalTo(@(40));
//        make.height.equalTo(@(40));
//    }];
//    [backBtn.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(backBtn);
//        make.width.equalTo(@(10));
//        make.height.equalTo(@(18));
//    }];
//    [backBtn setImage:[UIImage imageNamed:@"return_icon1"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // Logo
    UIImageView *logoImg = [[UIImageView alloc] init];
    [backImgView addSubview:logoImg];
    [logoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgView);
        make.top.equalTo(backImgView).with.offset(0.195 * H);
        make.width.equalTo(@(W * 0.21));
        make.height.equalTo(@(W * 0.21));
    }];
    logoImg.image = [UIImage imageNamed:@"logo"];
    
    
    
    // 国家区号选择分隔线
    UILabel *lbCountryFenGe = [[UILabel alloc] init];
    [backImgView addSubview:lbCountryFenGe];
    [lbCountryFenGe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backImgView).with.offset(H * 0.4485 + W * 0.0375);
        make.left.equalTo(backImgView).with.offset(W * 0.18);
        make.width.equalTo(@(45));
        make.height.equalTo(@(0.5));
    }];
    lbCountryFenGe.backgroundColor = FUIColorFromRGB(0x999999);
    
    // 国家手机编号
    _tfCountryId = [[UITextField alloc] init];
    [backImgView addSubview:_tfCountryId];
    [_tfCountryId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lbCountryFenGe.mas_top).with.offset(-3);
        make.left.equalTo(lbCountryFenGe);
        make.width.equalTo(lbCountryFenGe);
        make.height.equalTo(@(20));
    }];
    _tfCountryId.font = [UIFont systemFontOfSize:15];
    _tfCountryId.textColor = FUIColorFromRGB(0xffffff);
    _tfCountryId.text = @"+86";
    _tfCountryId.textAlignment = NSTextAlignmentCenter;
    _tfCountryId.userInteractionEnabled = NO; // 禁止用户操作
    
    
    // 输入线
    UILabel *lbUser = [[UILabel alloc] init];
    [backImgView addSubview:lbUser];
    [lbUser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbCountryFenGe);
        make.left.equalTo(lbCountryFenGe.mas_right).with.offset(10);
        make.width.equalTo(@(W * 0.64 - 55));
        make.height.equalTo(@(0.5));
    }];
    lbUser.backgroundColor = FUIColorFromRGB(0x999999);
    // 输入框
    UITextField *userTf = [[UITextField alloc] init];
    [backImgView addSubview:userTf];
    [userTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lbUser.mas_top).with.offset(-3);
        make.left.equalTo(lbUser);
        make.width.equalTo(lbUser);
        make.height.equalTo(@(20));
    }];
    userTf.textColor = FUIColorFromRGB(0x999999);
    userTf.font = [UIFont systemFontOfSize:13];
    userTf.tag = 666;
    userTf.text = @"请输入手机号";
    [userTf addTarget:self action:@selector(userTfStarAction:) forControlEvents:(UIControlEventEditingDidBegin)];
    [userTf addTarget:self action:@selector(userTfEndAction:) forControlEvents:(UIControlEventEditingDidEnd)];

    
    // 输入线
    UILabel *lbPass = [[UILabel alloc] init];
    [backImgView addSubview:lbPass];
    [lbPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backImgView).with.offset(H * 0.0185 + H * 0.5 + W * 0.0375);
        make.centerX.equalTo(backImgView);
        make.width.equalTo(@(0.64 * W));
        make.height.equalTo(@(0.5));
    }];
    lbPass.backgroundColor = FUIColorFromRGB(0x999999);
    // 输入框
    UITextField *passTf = [[UITextField alloc] init];
    [backImgView addSubview:passTf];
    [passTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lbPass.mas_top).with.offset(-3);
        make.left.equalTo(lbPass).with.offset(7);
        make.width.equalTo(@(0.64 * W - 7));
        make.height.equalTo(@(20));
    }];
    passTf.textColor = FUIColorFromRGB(0x999999);
    passTf.font = [UIFont systemFontOfSize:13];
    passTf.tag = 667;
    passTf.text = @"请输入密码";
    [passTf addTarget:self action:@selector(passTfStarAction:) forControlEvents:(UIControlEventEditingDidBegin)];
    [passTf addTarget:self action:@selector(passTfEndAction:) forControlEvents:(UIControlEventEditingDidEnd)];
    
    
    // 登录按钮
    UIButton *btnLogin = [[UIButton alloc] init];
    [backImgView addSubview:btnLogin];
    [btnLogin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPass.mas_bottom).with.offset(H * 0.062);
        make.centerX.equalTo(backImgView);
        make.height.equalTo(@(0.0485 * H));
        make.width.equalTo(@(0.5625 * W));
    }];
    [btnLogin setTitleColor:FUIColorFromRGB(0x151515) forState:UIControlStateNormal];
    btnLogin.backgroundColor = FUIColorFromRGB(0xfeaa0a);
    [btnLogin setTitle:@"登 录" forState:UIControlStateNormal];
    btnLogin.layer.cornerRadius = 0.0485 * H / 2;
    btnLogin.clipsToBounds = YES;
    btnLogin.titleLabel.font = [UIFont fontWithName:@"American Typewriter" size:15];
    [btnLogin addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 忘记密码
    UIButton *btnForgetPass = [[UIButton alloc] init];
    [backImgView addSubview:btnForgetPass];
    [btnForgetPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backImgView).with.offset(0.125 * W);
        make.top.equalTo(backImgView.mas_bottom).with.offset(- 0.088 * H);
        make.height.equalTo(@(30));
    }];
    [btnForgetPass setTitle:@"忘记密码" forState:UIControlStateNormal];
    [btnForgetPass setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [btnForgetPass addTarget:self action:@selector(forgetClick:) forControlEvents:UIControlEventTouchUpInside];
    btnForgetPass.titleLabel.font = [UIFont systemFontOfSize:13];
    
    
    // 立即注册
    UIButton *btnRegister = [[UIButton alloc] init];
    [backImgView addSubview:btnRegister];
    btnRegister.sd_layout
    .topEqualToView(btnForgetPass)
    .rightSpaceToView(backImgView,backImgView.size.width*0.125)
    .widthIs(72)
    .heightIs(30);
    
    btnRegister.imageView.sd_layout
    .centerYEqualToView(btnRegister)
    .rightEqualToView(btnRegister)
    .widthIs(14)
    .heightIs(12);
    
    btnRegister.titleLabel.sd_layout
    .centerYEqualToView(btnRegister)
    .rightSpaceToView(btnRegister.imageView,0)
    .widthIs(58)
    .heightIs(12);

    
    btnRegister.titleLabel.font = [UIFont systemFontOfSize:13];
    [btnRegister setImage:[UIImage imageNamed:@"login_icon4"] forState:UIControlStateNormal];
    [btnRegister setTitle:@"立即注册" forState:UIControlStateNormal];
    [btnRegister setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
    
    [btnRegister addTarget:self action:@selector(registerClick:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark -- 开始输入/结束输入
- (void)userTfStarAction:(UITextField *)textField {
    
    if ([textField.text isEqualToString:@"请输入手机号"]) {
        
        textField.text = @"";
        textField.textColor = FUIColorFromRGB(0xffffff);
        textField.font = [UIFont systemFontOfSize:14];
    }
}
- (void)passTfStarAction:(UITextField *)textField {
    
    if ([textField.text isEqualToString:@"请输入密码"]) {
        
        textField.text = @"";
        textField.textColor = FUIColorFromRGB(0xffffff);
        textField.font = [UIFont systemFontOfSize:14];
        textField.secureTextEntry = YES;
    }
}
- (void)userTfEndAction:(UITextField *)textField {
    
    if ([textField.text isEqualToString:@""]) {
        
        textField.text = @"请输入手机号";
        textField.textColor = FUIColorFromRGB(0x999999);
        textField.font = [UIFont systemFontOfSize:13];
    }
}
- (void)passTfEndAction:(UITextField *)textField {
    
    if ([textField.text isEqualToString:@""]) {
        
        textField.text = @"请输入密码";
        textField.textColor = FUIColorFromRGB(0x999999);
        textField.font = [UIFont systemFontOfSize:13];
        textField.secureTextEntry = NO; // 密文状态
    }
}


// 注册点击事件
- (void) registerClick:(UIButton *)btnRegister {
    
    NSLog(@"立即注册");
    
    // 注册页面
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    
    [self.navigationController pushViewController:registerVC animated:YES];
}

// 忘记密码点击事件
- (void) forgetClick:(UIButton *)btnForgetPass {
    
    NSLog(@"忘记密码");
    
    ForgetPassViewController *forgetPassVC = [[ForgetPassViewController alloc] init];
    
    [self.navigationController pushViewController:forgetPassVC animated:YES];
    
}

// 返回按钮点击事件
//- (void) backClick:(UIButton *)backBtn {
//    
//    [self.navigationController popViewControllerAnimated:YES];
//    
//}

// 触发事件
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 释放第一响应者
    UITextField *tf1 = [self.view viewWithTag:666];
    [tf1 resignFirstResponder];
    UITextField *tf2 = [self.view viewWithTag:667];
    [tf2 resignFirstResponder];
}

// 登录按钮点击事件
- (void) loginClick:(UIButton *)btnLogin {
    
    
    // 创建动画
    _HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 展示动画
    [_HUD show:YES];
    
    // 获取公共RSA公钥，进行网络请求
    HttpRequest *http = [[HttpRequest alloc] init];
    
    // 判断输入框是否为空,不为空，则进行请求
    UITextField *tf0 = [self.view viewWithTag:666];
    UITextField *tf1 = [self.view viewWithTag:667];
    if (tf0.text.length == 0 || [tf0.text isEqualToString:@"请输入手机号"]) {
        
        [MBHUDView hudWithBody:@"账号为空" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.5 show:YES];
        
        // 结束动画
        [_HUD hide:YES];
        
    }else if (tf1.text.length == 0 || [tf1.text isEqualToString:@"请输入密码"]) {
        
        [MBHUDView hudWithBody:@"密码为空" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.5 show:YES];
        
        // 结束动画
        [_HUD hide:YES];
        
    }else {
        
        // 生成一个16位的AES的key,并保存用于解密服务器返回的信息
        NSString *strAESkey = [NSString set32bitString:16];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:strAESkey forKey:@"aesKey"];
        
        // 请求RSA公钥,并把生成的AESKey进行加密
        [http GetRSAPublicKeySuccess:^(id strPublickey) {
            
            _ServePublicKeyStr = [UrlcodeAndBase64 jiemaurlDecodeAndBase64String:strPublickey];
            
            // 最终加密好的key参数的密文
            NSString *keyMiWenStr = [RSAEncryptor encryptString:strAESkey publicKey:_ServePublicKeyStr];
            
            
            // 获取当前时间戳，转换成json类型，并用AES进行加密,并做了base64及urlcode转码处理
            NSDate *senddate = [NSDate date];
            NSString *date2 = [NSString stringWithFormat:@"%ld", (long)[senddate timeIntervalSince1970]];
            
            
            NSDictionary *cgDic = @{@"requestTime":date2};
            // 最终加密好的cg参数的密文
            NSString *cgMiWenStr = [[MakeJson createJson:cgDic] AES128EncryptWithKey:strAESkey];
            
            // 用户信息，和获取验证码类型，用于请求验证码
            NSDictionary *dataDic = @{@"phone":tf0.text,@"password":tf1.text,@"rsa_public_key":[user objectForKey:@"localPublickey"]};
            // 转换成json并用aes进行加密，并做了base64和urlcode编码处理
            // 最终加密好的data参数的密文
            NSString *dataMiWenStr = [[MakeJson createJson:dataDic] AES128EncryptWithKey:strAESkey];
            
            
            // 创建请求验证码需要post的dic
            NSDictionary *postDataDic = @{@"key":keyMiWenStr,@"cg":cgMiWenStr,@"data":dataMiWenStr};
            [http PostLoginWithDic:postDataDic Success:^(id userDataJsonStr) {
                
                NSLog(@"服务器返回的最终data:%@",userDataJsonStr);
                
                if ([userDataJsonStr isEqualToString:@"0"]) {
                    
                    // 关闭动画
                    [_HUD hide:YES];
                    
                }else {
                    
                    // 得到用户的Dic字符串
                    NSDictionary *userDataDic = [MakeJson createDictionaryWithJsonString:userDataJsonStr];
                    // 创建单例,保存token和服务器给的公钥
                    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                    [user setObject:[userDataDic objectForKey:@"rsa_public_key"] forKey:@"severPublicKey"];
                    [user setObject:[userDataDic objectForKey:@"token"] forKey:@"token"];
                    
                    NSLog(@"得到的服务器的公钥:%@",[userDataDic objectForKey:@"rsa_public_key"]);
                    NSLog(@"得到的token:%@",[userDataDic objectForKey:@"token"]);
                    
                    
                    // 获取到用户RSAKey
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
                    // 用户token
                    NSString *userToken = [user objectForKey:@"token"];
                    NSDictionary *dicGetUserInfoData = @{@"uid":@""};
                    NSString *strJiaMiGetUserInfoData = [[MakeJson createJson:dicGetUserInfoData] AES128EncryptWithKey:strAESkey];
                    
                    // 用于最终获取用户资料需要的Dic
                    NSDictionary *dicForData = @{@"tk":userToken,@"key":keyMiWenStr,@"cg":cgMiWenStr,@"data":strJiaMiGetUserInfoData};
                    // 请求用户资料
                    [http PostUserInfoWithDic:dicForData Success:^(id userInfo) {
                        
                        NSDictionary *dicForUserInfo = [MakeJson createDictionaryWithJsonString:userInfo];
                        
                        // 将用户资料保存本地
                        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                        [user setObject:dicForUserInfo forKey:@"userInfo"];
                        
                        
                        // 注册JPush通知用户
                        [JPUSHService setAlias:[dicForUserInfo valueForKey:@"id"] completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                            // 回调方法,seq返回的就是下面的,
                        } seq:[[dicForUserInfo valueForKey:@"id"] integerValue]];
                        
                        
                    } failure:^(NSError *error) {
                        
                        // 请求失败
                    }];
                    
                    
                    // 结束动画
                    [_HUD hide:YES];
                    
                    // 提醒注册成功即将自动登录
                    [MBHUDView hudWithBody:@"登录成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.5 show:YES];
                    
                    
                    // 获取所有订阅关键词编号
                    NSDictionary *dicForAllKeyWordId = @{@"tk":userToken,@"key":keyMiWenStr,@"cg":cgMiWenStr};
                    [http PostGetAllFollowKeywordIdListWithDic:dicForAllKeyWordId Success:^(id userInfo) {
                        
                        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                        [user setValue:userInfo forKey:@"AllFollowKeyWordId"];
                        
                    } failure:^(NSError *error) {
                        
                        NSLog(@"网络请求错误，在具体用的时候，还会判断这个是否为nil");
                    }];
                    
                    
                    
                    
                    
                    
                    // 发送通知,用于修改资料
                    // 创建消息中心
                    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
                    // 在消息中心发布自己的消息
                    [notiCenter postNotificationName:@"loginSuccess" object:@"3"];
                    [notiCenter postNotificationName:@"loginSuccessForShouye" object:@"1"];
                    // 用于修改发现页
                    [notiCenter postNotificationName:@"loginSuccessForFind" object:@"90"];
                    // 用于修改消息页面
                    [notiCenter postNotificationName:@"loginSuccessForXiaoXi" object:@"91"];
                    
                    
                    // 1秒后，跳转
                    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(tiaozhuanEvent) userInfo:nil repeats:NO];
                }
                
            } failure:^(NSError *error) {
                
                // 登录的请求失败
                
            }];
            
        } failure:^(NSError *error) {
            
            // 登录的请求失败
            
        }];
    }
}

// 登录成功 跳转方法
- (void)tiaozhuanEvent {
    
    NSLog(@"要自动登录咯");
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 页面将要消失
- (void) viewWillDisappear:(BOOL)animated {
    
    // 打开手势返回
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

// 页面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // 关闭手势返回
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
