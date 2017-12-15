//
//  ShareAndOtherView.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/10/10.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "ShareAndOtherView.h"

#define Width self.frame.size.width
#define Height self.frame.size.height

@implementation ShareAndOtherView

// 创建frame
- (id)initWithFrame:(CGRect)frame {
    
    // 309 高度
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        NSArray *arrForName = @[@"微信好友",@"朋友圈",@"微信收藏",@"QQ",@"QQ空间"];
        NSArray *arrForImg = @[@"sheet_Share",@"sheet_Moments",@"sheet_Collection",@"sheet_qq",@"sheet_qzone"];
        
        
        self.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        
        // 提示语
        UILabel *lbTip = [[UILabel alloc] init];
        [self addSubview:lbTip];
        [lbTip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(10);
            make.centerX.equalTo(self);
        }];
        lbTip.font = [UIFont systemFontOfSize:15];
        lbTip.text = @"分享";
        lbTip.textColor = [UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1.0];
        
        
        // 分隔线
        UIView *fengeView = [[UIView alloc] initWithFrame:CGRectMake(20, 309 - 49 - 110, Width, 0.5)];
        fengeView.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
        [self addSubview:fengeView];
        
        // 取消按钮
        _cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 309 - 49, Width, 49)];
        [self addSubview:_cancleBtn];
        _cancleBtn.backgroundColor = FUIColorFromRGB(0xffffff);
        [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:FUIColorFromRGB(0x212121) forState:UIControlStateNormal];
        
        
        // 上部分滚动图
        UIScrollView *topScrollView = [[UIScrollView alloc] init];
        [self addSubview:topScrollView];
        [topScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lbTip.mas_bottom).with.offset(10);
            make.bottom.equalTo(fengeView.mas_top);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        topScrollView.alwaysBounceVertical = NO;
        topScrollView.alwaysBounceHorizontal = YES;
        
        
        for (int i = 0; i < arrForImg.count; i++) {
            
            UIButton *btn = [[UIButton alloc] init];
            [topScrollView addSubview:btn];
            btn.tag = i;
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(topScrollView);
                make.left.equalTo(topScrollView.mas_left).with.offset(15*(i+1) + 60*i);
                make.height.equalTo(@(95));
                make.width.equalTo(@(60));
            }];
            btn.imageView.sd_layout
            .centerXEqualToView(btn)
            .topEqualToView(btn)
            .widthIs(60)
            .heightIs(60);
            btn.titleLabel.sd_layout
            .topSpaceToView(btn.imageView, 5)
            .centerXEqualToView(btn)
            .widthIs(60)
            .heightIs(30);
            [btn setTitleColor:FUIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            btn.titleLabel.numberOfLines = 0;
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn setTitle:arrForName[i] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:arrForImg[i]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        
        // 下部分滚动图
        UIScrollView *bottomScrollView = [[UIScrollView alloc] init];
        [self addSubview:bottomScrollView];
        [bottomScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(fengeView.mas_bottom);
            make.bottom.equalTo(_cancleBtn.mas_top);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        bottomScrollView.alwaysBounceVertical = NO;
        bottomScrollView.alwaysBounceHorizontal = YES;
        
        // 拉黑
        _disLikeBtn = [[UIButton alloc] init];
        [bottomScrollView addSubview:_disLikeBtn];
        [_disLikeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomScrollView);
            make.left.equalTo(bottomScrollView).with.offset((Width - 120) / 3);
            make.height.equalTo(@(78));
            make.width.equalTo(@(60));
        }];
        _disLikeBtn.imageView.sd_layout
        .centerXEqualToView(_disLikeBtn)
        .topEqualToView(_disLikeBtn)
        .widthIs(60)
        .heightIs(60);
        _disLikeBtn.titleLabel.sd_layout
        .topSpaceToView(_disLikeBtn.imageView, 5)
        .centerXEqualToView(_disLikeBtn)
        .widthIs(60)
        .heightIs(13);
        [_disLikeBtn setTitleColor:FUIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
        _disLikeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _disLikeBtn.titleLabel.numberOfLines = 0;
        _disLikeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_disLikeBtn setTitle:@"拉黑此人" forState:UIControlStateNormal];
        [_disLikeBtn setImage:[UIImage imageNamed:@"icon_shielding"] forState:UIControlStateNormal];
        
        
        // 举报按钮
        _jubaoBtn = [[UIButton alloc] init];
        [bottomScrollView addSubview:_jubaoBtn];
        [_jubaoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomScrollView);
            make.left.equalTo(bottomScrollView).with.offset((Width - 120)/3*2 + 60);
            make.height.equalTo(@(78));
            make.width.equalTo(@(60));
        }];
        _jubaoBtn.imageView.sd_layout
        .centerXEqualToView(_jubaoBtn)
        .topEqualToView(_jubaoBtn)
        .widthIs(60)
        .heightIs(60);
        _jubaoBtn.titleLabel.sd_layout
        .topSpaceToView(_jubaoBtn.imageView, 5)
        .centerXEqualToView(_jubaoBtn)
        .widthIs(60)
        .heightIs(13);
        [_jubaoBtn setTitleColor:FUIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
        _jubaoBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _jubaoBtn.titleLabel.numberOfLines = 0;
        _jubaoBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_jubaoBtn setTitle:@"举报" forState:UIControlStateNormal];
        [_jubaoBtn setImage:[UIImage imageNamed:@"icon_complain"] forState:UIControlStateNormal];
        
    }
    
    return self;
}

// 分享点击事件
- (void) btnClick:(UIButton *)sender {
    
    
    switch (sender.tag) {
        case 0:
        {
            // 微信好友
            [self fenxiangWithType:SSDKPlatformSubTypeWechatSession];
        }
            break;
        case 1:
        {
            // 朋友圈
            [self fenxiangWithType:SSDKPlatformSubTypeWechatTimeline];
        }
            break;
        case 2:
        {
            // 微信收藏
            [self fenxiangWithType:SSDKPlatformSubTypeWechatFav];
        }
            break;
        case 3:
        {
            // QQ
            [self fenxiangWithType:SSDKPlatformSubTypeQQFriend];
        }
            break;
        case 4:
        {
            
            // QQ空间
            [self fenxiangWithType:SSDKPlatformSubTypeQZone];
        }
            break;
            
        default:
            break;
    }
}


- (void) fenxiangWithType:(SSDKPlatformType)type {
    
    NSArray* imageArray = @[[UIImage imageNamed:@"logo的副本"]];
    NSString *strTitle = @"嘚瑟";
    NSString *strSummry = @"你，值得被追随\n他，嘚瑟却不失本色\n只有你，配得上我的特别";
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:strSummry images:imageArray url:[NSURL URLWithString:@"https://app.blog.huopinb.com/Update.html"]title:strTitle type:SSDKContentTypeAuto];
    
    // 微信好友
    [ShareSDK share:type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil];
                [alertView show];
                break;
            }
            case SSDKResponseStateFail:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            default:
                break;
        }
    }];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
