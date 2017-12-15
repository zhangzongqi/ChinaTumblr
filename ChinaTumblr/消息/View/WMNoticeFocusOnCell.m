//
//  WMNoticeFocusOnCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/1.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "WMNoticeFocusOnCell.h"

@implementation WMNoticeFocusOnCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    //   640 * 95
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        // 两个Cell之间的分隔
        UILabel *lbFenge = [[UILabel alloc] init];
        [self addSubview:lbFenge];
        [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.left.equalTo(self).with.offset(72);
            make.right.equalTo(self);
            make.height.equalTo(@(1));
        }];
        lbFenge.backgroundColor = [UIColor colorWithRed:237/255.0 green:238/255.0 blue:239/255.0 alpha:1.0];
        
        
        // 头像
        _iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 52, 52)];
        [self addSubview:_iconImgView];
        _iconImgView.layer.cornerRadius = 26;
        _iconImgView.clipsToBounds = YES;
        _iconImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconImgClick:)];
        [_iconImgView addGestureRecognizer:tap];
        
        // 昵称
        _nickNameLb = [[UILabel alloc] init];
        [self addSubview:_nickNameLb];
        [_nickNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(24);
            make.left.equalTo(lbFenge.mas_left);
        }];
        _nickNameLb.textColor = FUIColorFromRGB(0x212121);
        _nickNameLb.font = [UIFont systemFontOfSize:15];
        
        
        // 关注按钮
        _focusOnBtn = [[UIButton alloc] init];
        [self addSubview:_focusOnBtn];
        [_focusOnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(23);
            make.right.equalTo(self).with.offset(-10);
            if (iPhone5S) {
                make.width.equalTo(@(60));
                make.height.equalTo(@(30));
                _focusOnBtn.layer.cornerRadius = 15;
                _focusOnBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            }else {
                make.width.equalTo(@(80));
                make.height.equalTo(@(32));
                _focusOnBtn.layer.cornerRadius = 16;
                _focusOnBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            }
        }];
        
        _focusOnBtn.clipsToBounds = YES;
        _focusOnBtn.layer.borderWidth = 1.f;
        [_focusOnBtn setTitle:@"＋关注" forState:UIControlStateNormal];
        [_focusOnBtn setTitle:@"已关注" forState:UIControlStateSelected];
        [_focusOnBtn setTitleColor:[UIColor colorWithRed:251/255.0 green:193/255.0 blue:85/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_focusOnBtn setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateSelected];
        [_focusOnBtn addTarget:self action:@selector(guanzhuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // 消息提示
        _noticeTipLb = [[UILabel alloc] init];
        [self addSubview:_noticeTipLb];
        [_noticeTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nickNameLb).with.offset(1);
            make.left.equalTo(_nickNameLb.mas_right).with.offset(10);
        }];
        _noticeTipLb.textColor = FUIColorFromRGB(0x4e4e4e);
        _noticeTipLb.font = [UIFont systemFontOfSize:14];
        _noticeTipLb.textAlignment = NSTextAlignmentLeft;
        
        // 时间label
        _timeLb = [[UILabel alloc] init];
        [self addSubview:_timeLb];
        [_timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nickNameLb);
            make.top.equalTo(_nickNameLb.mas_bottom).with.offset(14);
        }];
        _timeLb.textColor = FUIColorFromRGB(0x4e4e4e);
        _timeLb.font = [UIFont systemFontOfSize:13];
        
    }
    return self;
}


// 关注按钮点击事件
- (void) guanzhuBtnAction:(UIImageView *)sender {
    if (self.guanzhuBtnClick) {
        self.guanzhuBtnClick();
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
