//
//  WMTrendsLikeUserTableViewCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/20.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "WMTrendsLikeUserTableViewCell.h"
#import <SDWebImage/UIButton+WebCache.h>

#define Width [[UIScreen mainScreen] bounds].size.width

@implementation WMTrendsLikeUserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    //   640 * 211
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _backView = [[UIView alloc] init];
        [self.contentView addSubview:_backView];
        _backView.backgroundColor = FUIColorFromRGB(0xffffff);
        
        // 两个Cell之间的分隔
        //        UILabel *lbFenge = [[UILabel alloc] init];
        //        [backView addSubview:lbFenge];
        //        [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.bottom.equalTo(backView);
        //            make.left.equalTo(;
        //            make.right.equalTo(self);
        //            make.height.equalTo(@(1));
        //        }];
        //        lbFenge.backgroundColor = [UIColor colorWithRed:237/255.0 green:238/255.0 blue:239/255.0 alpha:1.0];
        
        
        // 头像
        _iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 36, 36)];
        [_backView addSubview:_iconImgView];
        _iconImgView.layer.cornerRadius = 18;
        _iconImgView.clipsToBounds = YES;
        _iconImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconImgClick:)];
        [_iconImgView addGestureRecognizer:tap];
        
        // 昵称
        _nickNameLb = [[UILabel alloc] init];
        [_backView addSubview:_nickNameLb];
        [_nickNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_iconImgView);
            make.left.equalTo(_iconImgView.mas_right).with.offset(0.0234375 * Width);
        }];
        _nickNameLb.textColor = FUIColorFromRGB(0x212121);
        _nickNameLb.font = [UIFont systemFontOfSize:15];
        [_nickNameLb layoutIfNeeded];
        
        
        // 时间label
        _timeLb = [[UILabel alloc] init];
        [_backView addSubview:_timeLb];
        [_timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nickNameLb).with.offset(2);
            make.right.equalTo(self.contentView).with.offset(-10);
        }];
        _timeLb.textColor = FUIColorFromRGB(0x4e4e4e);
        _timeLb.font = [UIFont systemFontOfSize:13];
        [_timeLb layoutIfNeeded];
        
        // 消息提示
        _noticeTipLb = [[UILabel alloc] init];
        [_backView addSubview:_noticeTipLb];
        [_noticeTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nickNameLb).with.offset(1);
            make.left.equalTo(_nickNameLb.mas_right).with.offset(0.0234375 * Width);
        }];
        _noticeTipLb.textColor = FUIColorFromRGB(0x4e4e4e);
        _noticeTipLb.font = [UIFont systemFontOfSize:13];
        
    }
    return self;
}


// 创建喜欢关注内容视图
- (void) createNewViewWithStartNum:(int) startNum andAllNum:(int) allNum {
    
//    _arrForLike = [NSArray array];
//    _arrForLike = arr;
    
    for (int i = startNum; i < allNum; i++) {
        
        UIButton *LikeView = [[UIButton alloc] init];
        [_backView addSubview:LikeView];
        LikeView.backgroundColor = FUIColorFromRGB(0xeeeeee);
        LikeView.imageView.sd_layout
        .widthRatioToView(LikeView, 1)
        .centerXEqualToView(LikeView)
        .centerYEqualToView(LikeView)
        .heightRatioToView(LikeView, 1);
        
        NSInteger count = i/5;
        
        [LikeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImgView.mas_bottom).with.offset(6 + count * (Width-80-0.0234375*Width)/5 + count * 6);
            make.left.equalTo(_nickNameLb).with.offset(i * (Width-80-0.0234375*Width)/5 + i * 6 - count * (5 * (Width-80-0.0234375*Width)/5 + 5 * 6));
            make.height.equalTo(@((Width-80-0.0234375*Width)/5));
            make.width.equalTo(@((Width-80-0.0234375*Width)/5));
        }];
        LikeView.layer.cornerRadius = (Width-80-0.0234375*Width)/10;
        LikeView.clipsToBounds = YES;
        
        
        if (i == allNum - 1) {
            
            [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView);
//                make.bottom.equalTo(LikeView.mas_bottom).with.offset(12);
            }];
        }
    }
}

// 给现有的视图赋值
- (void) giveArrForAlreadyHaveView:(NSArray *)arr {
    
    _arrForLike = [NSArray array];
    _arrForLike = arr;
    
    for (int i = 0; i < arr.count; i++) {
        
        UIButton *btn = self.backView.subviews[i + 4];
        btn.tag = i;
        [btn addTarget:self action:@selector(likeViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:[arr[i] valueForKey:@"targetIcon"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"账户管理_默认头像"]];
    }
}

// 点击事件
- (void) likeViewClick:(UIButton *)btn {
    
    // 拿到用户id
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicForUserInfo = [user objectForKey:@"userInfo"];
    if ([[_arrForLike[btn.tag] valueForKey:@"targetUid"] isEqualToString:[dicForUserInfo valueForKey:@"id"]]) {
        
        [TipIsYourSelf tipIsYourSelf];
        
    }else {
        
        // 获取delegate
        AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        OtherMineViewController *vc = [[OtherMineViewController alloc] init];
        vc.userId = [_arrForLike[btn.tag] valueForKey:@"targetUid"];
        [vc setHidesBottomBarWhenPushed:YES];
        // 跳转
        [tempAppDelegate.mainTabbarController.viewControllers[3] pushViewController:vc animated:YES];
    }
}


// 头像点击事件
- (void) iconImgClick:(UIImageView *)sender {
    if (self.iconImgViewClick) {
        self.iconImgViewClick();
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
