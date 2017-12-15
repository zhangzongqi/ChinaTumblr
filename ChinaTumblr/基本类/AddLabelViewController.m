//
//  AddLabelViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/11.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "AddLabelViewController.h"
#import <TTGTagCollectionView/TTGTextTagCollectionView.h>

@interface AddLabelViewController ()<UITextViewDelegate,TTGTextTagCollectionViewDelegate> {
    
    NSMutableArray *_labelMutArr; // 用于存储标签
}

@property (nonatomic,strong) UITextView *tfView; // 内容输入框
@property (nonatomic,copy) UICollectionView *collectionView; // 多行多列表格

@property (nonatomic,copy) TTGTextTagCollectionView *tagCollectionView; // 标签collectionView


@end

@implementation AddLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化数组
    [self initDataSource];
    
    // 背景色
    self.view.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 布局页面
    [self layoutViews];
}

// 初始化数组
- (void) initDataSource {
    
    _labelMutArr = [NSMutableArray array];
}

// 布局页面
- (void) layoutViews {
    
    // 导航栏
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, 64)];
    [self.view addSubview:navView];
    navView.backgroundColor = FUIColorFromRGB(0xffffff);
    
    // 导航栏与下面视图的分割线
    UILabel *lbFenge = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, W, 1)];
    [self.view addSubview:lbFenge];
    lbFenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
    
    
    // 标题
    UILabel *lbTitle = [[UILabel alloc] init];
    [navView addSubview:lbTitle];
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(navView).with.offset(10);
        make.centerX.equalTo(navView);
        make.height.equalTo(@(17));
    }];
    lbTitle.font = [UIFont systemFontOfSize:17];
    lbTitle.textColor = FUIColorFromRGB(0x212121);
    lbTitle.text = @"添加标签";
    
    // 返回按钮
    UIButton *backBtn = [[UIButton alloc] init];
    [navView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(navView).with.offset(10);
        make.centerY.equalTo(navView).with.offset(10);
        make.width.equalTo(@(50));
        make.height.equalTo(@(30));
    }];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    // 返回按钮点击事件
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    
    // 右侧按钮
    UIButton *rightBtn = [[UIButton alloc] init];
    [navView addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(navView).with.offset(-10);
        make.centerY.equalTo(navView).with.offset(10);
        make.width.equalTo(@(50));
        make.height.equalTo(@(30));
    }];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [rightBtn setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // #label
    UILabel *jinghaoLb = [[UILabel alloc] init];
    [self.view addSubview:jinghaoLb];
    [jinghaoLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(20);
        make.top.equalTo(lbFenge.mas_bottom).with.offset(15);
        make.height.equalTo(@(16));
    }];
    jinghaoLb.font = [UIFont systemFontOfSize:16];
    jinghaoLb.text = @"#";
    jinghaoLb.textColor = FUIColorFromRGB(0x212121);
    
    
    // 输入框
    _tfView = [[UITextView alloc] init];
    [self.view addSubview:_tfView];
    [_tfView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(jinghaoLb).with.offset(- 8);
        make.left.equalTo(jinghaoLb.mas_right).with.offset(2);
        make.right.equalTo(self.view).with.offset(-10);
        make.height.equalTo(@(W * 0.4375 - 18));
    }];
    // 是否可编辑
    _tfView.editable = YES;
    //设置代理
    _tfView.delegate = self;
    //设置字体
    _tfView.font = [UIFont systemFontOfSize:14];
    if (_strCurrentLabel.length != 0) {
        //设置内容
        _tfView.text = _strCurrentLabel;
        //字体颜色
        _tfView.textColor = FUIColorFromRGB(0x4e4e4e);
    }else {
        //设置内容
        _tfView.text = @"多个标签请用空格分隔...";
        //字体颜色
        _tfView.textColor = FUIColorFromRGB(0x999999);
    }
    
    
    // 分隔线2
    UILabel *lbFenge2 = [[UILabel alloc] init];
    [self.view addSubview:lbFenge2];
    [lbFenge2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tfView.mas_bottom);
        make.right.equalTo(self.view);
        make.left.equalTo(self.view).with.offset(20);
        make.height.equalTo(@(1));
    }];
    lbFenge2.backgroundColor = FUIColorFromRGB(0xeeeeee);
    
    // 推荐label
//    UILabel *tuijianLb = [[UILabel alloc] init];
//    [self.view addSubview:tuijianLb];
//    [tuijianLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(lbFenge2);
//        make.top.equalTo(lbFenge2.mas_bottom).with.offset(10);
//        make.height.equalTo(@(15));
//    }];
//    tuijianLb.textColor = FUIColorFromRGB(0xfeaa0a);
//    tuijianLb.text = @"推荐";
//    tuijianLb.font = [UIFont systemFontOfSize:15];
//    
//    [tuijianLb layoutIfNeeded];
//    [self.view layoutIfNeeded];
    
//    _tagCollectionView = [[TTGTextTagCollectionView alloc] initWithFrame:CGRectMake(15, tuijianLb.frame.size.height + tuijianLb.frame.origin.y + 10, W - 15, 500)];
//    [self.view addSubview:_tagCollectionView];
//    [_tagCollectionView addTags:@[@"#音乐", @"#摄影", @"#健身", @"#博物馆",@"#艺术",@"#乒乓球",@"#棋",@"#音乐", @"#摄影", @"#健身", @"#博物馆",@"#艺术",@"#乒乓球",@"#棋"]];
//
//    _tagCollectionView.delegate = self;
//    // Style
//    TTGTextTagConfig *config = _tagCollectionView.defaultConfig;
//    config.tagTextFont = [UIFont systemFontOfSize:15.0f];
//    config.tagExtraSpace = CGSizeMake(10, 10);
//    config.tagTextColor = FUIColorFromRGB(0x999999);
//    config.tagSelectedTextColor = [UIColor whiteColor];
//    config.tagBackgroundColor = [UIColor colorWithRed:246/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
//    config.tagSelectedBackgroundColor = FUIColorFromRGB(0xfeaa0a);
//    config.tagCornerRadius = 14.0f;
//    config.tagSelectedCornerRadius = 14.0f;
//    
//    config.tagBorderWidth = 0;
//    
//    config.tagBorderColor = [UIColor whiteColor];
//    config.tagSelectedBorderColor = [UIColor whiteColor];
//    
//    config.tagShadowColor = [UIColor clearColor];
//    config.tagShadowOffset = CGSizeMake(0, 0);
//    config.tagShadowOpacity = 0.0f;
//    config.tagShadowRadius = 0;
//    
//    [_tagCollectionView reload];
    
}


#pragma mark ------TTGTextTagCollectionViewDelegate------
// collectionView的点击事件
//- (void)textTagCollectionView:(TTGTextTagCollectionView *)textTagCollectionView didTapTag:(NSString *)tagText atIndex:(NSUInteger)index selected:(BOOL)selected {
//    
//    NSLog(@"Tap tag: %@, at: %ld, selected: %d", tagText, (long) index, selected);
//    
//    
//    // 选中了
//    if (selected == YES) {
//        
//        // 变成第一响应者
//        [_tfView becomeFirstResponder];
//        // 修改输入框内容
//        _tfView.text = [NSString stringWithFormat:@"%@ %@",_tfView.text,[tagText stringByReplacingOccurrencesOfString:@"#" withString:@""]];
//        
//    }else {
//        
//        // 修改输入框内容
//        _tfView.text = [_tfView.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@",[tagText stringByReplacingOccurrencesOfString:@"#" withString:@""]] withString:@""];
//        
//        if ([_tfView.text isEqualToString:@""]) {
//            
//            //设置内容
//            _tfView.text = @"多个标签请用空格分隔...";
//            //字体颜色
//            _tfView.textColor = FUIColorFromRGB(0x999999);
//            [_tfView resignFirstResponder];
//        }
//    }
//}


#pragma mark - UITextViewDelegate协议中的方法
//将要进入编辑模式
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if ([_tfView.text isEqualToString:@"多个标签请用空格分隔..."]) {
        
        //设置内容
        _tfView.text = @"";
        //字体颜色
        _tfView.textColor = FUIColorFromRGB(0x4e4e4e);
    }
    
    
    
    return YES;
}
//已经进入编辑模式
- (void)textViewDidBeginEditing:(UITextView *)textView{}
//将要结束/退出编辑模式
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{return YES;}
//已经结束/退出编辑模式
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    if ([_tfView.text isEqualToString:@""]) {
        //设置内容
        _tfView.text = @"多个标签请用空格分隔...";
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



// 返回按钮点击事件
- (void) doBack:(UIButton *)backBtn {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


// 导航栏右侧按钮点击事件
- (void)rightBtnClick:(UIButton *)menuBtn {
    
    NSLog(@"点击了完成");
    
    // 释放第一响应者
    [_tfView resignFirstResponder];
    
    if ([_tfView.text isEqualToString:@"多个标签请用空格分隔..."]) {
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:_labelMutArr forKey:@"labelArr"];
        
    }else {
        
        _tfView.text = [_tfView.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        _labelMutArr =[NSMutableArray arrayWithArray:[_tfView.text componentsSeparatedByString:@" "]];
        for (int i = 0; i < _labelMutArr.count; i++) {
            if ([_labelMutArr[i] isEqualToString:@""]) {
                [_labelMutArr removeObjectAtIndex:i];
                i = i-1;
            }
        }
        NSLog(@"_labelMutArr:%@",_labelMutArr);
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:_labelMutArr forKey:@"labelArr"];
        NSLog(@"useruseruseruser%@",[user objectForKey:@"labelArr"]);
    }
    
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    //这个接口可以动画的改变statusBar的前景色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}
- (void) viewWillAppear:(BOOL)animated {
    
    //这个接口可以动画的改变statusBar的前景色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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
