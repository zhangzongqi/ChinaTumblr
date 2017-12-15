//
//  PingLunCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/10.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "PingLunCell.h"

#define Width [[UIScreen mainScreen] bounds].size.width

#define KPraiseBtnWH 30
#define KToBrokenHeartWH    120/195

@implementation PingLunCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
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
        _nickNameLb.font = [UIFont systemFontOfSize:14];
        _nickNameLb.textColor = FUIColorFromRGB(0x212121);
        
        _lbHuiFuLe = [[UILabel alloc] init];
        [backView addSubview:_lbHuiFuLe];
        [_lbHuiFuLe mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_iconImgView);
            make.left.equalTo(_nickNameLb.mas_right).with.offset(5);
            make.width.equalTo(@(40));
        }];
        _lbHuiFuLe.text = @"回复了";
        _lbHuiFuLe.textColor = FUIColorFromRGB(0x999999);
        _lbHuiFuLe.font = [UIFont systemFontOfSize:13];
        
        
        // 时间label
        _timeLb = [[UILabel alloc] init];
        [backView addSubview:_timeLb];
        [_timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_nickNameLb);
            make.right.equalTo(self).with.offset(-0.0234375 * Width);
            make.width.equalTo(@(75));
        }];
        _timeLb.textColor = FUIColorFromRGB(0x4e4e4e);
        _timeLb.font = [UIFont systemFontOfSize:13];
        _timeLb.textAlignment = NSTextAlignmentRight;
        
        
        // 被回复人
        _lbTargetNickName = [[UILabel alloc] init];
        [backView addSubview:_lbTargetNickName];
        [_lbTargetNickName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_iconImgView);
            make.left.equalTo(_lbHuiFuLe.mas_right).with.offset(5);
            make.right.equalTo(_timeLb.mas_left);
        }];
        _lbTargetNickName.textColor = FUIColorFromRGB(0x212121);
        _lbTargetNickName.font = [UIFont systemFontOfSize:14];
        
        
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
        
        // 两个Cell之间的分隔
        UILabel *lbFenge = [[UILabel alloc] init];
        [backView addSubview:lbFenge];
        [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_lbText.mas_bottom).with.offset(8);
            make.left.equalTo(_iconImgView);
            make.right.equalTo(self.contentView);
            make.height.equalTo(@(1));
        }];
        lbFenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
        
        
        // 约束
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
            make.bottom.equalTo(lbFenge.mas_bottom).with.offset(0);
        }];
    }
    
    return self;
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
