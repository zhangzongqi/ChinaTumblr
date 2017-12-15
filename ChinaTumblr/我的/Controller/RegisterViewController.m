//
//  RegisterViewController.m
//  EasyLink
//
//  Created by 琦琦 on 16/11/1.
//  Copyright © 2016年 fengdian. All rights reserved.
//

#import "RegisterViewController.h"
#import "MZTimerLabel.h" // 计时类
#import "SelectLingYuViewController.h" // 选择领域
#import "UserAgreementViewController.h" // 用户协议页面
#import "JPUSHService.h" // 极光推送

@interface RegisterViewController ()<MZTimerLabelDelegate> {
    
    UILabel *timer_show;//倒计时label
    
    NSString *_ServePublicKeyStr; // 服务器的公共RSA公钥
}

@property (nonatomic,copy) MBProgressHUD *HUD;

@property (nonatomic,copy) UITextField *tfCountryId; // 国家手机编号

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 布局页面
    [self layoutViews];
}

// 布局页面
- (void) layoutViews {
    
    // 背景图
    UIImageView *backImgView = [[UIImageView alloc] init];
    [self.view addSubview:backImgView];
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        make.height.equalTo(@(H));
    }];
    backImgView.image = [UIImage imageNamed:@"login_bg"];
    backImgView.userInteractionEnabled = YES;
    
    // 返回按钮
    UIButton *backBtn = [[UIButton alloc] init];
    [backImgView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backImgView).with.offset(20);
        make.left.equalTo(backImgView).with.offset(5);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    [backBtn.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(backBtn);
        make.width.equalTo(@(14));
        make.height.equalTo(@(14));
    }];
    [backBtn setImage:[UIImage imageNamed:@"index_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    [userTf addTarget:self action:@selector(tfStarAction:) forControlEvents:(UIControlEventEditingDidBegin)];
    [userTf addTarget:self action:@selector(tfEndAction:) forControlEvents:(UIControlEventEditingDidEnd)];
    
    
    
    // 输入线
    UILabel *lbYanzheng = [[UILabel alloc] init];
    [backImgView addSubview:lbYanzheng];
    [lbYanzheng mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbCountryFenGe.mas_bottom).with.offset(0.125 * W);
        make.centerX.equalTo(backImgView);
        make.width.equalTo(@(0.64 * W));
        make.height.equalTo(@(0.5));
    }];
    lbYanzheng.backgroundColor = FUIColorFromRGB(0x999999);
    // 输入框
    UITextField *yanzhengTf = [[UITextField alloc] init];
    [backImgView addSubview:yanzhengTf];
    [yanzhengTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lbYanzheng.mas_top).with.offset(-3);
        make.left.equalTo(lbYanzheng).with.offset(7);
        make.width.equalTo(@(96));
        make.height.equalTo(@(20));
    }];
    yanzhengTf.textColor = FUIColorFromRGB(0x999999);
    yanzhengTf.font = [UIFont systemFontOfSize:13];
    yanzhengTf.tag = 667;
    yanzhengTf.text = @"请输入验证码";
    [yanzhengTf addTarget:self action:@selector(tfStarAction:) forControlEvents:(UIControlEventEditingDidBegin)];
    [yanzhengTf addTarget:self action:@selector(tfEndAction:) forControlEvents:(UIControlEventEditingDidEnd)];
    
    // 倒计时按钮
    UIButton *timeBtn = [[UIButton alloc] init];
    [backImgView addSubview:timeBtn];
    [timeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(yanzhengTf);
        make.right.equalTo(lbYanzheng.mas_right);
        make.height.equalTo(yanzhengTf.mas_height);
        make.width.equalTo(@(90));
    }];
    timeBtn.backgroundColor = [UIColor clearColor];
    [timeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [timeBtn setTitleColor:FUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    timeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    timeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [timeBtn addTarget:self action:@selector(getCodeClick) forControlEvents:UIControlEventTouchUpInside];
    timeBtn.tag = 501;
    // 分割线
    UILabel *lbFenge = [[UILabel alloc] init];
    [backImgView addSubview:lbFenge];
    [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(timeBtn);
        make.right.equalTo(timeBtn.mas_left);
        make.height.equalTo(timeBtn);
        make.width.equalTo(@(0.5));
    }];
    lbFenge.backgroundColor = FUIColorFromRGB(0x999999);
    
    
    
    // 密码输入线
    UILabel *lbPass = [[UILabel alloc] init];
    [backImgView addSubview:lbPass];
    [lbPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbYanzheng.mas_bottom).with.offset(0.125 * W);
        make.centerX.equalTo(backImgView);
        make.width.equalTo(lbYanzheng);
        make.height.equalTo(@(0.5));
    }];
    lbPass.backgroundColor = FUIColorFromRGB(0x999999);
    // 输入框
    UITextField *passTf = [[UITextField alloc] init];
    [backImgView addSubview:passTf];
    [passTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lbPass.mas_top).with.offset(-3);
        make.left.equalTo(lbPass).with.offset(7);
        make.width.equalTo(@(W * 0.64 - 7));
        make.height.equalTo(@(20));
    }];
    passTf.textColor = FUIColorFromRGB(0x999999);
    passTf.font = [UIFont systemFontOfSize:13];
    passTf.tag = 668;
    passTf.text = @"请输入密码";
    [passTf addTarget:self action:@selector(tfStarAction:) forControlEvents:(UIControlEventEditingDidBegin)];
    [passTf addTarget:self action:@selector(tfEndAction:) forControlEvents:(UIControlEventEditingDidEnd)];
    passTf.secureTextEntry = NO;
    
    
    // 用户协议勾选按钮
    UIButton *selectBtn = [[UIButton alloc] init];
    [backImgView addSubview:selectBtn];
    [selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbPass);
        make.top.equalTo(lbPass.mas_bottom);
        make.width.equalTo(@(25));
        make.height.equalTo(@(33));
    }];
    selectBtn.imageView.sd_layout
    .leftSpaceToView(selectBtn, 7)
    .topSpaceToView(selectBtn, 10)
    .widthIs(13)
    .heightIs(13);
    [selectBtn setImage:[UIImage imageNamed:@"login_icon2"] forState:UIControlStateSelected];
    [selectBtn setImage:[UIImage imageNamed:@"login_icon1"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    selectBtn.selected = YES;
    selectBtn.tag = 555;
    // 提示语
    UILabel *lbTip = [[UILabel alloc] init];
    [backImgView addSubview:lbTip];
    [lbTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(selectBtn);
        make.left.equalTo(selectBtn.mas_right);
    }];
    lbTip.font = [UIFont systemFontOfSize:12];
    lbTip.textColor = FUIColorFromRGB(0x999999);
    lbTip.text = @"我已阅读和同意";
    // 协议按钮
    UIButton *xieyiBtn = [[UIButton alloc] init];
    [backImgView addSubview:xieyiBtn];
    [xieyiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(selectBtn);
        make.left.equalTo(lbTip.mas_right).with.offset(3);
    }];
    [xieyiBtn setTitle:@"《嘚瑟用户协议》" forState:UIControlStateNormal];
    [xieyiBtn setTitleColor:FUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    xieyiBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [xieyiBtn addTarget:self action:@selector(xieyiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 注册按钮
    UIButton *registerBtn = [[UIButton alloc] init];
    [self.view addSubview:registerBtn];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPass).with.offset(0.072 * H);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(W * 0.65625));
        make.height.equalTo(@(H * 0.047 + 6));
    }];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:FUIColorFromRGB(0x151515) forState:UIControlStateNormal];
    [registerBtn setBackgroundColor:FUIColorFromRGB(0xfeaa0a)];
    registerBtn.clipsToBounds = YES;
    registerBtn.layer.cornerRadius = (H * 0.047 + 6) / 2;
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [registerBtn addTarget:self action:@selector(registerClick:) forControlEvents:UIControlEventTouchUpInside];
}


// 协议按钮
- (void) xieyiBtnClick:(UIButton *)xieyiBtn {
    
    UserAgreementViewController *vc = [[UserAgreementViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}


// 勾选用户协议点击事件
- (void) selectBtnClick:(UIButton *)senderBtn {
    
    if (senderBtn.selected == NO) {
        senderBtn.selected = YES;
    }else {
        senderBtn.selected = NO;
    }
}

#pragma mark -- 开始输入/结束输入
- (void)tfStarAction:(UITextField *)textField {
    
    switch (textField.tag) {
        case 666:
        {
            if ([textField.text isEqualToString:@"请输入手机号"]) {
                
                textField.text = @"";
                textField.textColor = FUIColorFromRGB(0xffffff);
                textField.font = [UIFont systemFontOfSize:14];
            }
        }
            break;
        case 667:
        {
            if ([textField.text isEqualToString:@"请输入验证码"]) {
                
                textField.text = @"";
                textField.textColor = FUIColorFromRGB(0xffffff);
                textField.font = [UIFont systemFontOfSize:14];
            }
        }
            break;
        case 668:
        {
            if ([textField.text isEqualToString:@"请输入密码"]) {
                
                textField.text = @"";
                textField.textColor = FUIColorFromRGB(0xffffff);
                textField.font = [UIFont systemFontOfSize:14];
                textField.secureTextEntry = YES;
            }
        }
            break;
            
        default:
            break;
    }
    
}

- (void)tfEndAction:(UITextField *)textField {
    
    switch (textField.tag) {
        case 666:
        {
            if ([textField.text isEqualToString:@""]) {
                
                textField.text = @"请输入手机号";
                textField.textColor = FUIColorFromRGB(0x999999);
                textField.font = [UIFont systemFontOfSize:13];
            }
        }
            break;
        case 667:
        {
            if ([textField.text isEqualToString:@""]) {
                
                textField.text = @"请输入验证码";
                textField.textColor = FUIColorFromRGB(0x999999);
                textField.font = [UIFont systemFontOfSize:13];
            }
        }
            break;
        case 668:
        {
            if ([textField.text isEqualToString:@""]) {
                
                textField.text = @"请输入密码";
                textField.textColor = FUIColorFromRGB(0x999999);
                textField.font = [UIFont systemFontOfSize:13];
                textField.secureTextEntry = NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    
}

// 返回按钮
- (void) backClick:(UIButton *)backBtn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 注册点击事件
- (void) registerClick:(UIButton *)registerBtn {
    
    // 创建动画
    _HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 展示动画
    [_HUD show:YES];
    
    // 获取公共RSA公钥，进行网络请求
    HttpRequest *http = [[HttpRequest alloc] init];
    
    // 判断输入框是否为空,不为空，则进行请求
    UITextField *tf0 = [self.view viewWithTag:666];
    UITextField *tf1 = [self.view viewWithTag:667];
    UITextField *tf2 = [self.view viewWithTag:668];
    UIButton *selectBtn = [self.view viewWithTag:555];
    if (tf0.text.length == 0 || [tf0.text isEqualToString:@"请输入手机号"]) {
        
        [MBHUDView hudWithBody:@"手机号为空" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.5 show:YES];
        // 结束动画
        [_HUD hide:YES];
        
    }else if (tf1.text.length == 0 || [tf1.text isEqualToString:@"请输入验证码"]){
            
        [MBHUDView hudWithBody:@"验证码为空" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.5 show:YES];
        // 结束动画
        [_HUD hide:YES];
        
    }else if (tf2.text.length == 0 || [tf2.text isEqualToString:@"请输入密码"]){
        
        [MBHUDView hudWithBody:@"密码为空" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.5 show:YES];
        // 结束动画
        [_HUD hide:YES];
        
    }else if (selectBtn.selected == NO) {
        
        [http GetHttpDefeatAlert:@"请先同意用户协议"];
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
            NSDictionary *dataDic = @{@"phone":tf0.text,@"code":tf1.text,@"password":tf2.text,@"rsa_public_key":[user objectForKey:@"localPublickey"]};
            // 转换成json并用aes进行加密，并做了base64和urlcode编码处理
            // 最终加密好的data参数的密文
            NSString *dataMiWenStr = [[MakeJson createJson:dataDic] AES128EncryptWithKey:strAESkey];
            
            
            // 创建请求验证码需要post的dic
            NSDictionary *postDataDic = @{@"key":keyMiWenStr,@"cg":cgMiWenStr,@"data":dataMiWenStr};
            
            
            NSLog(@"11111:%@",keyMiWenStr);
            NSLog(@"22222:%@",cgMiWenStr);
            NSLog(@"33333:%@",dataMiWenStr);
            
            [http PostRegisterWithDic:postDataDic Success:^(id userDataJsonStr) {
                
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
//                    HttpRequest *http = [[HttpRequest alloc] init];
//                    [http GetHttpDefeatAlert:@"恭喜您,注册成功!"];

                    [MBHUDView hudWithBody:@"注册成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.5 show:YES];
                    
                    
                    // 1秒后，跳转
                    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(tiaozhuanEvent) userInfo:nil repeats:NO];
                }
                
            } failure:^(NSError *error) {
                
                [_HUD hide: YES];
                
            }];
            
        } failure:^(NSError *error) {
            
            [_HUD hide: YES];
            
        }];
    }
}

// 注册成功,跳转到选择领域页面
- (void) tiaozhuanEvent {
    
    // 选择领域页面
    SelectLingYuViewController *vc = [[SelectLingYuViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

// 触发事件
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 释放第一响应者
    UITextField *tf1 = [self.view viewWithTag:666];
    [tf1 resignFirstResponder];
    UITextField *tf2 = [self.view viewWithTag:667];
    [tf2 resignFirstResponder];
    UITextField *tf3 = [self.view viewWithTag:668];
    [tf3 resignFirstResponder];
}


// 获取验证码点击事件
- (void) getCodeClick {
    
    // 创建动画
    _HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 展示动画
    [_HUD show:YES];
    
    // 获取公共RSA公钥，进行网络请求
    HttpRequest *http = [[HttpRequest alloc] init];
    
    // 判断输入框是否为空,不为空，则进行请求
    UITextField *tf0 = [self.view viewWithTag:666];
    if (tf0.text.length == 0 || [tf0.text isEqualToString:@"请输入手机号"]) {
        
        [MBHUDView hudWithBody:@"手机号为空" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.5 show:YES];
        // 结束动画
        [_HUD hide:YES];
        
    }else {
        
        // 获取公共公钥后,生成一个16位的AES的key,并保存用于解密服务器返回的信息
        NSString *strAESkey = [NSString set32bitString:16];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:strAESkey forKey:@"aesKey"];
        
        
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
            NSDictionary *dataDic = @{@"phone":tf0.text,@"opt":@"1"};
            // 转换成json并用aes进行加密，并做了base64和urlcode编码处理
            // 最终加密好的data参数的密文
            NSString *dataMiWenStr = [[MakeJson createJson:dataDic] AES128EncryptWithKey:strAESkey];
            
            
            // 创建请求验证码需要post的dic
            NSDictionary *postDataDic = @{@"key":keyMiWenStr,@"cg":cgMiWenStr,@"data":dataMiWenStr};
            [http PostPhoneCodeWithDic:postDataDic Success:^(id status) {
                
                // 请求成功,开始倒计时
                
                if ([status isEqualToString:@"0"]) {
                    
                    // 结束动画
                    [_HUD hide:YES];
                    
                }else {
                    
                    // 结束动画
                    [_HUD hide:YES];
                    // 倒计时
                    [self timeCount];
                }
                
            } failure:^(NSError *error) {
                
                
            }];
            
            
//                    NSLog(@"最终加密好的key参数的密文:%@",keyMiWenStr);
//                    NSLog(@"最终加密好的cg参数的密文:%@",cgMiWenStr);
//                    NSLog(@"最终加密好的data参数的密文:%@",dataMiWenStr);
            
            //        NSLog(@"没处理之前请求到的公共公钥:%@",strPublickey);
            //        NSLog(@"经过处理完之后的公钥:%@",_ServePublicKeyStr);
            //        NSLog(@"Key%@",strAESkey);
            
        } failure:^(NSError *error) {
            
        }];
    }
    
}

// 倒计时方法
- (void)timeCount{//倒计时函数
    
    UIButton *btn = [self.view viewWithTag:501];
    
    [btn setTitle:nil forState:UIControlStateNormal];//把按钮原先的名字消掉
    timer_show = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn.frame.size.width, btn.frame.size.height)];//UILabel设置成和UIButton一样的尺寸和位置
    timer_show.backgroundColor = [UIColor clearColor];// 设置背景色
    [btn addSubview:timer_show];//把timer_show添加到_dynamicCode_btn按钮上
    MZTimerLabel *timer_cutDown = [[MZTimerLabel alloc] initWithLabel:timer_show andTimerType:MZTimerLabelTypeTimer];//创建MZTimerLabel类的对象timer_cutDown
    [timer_cutDown setCountDownTime:60];//倒计时时间60s
    timer_cutDown.timeFormat = @"ss 重新获取";//倒计时格式,也可以是@"HH:mm:ss SS"，时，分，秒，毫秒；想用哪个就写哪个
    timer_cutDown.timeLabel.textColor = [UIColor colorWithRed:135/255.0 green:135/255.0 blue:135/255.0 alpha:1.0];//倒计时字体颜色
    timer_cutDown.timeLabel.font = [UIFont systemFontOfSize:13.0];//倒计时字体大小
    timer_cutDown.timeLabel.textAlignment = NSTextAlignmentCenter;//剧中
    timer_cutDown.delegate = self;//设置代理，以便后面倒计时结束时调用代理
    btn.userInteractionEnabled = NO;//按钮禁止点击
    [timer_cutDown start];//开始计时
}

//倒计时结束后的代理方法
- (void)timerLabel:(MZTimerLabel *)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime{
    
    UIButton *btn = [self.view viewWithTag:501];
    
    [btn setTitle:@"获取验证码" forState:UIControlStateNormal];//倒计时结束后按钮名称改为"获取验证码"
    [timer_show removeFromSuperview];//移除倒计时模块
    btn.userInteractionEnabled = YES;//按钮可以点击
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
