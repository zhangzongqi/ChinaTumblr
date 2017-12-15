//
//  HomeTextCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/14.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "SearchDetailTextCell.h"
#import "SearchLabelDeatilViewController.h"
#import "AppDelegate.h"

#define Width [[UIScreen mainScreen] bounds].size.width

#define KPraiseBtnWH 30
#define KToBrokenHeartWH    120/195

@implementation SearchDetailTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    
    // 640*646   页面大小
    
    // 点击时，无效果
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = FUIColorFromRGB(0xffffff);
        
        
        backView = [[UIView alloc] init];
        [self.contentView addSubview:backView];
        backView.backgroundColor = FUIColorFromRGB(0xffffff);
        
        
        // 头像图片
        _iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 36, 36)];
        [backView addSubview:_iconImgView];
        _iconImgView.layer.cornerRadius = 18;
        _iconImgView.clipsToBounds = YES;
        _iconImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconImgClick:)];
        [_iconImgView addGestureRecognizer:tap];
        
        // 昵称
        _nickNameLb = [[UILabel alloc] init];
        [backView addSubview:_nickNameLb];
        [_nickNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_iconImgView);
            make.left.equalTo(_iconImgView.mas_right).with.offset(0.0234375 * Width);
        }];
        _nickNameLb.font = [UIFont systemFontOfSize:15];
        _nickNameLb.textColor = FUIColorFromRGB(0x212121);
        
        // 时间label
        _timeLb = [[UILabel alloc] init];
        [backView addSubview:_timeLb];
        [_timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_nickNameLb);
            make.left.equalTo(_nickNameLb.mas_right).with.offset(0.0234375 * Width);
        }];
        _timeLb.textColor = FUIColorFromRGB(0x4e4e4e);
        _timeLb.font = [UIFont systemFontOfSize:13];
        
        // 个人操作按钮
        _gerenBtn = [[UIButton alloc] init];
        [backView addSubview:_gerenBtn];
        [_gerenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_nickNameLb);
            make.right.equalTo(self);
            make.height.equalTo(@(Width * 0.625));
            make.width.equalTo(@(20 + 0.0234375 * Width + 10));
        }];
        _gerenBtn.imageView.sd_layout
        .centerXEqualToView(_gerenBtn)
        .centerYEqualToView(_gerenBtn)
        .widthIs(20)
        .heightIs(20);
        [_gerenBtn setImage:[UIImage imageNamed:@"personal_icon2"] forState:UIControlStateNormal];
        [_gerenBtn addTarget:self action:@selector(gerenButtonViewClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 右侧按钮
        _rightBtn = [[UIButton alloc] init];
        [backView addSubview:_rightBtn];
        [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).with.offset(- 0.0234375 * Width);
            make.height.equalTo(@(36));
            make.centerY.equalTo(_iconImgView);
        }];
        [_rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 发布的文字
        _lbText = [[UILabel alloc] init];
        [backView addSubview:_lbText];
        [_lbText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImgView.mas_bottom).with.offset(8);
            make.left.equalTo(self.contentView).with.offset(0.03125 * Width);
            make.width.equalTo(@(Width - 0.03125 * Width * 2));
        }];
        _lbText.numberOfLines = 0;
        _lbText.textColor = FUIColorFromRGB(0x212121);
        _lbText.font = [UIFont systemFontOfSize:14];
        
        
        // 分割线
        lbFenGe1 = [[UILabel alloc] init];
        [backView addSubview:lbFenGe1];
        [lbFenGe1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_lbText.mas_bottom).with.offset(0.03125 * Width);
            make.left.equalTo(_lbText);
            make.right.equalTo(backView);
            make.height.equalTo(@(0.5));
        }];
        lbFenGe1.backgroundColor = FUIColorFromRGB(0x999999);
        
        
        // 喜欢按钮背景点击
        UIButton *btnPraiseBtnBack = [[UIButton alloc] init];
        [backView addSubview:btnPraiseBtnBack];
        [btnPraiseBtnBack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView);
            make.top.equalTo(lbFenGe1.mas_bottom);
            make.width.equalTo(@(20 + 0.03 * Width));
            make.height.equalTo(@(20 + 0.05625 * Width));
        }];
        [btnPraiseBtnBack addTarget:self action:@selector(loveBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 喜欢按钮
        _praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backView addSubview:self.praiseBtn];
//        _praiseBtn.frame = CGRectMake(0.03125 * Width, lbFenGe1.frame.origin.y + lbFenGe1.frame.size.height + 0.028125 * Width, 20, 20);
        [_praiseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lbFenGe1).with.offset(- 0.015 * Width);
            make.top.equalTo(lbFenGe1.mas_bottom).with.offset(0.013125 * Width);
            make.height.equalTo(@(20 + 0.03 * Width));
            make.width.equalTo(@(20 + 0.03 * Width));
        }];
        _praiseBtn.imageView.sd_layout
        .centerXEqualToView(_praiseBtn)
        .centerYEqualToView(_praiseBtn)
        .widthIs(20)
        .heightIs(20);
        [_praiseBtn setImage:[UIImage imageNamed:@"index_icon1"] forState:UIControlStateNormal];
        [_praiseBtn setImage:[UIImage imageNamed:@"index_icon1on"] forState:UIControlStateSelected];
        
        
        _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backView addSubview:self.coverBtn];
        [_coverBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.praiseBtn);
            make.left.equalTo(self.praiseBtn);
            make.width.equalTo(@(20));
            make.height.equalTo(@(20));
        }];;
        _coverBtn.alpha = 0;
        [_coverBtn setImage:[UIImage imageNamed:@"big"] forState:UIControlStateSelected];
        [_coverBtn setImage:[UIImage imageNamed:@"big"] forState:UIControlStateNormal];
        
        [backView insertSubview:self.coverBtn belowSubview:self.praiseBtn];
        _cancelPraiseImg = [[UIImageView alloc]init];
        [backView addSubview:self.cancelPraiseImg];
        [_cancelPraiseImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.praiseBtn).with.offset(-15);
            make.top.equalTo(self.praiseBtn).with.offset(-40);
            make.width.equalTo(@(KPraiseBtnWH*1.5));
            make.height.equalTo(@(KPraiseBtnWH*1.5*KToBrokenHeartWH));
        }];
        _cancelPraiseImg.hidden = YES;
        _cancelPraiseImg.centerX = _praiseBtn.centerX;
        [self.praiseBtn addTarget:self action:@selector(loveBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // 评论按钮
        _pinglunBtn = [[UIButton alloc] init];
        [backView addSubview:_pinglunBtn];
        [_pinglunBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.praiseBtn);
            make.left.equalTo(self.praiseBtn.mas_right);
            make.width.equalTo(@(20 + 0.03 * Width));
            make.height.equalTo(@(20 + 0.05625 * Width));
        }];
        _pinglunBtn.imageView.sd_layout
        .leftSpaceToView(_pinglunBtn, 0.015 * Width)
        .centerYEqualToView(_pinglunBtn)
        .widthIs(20)
        .heightIs(20);
        [_pinglunBtn setImage:[UIImage imageNamed:@"index_icon2"] forState:UIControlStateNormal];
        [_pinglunBtn addTarget:self action:@selector(pinglunBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 分享按钮
        _shareBtn = [[UIButton alloc] init];
        [backView addSubview:_shareBtn];
        [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.praiseBtn);
            make.left.equalTo(_pinglunBtn.mas_right);
            make.width.equalTo(@(20 + 0.03 * Width));
            make.height.equalTo(@(20 + 0.05625 * Width));
        }];
        _shareBtn.imageView.sd_layout
        .leftSpaceToView(_shareBtn, 0.015 * Width)
        .centerYEqualToView(_shareBtn)
        .widthIs(20)
        .heightIs(20);
        [_shareBtn setImage:[UIImage imageNamed:@"index_icon3"] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        // 评论条数
        _pinglunNumBtn = [[UIButton alloc] init];
        [backView addSubview:_pinglunNumBtn];
        [_pinglunNumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.praiseBtn);
            make.right.equalTo(self.contentView).with.offset(- 0.03125 * Width);
        }];
        [_pinglunNumBtn setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
        _pinglunNumBtn.titleLabel.font = [UIFont systemFontOfSize:12.5];
        [_pinglunNumBtn addTarget:self action:@selector(pinglunBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 动态按钮
        _dongtaiBtn = [[UIButton alloc] init];
        [backView addSubview:_dongtaiBtn];
        [_dongtaiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.praiseBtn);
            make.right.equalTo(_pinglunNumBtn.mas_left).with.offset(- 0.03125 * Width);
        }];
        [_dongtaiBtn setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
        _dongtaiBtn.titleLabel.font = [UIFont systemFontOfSize:12.5];
        [_dongtaiBtn addTarget:self action:@selector(dongtaiClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 两个Cell之间的分隔
        UILabel *lbFenge = [[UILabel alloc] init];
        [backView addSubview:lbFenge];
        [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_dongtaiBtn.mas_bottom).with.offset(0.028125 * Width);
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.height.equalTo(@(6));
        }];
        lbFenge.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
        lbFenge.tag = 5;
        
        
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
            make.bottom.equalTo(lbFenge.mas_bottom).with.offset(0);
        }];
    }
    
    return self;
}


// 创建标签
- (void) giveArrForbiaoqian:(NSArray *)arr andNavIndex:(NSInteger)navIndex {
    
    navIndexForTiaoZhuan = navIndex;
    
    arrForLabel = [NSArray array];
    arrForLabel = arr;
    
    UILabel *lbFenGe = [self viewWithTag:5];
    [lbFenGe removeFromSuperview];
    
    // #
    UILabel *jinghaoLb = [[UILabel alloc] init];
    [backView addSubview:jinghaoLb];
    [jinghaoLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_dongtaiBtn.mas_bottom).with.offset(0.027 * Width);
        make.left.equalTo(backView).with.offset(0.03125 * Width);
        make.width.equalTo(@(14));
        make.height.equalTo(@(14));
    }];
    jinghaoLb.textColor = FUIColorFromRGB(0x999999);
    jinghaoLb.text = @"#";
    jinghaoLb.font = [UIFont systemFontOfSize:13];
    
    
    UIButton *lab;
    
    for (int i = 0; i < arr.count; i++) {
        
        UIButton *lb = [[UIButton alloc] init];
        [backView addSubview:lb];
        [lb setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
        lb.titleLabel.font = [UIFont systemFontOfSize:14];
        lb.tag = i;
        [lb addTarget:self action:@selector(lbClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(jinghaoLb);
                make.left.equalTo(jinghaoLb.mas_right).with.offset(0.015625 * Width);
                make.height.equalTo(@(14));
            }];
        }else {
            
            [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(jinghaoLb);
                make.left.equalTo(lab.mas_right).with.offset(0.025 * Width);
                make.height.equalTo(@(14));
            }];
        }
        // 赋值text
        [lb setTitle:arr[i] forState:UIControlStateNormal];
        
        lab = lb;
    }
    
    // 两个Cell之间的分隔
    UILabel *lbFenge = [[UILabel alloc] init];
    [backView addSubview:lbFenge];
    [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(jinghaoLb.mas_bottom).with.offset(0.034375 * Width);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@(6));
    }];
    lbFenge.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.bottom.equalTo(lbFenge.mas_bottom).with.offset(0);
        
    }];
    
}


- (void) lbClick: (UIButton *)btn {
    
    // 获取delegate
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SearchLabelDeatilViewController *vc = [[SearchLabelDeatilViewController alloc] init];
    vc.strDeatil = arrForLabel[btn.tag];
    [vc setHidesBottomBarWhenPushed:YES];
    // 跳转
    [tempAppDelegate.mainTabbarController.viewControllers[navIndexForTiaoZhuan] pushViewController:vc animated:YES];
}


// 个人操作
- (void) gerenButtonViewClick:(UIButton *)sender {
    
    if (self.gerenBtnViewClick) {
        self.gerenBtnViewClick();
    }
}
// 动态
- (void) dongtaiClick:(UIButton *)sender {
    if (self.dongtaiBtnClick) {
        self.dongtaiBtnClick();
    }
}
// 分享
- (void) shareBtnClick:(UIButton *)sender {
    if (self.shareBtnClick) {
        self.shareBtnClick();
    }
}
// 评论
- (void) pinglunBtnClick:(UIButton *)sender {
    if (self.pinglunBtnClick) {
        self.pinglunBtnClick();
    }
}
// 右侧按钮的点击
- (void) rightBtnClick:(UIButton *)sender {
    if (self.rightButtonClick) {
        self.rightButtonClick();
    }
}
// 头像点击事件
- (void) iconImgClick:(UIImageView *)sender {
    if (self.iconImgViewClick) {
        self.iconImgViewClick();
    }
}
// 喜欢按钮的点击事件
- (void)loveBtnAction:(UIButton *)sender
{
    if (self.LoveButtonClick) {
        
        self.LoveButtonClick();
    }
}


//- (UIButton*)praiseBtn
//{
//    if (!_praiseBtn) {
//        _praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _praiseBtn.frame = CGRectMake(0.03125 * Width, lbFenGe1.frame.origin.y + lbFenGe1.frame.size.height + 0.028125 * Width, 20, 20);
//        [_praiseBtn setImage:[UIImage imageNamed:@"index_icon1"] forState:UIControlStateNormal];
//        [_praiseBtn setImage:[UIImage imageNamed:@"index_icon1on"] forState:UIControlStateSelected];
//    }
//    return _praiseBtn;
//}

//- (UIButton*)coverBtn
//{
//    if (!_coverBtn) {
//        
//    }
//    return _coverBtn;
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
