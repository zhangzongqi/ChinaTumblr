//
//  AccountManagerViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/18.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "AccountManagerViewController.h"
#import "ChangePhoneViewController.h" // 更换手机号
#import "RevisePassViewController.h" // 修改密码
#import "LoginViewController.h" // 登录页面
#import "AppDelegate.h" //
#import "ASBirthSelectSheet.h" // 生日选择器
#import "AddAddressSelectView.h" // 地址选择视图
#import "ZheZhaoView.h" // 遮罩层
#import "JPUSHService.h" // 极光推送

@interface AccountManagerViewController ()<UIActionSheetDelegate,UITextFieldDelegate>{
    
    // 地址遮罩层
    ZheZhaoView *_dizhiZheZhao;
    
    // 用户修改的字典
    NSMutableDictionary *_userInfoDic;
}

// 地址选择视图
@property (nonatomic, copy) AddAddressSelectView *addressSelectVc;

@property (nonatomic, copy) UITextField *tf;

@end

@implementation AccountManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置导航栏标题
    UILabel *lbItemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    lbItemTitle.text = @"账户管理";
    lbItemTitle.textColor = FUIColorFromRGB(0x212121);
    lbItemTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = lbItemTitle;
    
    // 初始化数组
    [self initArr];
    
    // 创建UI
    [self createUI];
    
    // 导航栏右侧按钮和视图
    [self createRightBtn];
    
    
    // 创建地址选择视图
    [self createAddressSelectView];
}


// 导航栏右侧按钮和视图
- (void) createRightBtn {
    
    // 右侧按钮
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 28, 15);
    [menuBtn setTitle:@"编辑" forState:UIControlStateNormal];
    menuBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [menuBtn setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    menuBtn.selected = NO;
    menuBtn.tag = 999;
}


// 导航栏右侧按钮点击事件
- (void)rightBtnClick:(UIButton *)menuBtn {
    
    if (menuBtn.selected == NO) {
        
        menuBtn.selected = YES;
        [menuBtn setTitle:@"保存" forState:UIControlStateNormal];
        // 打开用户交互
        for (int i = 0; i < 2; i++) {
            UITextField *tf1 = [self.view viewWithTag:1000 + i];
            tf1.userInteractionEnabled = YES;
            if (i == 0) {
                if ([tf1 isFirstResponder] == NO) {
                    [tf1 becomeFirstResponder];
                }
            }
        }
        for (int i = 2; i < 5; i++) {
            
            UIButton *tfBtn = [self.view viewWithTag:1000 + i];
            tfBtn.userInteractionEnabled = YES;
        }
        
    }else {
        
        // 输入框释放第一响应者
        for (int i = 0; i < 2; i++) {
            UITextField *tf1 = [self.view viewWithTag:1000 + i];
            [tf1 resignFirstResponder];
        }
        
        
        if ([_userInfoDic count] == 0) {
            // 把右上角按钮变回去
            menuBtn.selected = NO;
            [menuBtn setTitle:@"编辑" forState:UIControlStateNormal];
            // 输入框禁用
            for (int i = 0; i < 2; i++) {
                UITextField *tf1 = [self.view viewWithTag:1000 + i];
                tf1.userInteractionEnabled = NO;
            }
            for (int i = 2; i < 5; i++) {
                UIButton *tfBtn = [self.view viewWithTag:1000 + i];
                tfBtn.userInteractionEnabled = NO;
            }
        }else {
            
            // 创建单例,获取到用户RSAKey
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSString *userRsaPublicKey = [user objectForKey:@"severPublicKey"];
            
            // 生成一个16位的AES的key,并保存用于解密服务器返回的信息
            NSString *strAESkey = [NSString set32bitString:16];
            [user setObject:strAESkey forKey:@"aesKey"];
            // 最终加密好的key参数的密文
            NSString *keyMiWenStr = [RSAEncryptor encryptString:strAESkey publicKey:userRsaPublicKey];
            
            // 获取当前时间戳，转换成json类型，并用AES进行加密,并做了base64及urlcode转码处理
            NSDate *senddate = [NSDate date];
            NSString *date2 = [NSString stringWithFormat:@"%ld", (long)[senddate timeIntervalSince1970]];
            NSDictionary *cgDic = @{@"requestTime":date2};
            // 最终加密好的cg参数的密文
            NSString *cgMiWenStr = [[MakeJson createJson:cgDic] AES128EncryptWithKey:strAESkey];
            
            // 用户token
            NSString *userToken = [user objectForKey:@"token"];
            
            NSLog(@"*****************%@",_userInfoDic);
            
            NSString *strData = [[MakeJson createJson:_userInfoDic] AES128EncryptWithKey:strAESkey];
            
            NSDictionary *dicForData = @{@"tk":userToken,@"key":keyMiWenStr,@"cg":cgMiWenStr,@"data":strData};
            
            NSLog(@"dicForData,%@",dicForData);
            
            // 进行数据请求
            HttpRequest *http = [[HttpRequest alloc] init];
            [http PostReviseUserInfoWithDic:dicForData Success:^(id userInfo) {
                
                
                if ([userInfo isEqualToString:@"昵称被占用"]) {
                    // 修改失败了
                    
                    
                    // 删除刚刚保存的用户名
                    [_userInfoDic removeObjectForKey:@"nickname"];
                    UITextField *tf1 = [self.view viewWithTag:1000];
                    [tf1 becomeFirstResponder];
                    
                }else {
                    
                    // 修改成功了
                    
                    [MBHUDView hudWithBody:@"资料修改成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                    
                    // 把返回的信息做一次本地保存
                    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                    [user setObject:[MakeJson createDictionaryWithJsonString:userInfo] forKey:@"userInfo"];
                    // 发通知，用于返回我的页面时，修改头像和昵称和签名
                    // 创建消息中心
                    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
                    // 在消息中心发布自己的消息
                    [notiCenter postNotificationName:@"reviseUserInfo" object:@"2"];
                    
                    // 把右上角按钮变回去
                    menuBtn.selected = NO;
                    [menuBtn setTitle:@"编辑" forState:UIControlStateNormal];
                    // 输入框禁用
                    for (int i = 0; i < 2; i++) {
                        UITextField *tf1 = [self.view viewWithTag:1000 + i];
                        tf1.userInteractionEnabled = NO;
                    }
                    for (int i = 2; i < 5; i++) {
                        UIButton *tfBtn = [self.view viewWithTag:1000 + i];
                        tfBtn.userInteractionEnabled = NO;
                    }
                }
                
                
                NSLog(@"userInfo:%@",userInfo);
                
                
            } failure:^(NSError *error) {
                
                
                // 请求失败
            }];
        }
    }
}



// 创建地址选择视图
- (void) createAddressSelectView {
    
    UIButton *btn = [self.view viewWithTag:1004];
    
    // 地址遮罩层
    _dizhiZheZhao = [[ZheZhaoView alloc] initWithFrame:CGRectMake(0, 0, W, H - 64)];
    [self.view addSubview:_dizhiZheZhao];
    _dizhiZheZhao.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dizhiZhezhaoClick)];
    [_dizhiZheZhao addGestureRecognizer:tap];
    
    // 地址选择视图
    _addressSelectVc = [[AddAddressSelectView alloc] initWithFrame:CGRectMake(0, H, W, W * 25/32)];
    [self.view addSubview:_addressSelectVc];
    [_addressSelectVc.closeBtn addTarget:self action:@selector(AddressSelectClose) forControlEvents:UIControlEventTouchUpInside];
    // 关闭
    __weak typeof (self) weakSelf = self;
    _addressSelectVc.chooseFinish = ^{
        [UIView animateWithDuration:0.25 animations:^{
            [btn setTitle:weakSelf.addressSelectVc.address forState:UIControlStateNormal];
            [btn setTitleColor:FUIColorFromRGB(0x212121) forState:UIControlStateNormal];
            
            [weakSelf AddressSelectClose];
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSLog(@"getStreetId:%@",[user objectForKey:@"getStreetId"]);
            
            // 保存到用户修改字典
            [_userInfoDic setObject:[user objectForKey:@"shengshiquId"] forKey:@"city"];
            
            [_userInfoDic setObject:[NSString stringWithFormat:@"%@,%@,%@",[user objectForKey:@"province"],[user objectForKey:@"city"],[user objectForKey:@"district"]] forKey:@"city_txt"];
            NSLog(@"%@",_userInfoDic);
        }];
    };
}

// 地址选择视图关闭按钮的点击
- (void) AddressSelectClose {
    
    [self dizhiZhezhaoClick];
}

// 地址遮罩层点击事件
- (void) dizhiZhezhaoClick {
    
    // 城市
    [UIView animateWithDuration:0.25f animations:^{
        
        _addressSelectVc.frame = CGRectMake(0, H, W, W * 25/32);
        
    } completion:^(BOOL finished) {
        
        _dizhiZheZhao.hidden = YES;
    }];
}



// 初始化数组
- (void) initArr {
    
    // 用户修改的信息字典
    _userInfoDic = [[NSMutableDictionary alloc] init];
}

// 创建UI
- (void) createUI {
    
    NSArray *arrMineInfoName = @[@"昵称",@"个性签名",@"性别",@"生日",@"所在城市"];
    NSArray *arrPlaceholder = @[@"请输入昵称",@"请输入个性签名",@"请选择性别",@"请选择生日",@"请选择所在城市"];
    
    
    // 创建6个TextFiled
    for (int i = 0; i < 5; i++) {
        
        // 分类标题
        UILabel *lb = [[UILabel alloc] init];
        [self.view addSubview:lb];
        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(29+ (0.071 * H * i));
            make.left.equalTo(self.view).with.offset(0.08 * W);
            make.width.equalTo(@(62));
            make.height.equalTo(@(16));
        }];
        lb.text = arrMineInfoName[i];
        lb.font = [UIFont systemFontOfSize:14];
        lb.textColor = FUIColorFromRGB(0x4e4e4e);
        
        // 分割线
        UILabel *lbFenge = [[UILabel alloc] init];
        [self.view addSubview:lbFenge];
        [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lb.mas_bottom).with.offset(0.0185 * H);
            make.left.equalTo(lb);
            make.right.equalTo(self.view).with.offset(- 0.07 * W);
            make.height.equalTo(@(1));
        }];
        lbFenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
        
        // 用户资料
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSDictionary *userInfo = [user objectForKey:@"userInfo"];
        
        // 输入框
        if (i == 0 || i == 1) {
            _tf = [[UITextField alloc] init];
            [self.view addSubview:_tf];
            [_tf mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(lbFenge);
                make.left.equalTo(lb.mas_right).with.offset(0.047 * W);
                make.right.equalTo(lbFenge.mas_right);
                make.height.equalTo(@(0.0185 * H * 2 + 16));
            }];
            _tf.placeholder = arrPlaceholder[i];
            _tf.font = [UIFont systemFontOfSize:13];
            _tf.tag = 1000 + i;
            _tf.textColor = FUIColorFromRGB(0x212121);
            _tf.userInteractionEnabled = NO; // 禁用用户编辑
            _tf.delegate = self;
            if (i == 0) {
                if ([[userInfo objectForKey:@"nickname"] isEqualToString:@""]) {
                    
                }else {
                    _tf.text = [userInfo objectForKey:@"nickname"];
                }
            }
            if (i == 1) {
                if ([[userInfo objectForKey:@"sign"] isEqualToString:@""]) {
                    
                }else {
                    _tf.text = [userInfo objectForKey:@"sign"];
                }
            }
            
            
        }else {
            
            UIButton *tfBtn = [[UIButton alloc] init];
            [self.view addSubview:tfBtn];
            [tfBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(lbFenge);
                make.left.equalTo(lb.mas_right).with.offset(0.047 * W);
                make.right.equalTo(lbFenge.mas_right);
                make.height.equalTo(@(0.0185 * H * 2 + 16));
            }];
            tfBtn.titleLabel.sd_layout
            .centerYEqualToView(tfBtn)
            .leftEqualToView(tfBtn)
            .widthRatioToView(tfBtn, 1.0)
            .heightIs(13);
            tfBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [tfBtn setTitleColor:[UIColor colorWithRed:212/255.0 green:212/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateNormal];
            [tfBtn setTitle:arrPlaceholder[i] forState:UIControlStateNormal];
            tfBtn.tag = 1000+i;
            [tfBtn addTarget:self action:@selector(tfBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            tfBtn.userInteractionEnabled = NO; // 禁用用户交互
            
            
            
            if (i == 2) {
                if ([[userInfo objectForKey:@"sex"] isEqualToString:@""]) {
                    
                }else {
                    
                    [tfBtn setTitleColor:FUIColorFromRGB(0x212121) forState:UIControlStateNormal];
                    
                    switch ([[userInfo objectForKey:@"sex"] integerValue]) {
                        case 0:{
                            [tfBtn setTitle:@"保密" forState:UIControlStateNormal];
                        }
                            break;
                        case 1:{
                            [tfBtn setTitle:@"男" forState:UIControlStateNormal];
                        }
                            break;
                        case 2:{
                            [tfBtn setTitle:@"女" forState:UIControlStateNormal];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
            }
            if (i == 3) {
                if ([[userInfo objectForKey:@"birth_day"] isEqualToString:@""]) {
                    
                }else {
                    
                    // 时间戳转换成时间
                    int dt = [[userInfo objectForKey:@"birth_day"] intValue];
                    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:dt];
                    HttpRequest *stringForDate = [[HttpRequest alloc] init];
                    NSString *strDate = [stringForDate stringFromDate:confromTimesp];
                    NSString *str = [[strDate componentsSeparatedByString:@" "] objectAtIndex:0];
                    
                    // 设置生日
                    [tfBtn setTitle:str forState:UIControlStateNormal];
                    [tfBtn setTitleColor:FUIColorFromRGB(0x212121) forState:UIControlStateNormal];
                }
            }
            if (i == 4) {
                if ([[userInfo objectForKey:@"city_txt"] isEqualToString:@""]) {
                    
                }else {
                    
                    NSString *strCity = [[userInfo objectForKey:@"city_txt"] stringByReplacingOccurrencesOfString:@"," withString:@" "];
                    
                    [tfBtn setTitle:strCity forState:UIControlStateNormal];
                    [tfBtn setTitleColor:FUIColorFromRGB(0x212121) forState:UIControlStateNormal];
                }
            }
        }
        
        
        if (i == 4) {
            
            NSArray *arrTitleName = @[@"更换手机号",@"更换密码"];
            
            for (int j = 0; j < 2; j++) {
                
                // 创建下面两行
                // 分类标题
                UILabel *lb = [[UILabel alloc] init];
                [self.view addSubview:lb];
                [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lbFenge.mas_bottom).with.offset(71 + (0.071 * H * j));
                    make.left.equalTo(self.view).with.offset(0.08 * W);
                    make.height.equalTo(@(16));
                }];
                lb.text = arrTitleName[j];
                lb.font = [UIFont systemFontOfSize:14];
                lb.textColor = FUIColorFromRGB(0x4e4e4e);
                
                // 分割线
                UILabel *lbFenge = [[UILabel alloc] init];
                [self.view addSubview:lbFenge];
                [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lb.mas_bottom).with.offset(0.0185 * H);
                    make.left.equalTo(lb);
                    make.right.equalTo(self.view).with.offset(- 0.07 * W);
                    make.height.equalTo(@(1));
                }];
                lbFenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
                
                // button
                UIButton *btnMineSet = [[UIButton alloc] init];
                [self.view addSubview:btnMineSet];
                [btnMineSet mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lb);
                    make.left.equalTo(lb.mas_right).with.offset(0.047 * W);
                    make.right.equalTo(lbFenge.mas_right);
                    make.height.equalTo(lb);
                }];
                btnMineSet.titleLabel.sd_layout
                .leftSpaceToView(btnMineSet,0)
                .topSpaceToView(btnMineSet,0)
                .widthIs(100)
                .heightRatioToView(btnMineSet,1);
                btnMineSet.imageView.sd_layout
                .leftSpaceToView(btnMineSet.titleLabel,btnMineSet.frame.size.width - 100 - 9.15)
                .topSpaceToView(btnMineSet,0)
                .widthIs(9.15)
                .heightIs(16);
                if (j == 0) {
                    btnMineSet.titleLabel.font = [UIFont systemFontOfSize:13];
                    [btnMineSet setTitle:[userInfo objectForKey:@"phone"] forState:UIControlStateNormal];
                    [btnMineSet setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
                }
                [btnMineSet setImage:[UIImage imageNamed:@"cellrightImg"] forState:UIControlStateNormal];
                btnMineSet.tag = 100 + j;
                [btnMineSet addTarget:self action:@selector(MineSetClick:) forControlEvents:UIControlEventTouchUpInside];
                
                
                if (j == 1) {
                    // 创建退出登录按钮
                    UIButton *logOutBtn = [[UIButton alloc] init];
                    [self.view addSubview:logOutBtn];
                    [logOutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(lbFenge.mas_bottom).with.offset(0.0616 * H);
                        make.centerX.equalTo(self.view);
                        make.height.equalTo(@(0.084375 * W));
                        make.width.equalTo(@(0.65625 * W));
                    }];
                    logOutBtn.layer.cornerRadius = 0.084375 * W / 2;
                    logOutBtn.clipsToBounds = YES;
                    logOutBtn.layer.borderWidth = 1;
                    logOutBtn.layer.borderColor = [[UIColor colorWithRed:252/255.0 green:169/255.0 blue:44/255.0 alpha:1.0] CGColor];
                    [logOutBtn setTitle:@"退出该账户" forState:UIControlStateNormal];
                    logOutBtn.titleLabel.font = [UIFont systemFontOfSize:15];
                    [logOutBtn setTitleColor:[UIColor colorWithRed:252/255.0 green:169/255.0 blue:44/255.0 alpha:1.0] forState:UIControlStateNormal];
                    [logOutBtn addTarget:self action:@selector(logOutBtnClick) forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
    }
}

// 仿tf的按钮点击事件
- (void) tfBtnClick:(UIButton *)tfBtn {
    
    
    if (tfBtn.tag == 1002) {
        
        for (int i = 0; i < 2; i++) {
            UITextField *tf1 = [self.view viewWithTag:1000+i];
            [tf1 resignFirstResponder];
        }
        
        // 性别
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女",@"保密",nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
        actionSheet.delegate = self;
    }
    
    if (tfBtn.tag == 1003) {
        
        for (int i = 0; i < 2; i++) {
            UITextField *tf1 = [self.view viewWithTag:1000+i];
            [tf1 resignFirstResponder];
        }
        
        // 创建生日选择器
        [self createBirthSelectView];
    }
    
    if (tfBtn.tag == 1004) {
        
        for (int i = 0; i < 2; i++) {
            UITextField *tf1 = [self.view viewWithTag:1000+i];
            [tf1 resignFirstResponder];
        }
            
        [UIView animateWithDuration:0.25f animations:^{
            
            _dizhiZheZhao.hidden = NO;
            
            _addressSelectVc.frame = CGRectMake(0, H - W * 25/32, W, W * 25/32);
            
        } completion:^(BOOL finished) {
            
            
        }];
    }
}

// 选择器
- (void) createBirthSelectView {
    
    // 生日选择器
    ASBirthSelectSheet *datesheet = [[ASBirthSelectSheet alloc] initWithFrame:self.view.bounds];
    datesheet.selectDate = @"2015-12-08";
    datesheet.GetSelectDate = ^(NSString *dateStr) {
        NSLog(@"ok Date:%@", dateStr);
        
        // 显示生日
        UIButton *tfBtn1 = [self.view viewWithTag:1003];
        [tfBtn1 setTitle:dateStr forState:UIControlStateNormal];
        [tfBtn1 setTitleColor:FUIColorFromRGB(0x212121) forState:UIControlStateNormal];
        
        
        // 时间转时间戳的方法
        NSDate *date = [self dateFromString:dateStr];
        NSString *timeSp = [NSString stringWithFormat:@"%ld",(NSInteger)[date timeIntervalSince1970]];
        NSLog(@"%@",timeSp);
        NSInteger timeSpInteger = [timeSp integerValue];
        
        // 用户单例
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSDictionary *userInfoDic = [user objectForKey:@"userInfo"];
        
        if ([tfBtn1.titleLabel.text isEqualToString:@""] || [[userInfoDic objectForKey:@"birth_day"] isEqualToString:timeSp]) {
            
            // 数据未做改变
            
        }else {
            
            // 添加到用户修改资料字典
            [_userInfoDic setObject:@(
             timeSpInteger) forKey:@"birth_day"];
        }
    };
    
    [self.view addSubview:datesheet];
    
}


// 字符串转换成NSDate类型
- (NSDate *)dateFromString:(NSString *)dateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
}


// 弹出代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        UIButton *tfBtn1 = [self.view viewWithTag:1002];
        [tfBtn1 setTitleColor:FUIColorFromRGB(0x212121) forState:UIControlStateNormal];
        [tfBtn1 setTitle:@"男" forState:UIControlStateNormal];
        [_userInfoDic setObject:@"1" forKey:@"sex"];
        
    }else if (buttonIndex == 1) {
        
        UIButton *tfBtn1 = [self.view viewWithTag:1002];
        [tfBtn1 setTitleColor:FUIColorFromRGB(0x212121) forState:UIControlStateNormal];
        [tfBtn1 setTitle:@"女" forState:UIControlStateNormal];
        [_userInfoDic setObject:@"2" forKey:@"sex"];

        
    }else if(buttonIndex == 2) {
        
        // 保密
        UIButton *tfBtn1 = [self.view viewWithTag:1002];
        [tfBtn1 setTitleColor:FUIColorFromRGB(0x212121) forState:UIControlStateNormal];
        [tfBtn1 setTitle:@"保密" forState:UIControlStateNormal];
        [_userInfoDic setObject:@"0" forKey:@"sex"];
        
    }else if (buttonIndex == 3) {
        
        // 取消
        NSLog(@"取消");
    }
}



#pragma  mark - textField delegate
// 已经结束输入
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"3");//文本彻底结束编辑时调用
    if (textField.tag == 1000) {
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSDictionary *userInfo = [user objectForKey:@"userInfo"];
        
        // 昵称
        if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:[userInfo objectForKey:@"nickname"]]) {
            // 没有变动不做修改
        }else {
            // 修改用户资料字典
            [_userInfoDic setObject:textField.text forKey:@"nickname"];
        }
    }
    
    if (textField.tag == 1001) {
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSDictionary *userInfo = [user objectForKey:@"userInfo"];
        
        // 昵称
        if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:[userInfo objectForKey:@"sign"]]) {
            // 没有变动不做修改
        }else {
            // 修改用户资料字典
            [_userInfoDic setObject:textField.text forKey:@"sign"];
        }
    }
}



// 退出登录点击事件
- (void) logOutBtnClick {
    
    NSLog(@"点击了退出登录");
    
    // 极光推送删除绑定用户
    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        
    } seq:0];
    
    
    // 跳转到登录页面
    // 清除当前用户信息
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"token"];
    [user removeObjectForKey:@"severPublicKey"];
    [user removeObjectForKey:@"userInfo"];
    [user removeObjectForKey:@"AllFollowKeyWordId"];
    
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
    
    // 返回到我的主页页面
    [self.navigationController popToRootViewControllerAnimated:NO];
}


// 个人设置点击事件
- (void)MineSetClick:(UIButton *)btnMineSet {
    
    NSLog(@"%ld",(long)btnMineSet.tag);
    if (btnMineSet.tag == 100) {
        
        // 修改手机号
//        ChangePhoneViewController *vc = [[ChangePhoneViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
        HttpRequest *httpAlert = [[HttpRequest alloc] init];
        [httpAlert GetHttpDefeatAlert:@"暂时无法修改,敬请期待"];
        
        
    }else if (btnMineSet.tag == 101) {
        
        // 更换密码
        RevisePassViewController *vc = [[RevisePassViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else {
        
        // 啥也不是
    }
}

// 触发事件
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 释放第一响应者
    for (int i = 0; i < 2; i++) {
        UITextField *tf1 = [self.view viewWithTag:1000 + i];
        [tf1 resignFirstResponder];
    }
    
    
    
}


- (void) viewWillDisappear:(BOOL)animated {
    
    
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
