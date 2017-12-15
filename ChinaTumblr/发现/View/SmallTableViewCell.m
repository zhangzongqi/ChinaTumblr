//
//  SmallTableViewCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/24.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "SmallTableViewCell.h"

@implementation SmallTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    
    // 640*646   页面大小
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // 头像
        _iconImgView = [[UIImageView alloc] init];
        [self addSubview:_iconImgView];
        [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).with.offset(6);
            make.width.height.equalTo(@(30));
        }];
        _iconImgView.layer.cornerRadius = 15;
        _iconImgView.clipsToBounds = YES;
        _iconImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconImgClick:)];
        [_iconImgView addGestureRecognizer:tap];
        
        // 昵称
        _nickNameLb = [[UILabel alloc] init];
        [self addSubview:_nickNameLb];
        [_nickNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImgView);
            make.height.equalTo(@(14));
            make.left.equalTo(_iconImgView.mas_right).with.offset(3);
            make.right.equalTo(self).with.offset(-5);
        }];
        _nickNameLb.font = [UIFont systemFontOfSize:14];
        _nickNameLb.textColor = FUIColorFromRGB(0x4e4e4e);
        
        //
        _signLb = [[UILabel alloc] init];
        [self addSubview:_signLb];
        [_signLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_iconImgView);
            make.height.equalTo(@(13));
            make.left.equalTo(_iconImgView.mas_right).with.offset(3);
            make.right.equalTo(self).with.offset(- 5);
        }];
        _signLb.font = [UIFont systemFontOfSize:13];
        _signLb.textColor = FUIColorFromRGB(0x999999);
        
        
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
