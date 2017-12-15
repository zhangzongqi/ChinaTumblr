//
//  PublishTextViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/7.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "PublishTextViewController.h"
#import "AddLabelViewController.h" // 添加标签页面

@interface PublishTextViewController ()<UITextViewDelegate,UIActionSheetDelegate> {
    
    NSMutableDictionary *_dicData; // 需要上传的内容
    
    UIButton *labelBtn; // 标签
    UIButton *locationBtn; // 当前位置
    UIButton *quanxianBtn; // 权限
}

@property (nonatomic,strong) UITextView *tfView; // 内容输入框

@property (nonatomic,copy) MBProgressHUD *HUD; // 动画

@end

@implementation PublishTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 背景色
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    
    // 初始化数据
    [self initDataSource];
    
    // 布局页面
    [self layoutViews];

}


// 初始化数据
- (void) initDataSource {
    
    _dicData = [[NSMutableDictionary alloc] init];
    [_dicData setValue:@"0" forKey:@"type"];
//    [_dicData setValue:@"" forKey:@"files"];
    [_dicData setValue:@"0" forKey:@"privateFlag"];
    [_dicData setValue:@"" forKey:@"position"];
}

// 布局页面
- (void) layoutViews {
    
    // 文字
    UILabel *titleLb = [[UILabel alloc] init];
    [self.view addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(34);
    }];
    titleLb.font = [UIFont systemFontOfSize:16];
    titleLb.textColor = [UIColor whiteColor];
    titleLb.text = @"文字";
    
    // 取消按钮
    UIButton *cancleBtn = [[UIButton alloc] init];
    [self.view addSubview:cancleBtn];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLb);
        make.left.equalTo(self.view).with.offset(18);
    }];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor colorWithRed:124/255.0 green:125/255.0 blue:126/255.0 alpha:1.0] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancleBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 发布按钮
    UIButton *publishBtn = [[UIButton alloc] init];
    [self.view addSubview:publishBtn];
    [publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLb);
        make.right.equalTo(self.view).with.offset(-18);
    }];
    [publishBtn setTitle:@"发布" forState:UIControlStateNormal];
    [publishBtn setTitleColor:[UIColor colorWithRed:124/255.0 green:125/255.0 blue:126/255.0 alpha:1.0] forState:UIControlStateNormal];
    publishBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [publishBtn addTarget:self action:@selector(publishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 白色背景
    UIView *whiteBackView = [[UIView alloc] init];
    [self.view addSubview:whiteBackView];
    [whiteBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view).with.offset(64);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(W * 0.4375));
    }];
    whiteBackView.backgroundColor = [UIColor whiteColor];
    
    
    // 输入框
    _tfView = [[UITextView alloc] init];
    [whiteBackView addSubview:_tfView];
    [_tfView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(whiteBackView).with.offset(10);
        make.left.equalTo(whiteBackView).with.offset(10);
        make.right.equalTo(whiteBackView).with.offset(-10);
        make.height.equalTo(@(W * 0.4375 - 18));
    }];
    // 是否可编辑
    _tfView.editable = YES;
    //设置代理
    _tfView.delegate = self;
    if (_model == nil) {
        //设置内容
        _tfView.text = @"说点什么吧...";
        //字体颜色
        _tfView.textColor = FUIColorFromRGB(0x999999);
    }else {
        //设置内容
        _tfView.text = _model.content;
        //字体颜色
        _tfView.textColor = FUIColorFromRGB(0x4e4e4e);
    }
    //设置字体
    _tfView.font = [UIFont systemFontOfSize:14];
    // 变成第一响应者
    [_tfView becomeFirstResponder];
    
    // 标签
    labelBtn = [[UIButton alloc] init];
    [self.view addSubview:labelBtn];
    [labelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(whiteBackView.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        make.height.equalTo(@(H * 0.0546));
    }];
    labelBtn.backgroundColor = [UIColor whiteColor];
    labelBtn.imageView.sd_layout
    .centerYEqualToView(labelBtn)
    .leftSpaceToView(labelBtn,22)
    .heightIs(13)
    .widthIs(11);
    labelBtn.titleLabel.sd_layout
    .centerYEqualToView(labelBtn)
    .leftSpaceToView(labelBtn.imageView, 12)
    .heightRatioToView(labelBtn, 0.5);
    [labelBtn setImage:[UIImage imageNamed:@"add_icon2"] forState:UIControlStateNormal];
    [labelBtn setTitleColor:FUIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    labelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [labelBtn addTarget:self action:@selector(labelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    // 分割线
    UILabel *fengeLb = [[UILabel alloc] init];
    [self.view addSubview:fengeLb];
    [fengeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labelBtn.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        make.height.equalTo(@(1.5));
    }];
    fengeLb.backgroundColor = FUIColorFromRGB(0xeeeeee);
    
    
    // 当前位置
    locationBtn = [[UIButton alloc] init];
    [self.view addSubview:locationBtn];
    [locationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fengeLb.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        make.height.equalTo(@(H * 0.0546 + 1));
    }];
    locationBtn.backgroundColor = [UIColor whiteColor];
    locationBtn.imageView.sd_layout
    .centerYEqualToView(locationBtn)
    .leftSpaceToView(locationBtn,22)
    .heightIs(14)
    .widthIs(14);
    locationBtn.titleLabel.sd_layout
    .centerYEqualToView(locationBtn).offset(-1)
    .leftSpaceToView(locationBtn.imageView, 12)
    .heightRatioToView(locationBtn, 0.5);
    [locationBtn setImage:[UIImage imageNamed:@"publish_icon4"] forState:UIControlStateNormal];
    [locationBtn setTitleColor:FUIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    locationBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    if (_model == nil) {
        [locationBtn setTitle:@"当前位置" forState:UIControlStateNormal];
    }else {
        [locationBtn setTitle:_model.position forState:UIControlStateNormal];
    }
    locationBtn.hidden = YES;
    // 分割线
//    UILabel *lbFenge2 = [[UILabel alloc] init];
//    [locationBtn addSubview:lbFenge2];
//    [lbFenge2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(locationBtn);
//        make.left.equalTo(self.view).with.offset(20);
//        make.width.equalTo(@(W - 20));
//        make.height.equalTo(@(1));
//    }];
//    lbFenge2.backgroundColor = FUIColorFromRGB(0xeeeeee);
    
    
    // 权限btn
    quanxianBtn = [[UIButton alloc] init];
    [self.view addSubview:quanxianBtn];
    [quanxianBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(locationBtn);
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        make.height.equalTo(@(H * 0.0546));
    }];
    quanxianBtn.backgroundColor = [UIColor whiteColor];
    quanxianBtn.imageView.sd_layout
    .centerYEqualToView(quanxianBtn)
    .leftSpaceToView(quanxianBtn, 22)
    .heightIs(13)
    .widthIs(13);
    quanxianBtn.titleLabel.sd_layout
    .centerYEqualToView(quanxianBtn)
    .leftSpaceToView(quanxianBtn.imageView, 10)
    .heightRatioToView(quanxianBtn, 0.5);
    [quanxianBtn setImage:[UIImage imageNamed:@"publish_icon5"] forState:UIControlStateNormal];
    [quanxianBtn setTitleColor:FUIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    quanxianBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [quanxianBtn addTarget:self action:@selector(quanxianBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    if (_model == nil) {
        [quanxianBtn setTitle:@"公开" forState:UIControlStateNormal];
    }else {
        if ([_model.private_flag isEqualToString:@"0"]) {
            [quanxianBtn setTitle:@"公开" forState:UIControlStateNormal];
        }else {
            NSLog(@":::::::::%@",_model);
            [quanxianBtn setTitle:@"私有" forState:UIControlStateNormal];
            [_dicData setValue:@"1" forKey:@"privateFlag"];
        }
    }
}

// 权限点击事件
- (void) quanxianBtnClick:(UIButton *)btn {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"公开", @"私有",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
    actionSheet.delegate = self;
}

// 弹出代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        [_dicData setValue:@"0" forKey:@"privateFlag"];
        [quanxianBtn setTitle:@"公开" forState:UIControlStateNormal];
        
    }else if (buttonIndex == 1) {
        
        [_dicData setValue:@"1" forKey:@"privateFlag"];
        [quanxianBtn setTitle:@"私有" forState:UIControlStateNormal];
        
    }else {
    
        NSLog(@"取消");
    }
}

// labelBtn点击事件
- (void) labelBtnClick:(UIButton *)labelBtn1 {
    
    
    AddLabelViewController *vc = [[AddLabelViewController alloc] init];
    if (labelBtn.selected == NO) {
        
    }else {
        vc.strCurrentLabel = labelBtn.titleLabel.text;
    }
    [self presentViewController:vc animated:YES completion:nil];
    
}

#pragma mark - UITextViewDelegate协议中的方法
//将要进入编辑模式
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if ([_tfView.text isEqualToString:@"说点什么吧..."]) {
        
        //设置内容
        _tfView.text = @"";
        //字体颜色
        _tfView.textColor = FUIColorFromRGB(0x4e4e4e);
        //设置字体
        _tfView.font = [UIFont systemFontOfSize:14];
    }
    
    return YES;
}
//已经进入编辑模式
- (void)textViewDidBeginEditing:(UITextView *)textView{}
//将要结束/退出编辑模式
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{return YES;}
//已经结束/退出编辑模式
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    [_dicData setValue:textView.text forKey:@"content"];
    
    if ([_tfView.text isEqualToString:@""]) {
        //设置字体
        _tfView.font = [UIFont systemFontOfSize:12];
        //设置内容
        _tfView.text = @"说点什么吧...";
        //字体颜色
        _tfView.textColor = FUIColorFromRGB(0x999999);
    }
}
//当textView的内容发生改变的时候调用
- (void)textViewDidChange:(UITextView *)textView{}
//选中textView 或者输入内容的时候调用
- (void)textViewDidChangeSelection:(UITextView *)textView{}
//从键盘上将要输入到textView 的时候调用
//rangge  光标的位置
//text  将要输入的内容
//返回YES 可以输入到textView中  NO不能
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{return YES;}


// 触摸屏幕触发事件
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if ([_tfView isFirstResponder]) {
        [_tfView resignFirstResponder];
    }
}


// 发布按钮点击事件
- (void) publishBtnClick {
    
    // 点击了发布按钮
    NSLog(@"点击了发布");
    
    // 释放第一响应者
    [_tfView resignFirstResponder];
    
    if ([[[_dicData objectForKey:@"content"] stringByReplacingOccurrencesOfString:@" "  withString:@""] isEqualToString:@""]) {
        
        // 内容
        [MBHUDView hudWithBody:@"说点什么吧" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
    }else if ([[_dicData objectForKey:@"keywords"] isEqualToString:@""] || [labelBtn.titleLabel.text isEqualToString:@""]){
        
        // 关键词
        [MBHUDView hudWithBody:@"标签为空" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
    }else if (_tfView.text.length > 300) {
        
        // 关键词
        [MBHUDView hudWithBody:@"最多300字~" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
    }else {
        
        
        // 创建动画
        _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // 展示动画
        [_HUD show:YES];
        
        // 获取到用户相关的加密信息
        NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
        // 进行发帖请求
        HttpRequest *http = [[HttpRequest alloc] init];
        
        
        if (_model == nil) {
            
            NSLog(@"fhdsjabfhjdsabfhajs%@",_dicData);
            
            NSString *dataStrJiaMi = [[MakeJson createJson:_dicData] AES128EncryptWithKey:userJiaMiArr[3]];
            
            NSDictionary *dicData111 = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStrJiaMi};
            NSLog(@"dicData111:%@",dicData111);
            
            // 发布
            [http PostAddNoteWithDic:dicData111 Success:^(id userInfo) {
                
                if ([userInfo isEqualToString:@"0"]) {
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    
                }
                if ([userInfo isEqualToString:@"1"]) {
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    
                    // 发帖成功
                    [MBHUDView hudWithBody:@"发帖成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                    
//                    // 创建消息中心
//                    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
//                    // 在消息中心发布自己的消息
//                    [notiCenter postNotificationName:@"fatieChengGong" object:@"20"];
                    
                    // 等一秒跳转回首页
                    // 1秒后，跳转
                    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(tiaozhuanEvent) userInfo:nil repeats:NO];
                }
                
            } failure:^(NSError *error) {
                
                // 网络请求失败
                
                // 隐藏动画
                [_HUD hide:YES];
            }];
            
        }else {
            
            // 帖子Id
            [_dicData setValue:_model.id1 forKey:@"id"];
            
            NSLog(@"fhdsjabfhjdsabfhajs%@",_dicData);
            
            // 修改
            NSString *dataStrJiaMi = [[MakeJson createJson:_dicData] AES128EncryptWithKey:userJiaMiArr[3]];
            
            NSDictionary *dicData111 = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStrJiaMi};
            NSLog(@"dicData111:%@",dicData111);
            
            // 修改
            [http PostEditNoteWithDic:dicData111 Success:^(id userInfo) {
                
                if ([userInfo isEqualToString:@"0"]) {
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    
                    // 修改失败
                    
                }
                if ([userInfo isEqualToString:@"1"]) {
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    
                    // 修改成功
                    [MBHUDView hudWithBody:@"修改成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                    
                    
                    
                    
                    
                    
                    // 创建消息中心
                    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
                    // 在消息中心发布自己的消息,
                    [notiCenter postNotificationName:@"reviseTieZiSuccess" object:@"6666" userInfo:_dicData];
                    
                    
                    
                    
                    
                    // 等一秒跳转回首页
                    // 1秒后，跳转
                    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(tiaozhuanEvent) userInfo:nil repeats:NO];
                }
                
            } failure:^(NSError *error) {
                
                // 网络请求失败
                
                // 隐藏动画
                [_HUD hide:YES];
            }];
            
        }
        
    }
    
}

// 发帖成功后消失当前页
- (void) tiaozhuanEvent {
    
    // 标签数组消失
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"labelArr"];
    
    // 消失本页面
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 取消按钮点击事件
- (void) cancleBtnClick {
    
    // 标签数组消失
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"labelArr"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

// 页面将要消失
- (void) viewWillDisappear:(BOOL)animated {
    
    
}

// 页面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [user objectForKey:@"labelArr"];
    if ([arr count] == 0) {
        
        [_dicData setValue:@"" forKey:@"keywords"];
        
        if (_model == nil) {
            
            [labelBtn setTitle:@"标签" forState:UIControlStateNormal];
            labelBtn.selected = NO;
        }else {
            if (_model.kwList == nil) {
                [labelBtn setTitle:@"标签" forState:UIControlStateNormal];
                labelBtn.selected = NO;
            }else {
                NSString *str = [_model.kwList stringByReplacingOccurrencesOfString:@"," withString:@" "];
                [labelBtn setTitle:str forState:UIControlStateNormal];
                labelBtn.selected = YES;
                // 加入需要传入的参数字典
                [_dicData setValue:_model.kwList forKey:@"keywords"];
            }
        }
    
    }else {
        
        NSString *strLabel = [[NSString alloc] init];
        NSString *strLableForDicData = [[NSString alloc] init];
        for (int i = 0; i < arr.count; i++) {
            
            if (i == 0) {
                
                strLabel = arr[i];
                strLableForDicData = arr[i];
                
            }else {
                strLabel = [NSString stringWithFormat:@"%@ %@",strLabel,arr[i]];
                strLableForDicData = [NSString stringWithFormat:@"%@,%@",strLableForDicData,arr[i]];
            }
        }
        
        [labelBtn setTitle:strLabel forState:UIControlStateNormal];
        labelBtn.selected = YES;
        
        // 加入需要传入的参数字典
        [_dicData setValue:strLableForDicData forKey:@"keywords"];
    };
    
    //这个接口可以动画的改变statusBar的前景色
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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
