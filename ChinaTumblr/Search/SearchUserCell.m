//
//  SearchUserCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/4.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "SearchUserCell.h"

#define Width [[UIScreen mainScreen] bounds].size.width

@implementation SearchUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//*iconImgView; // 用户头像
//@property (nonatomic, copy) UILabel *nickName; // 昵称Label
//@property (nonatomic, copy) UILabel *followNumLb; // 关注人数Lb
//@property (nonatomic, copy) UILabel *signLb

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    // 640*92
    
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // 分隔线
        UILabel *fengeLb = [[UILabel alloc] init];
        [self.contentView addSubview:fengeLb];
        [fengeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
            make.left.equalTo(self.contentView).with.offset(Width * 0.13);
            make.height.equalTo(@(0.5));
            make.right.equalTo(self.contentView);
        }];
        fengeLb.backgroundColor = FUIColorFromRGB(0xeeeeee);
        
        // 用户头像
        _iconImgView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImgView];
        [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).with.offset(20);
            make.width.equalTo(@(52));
            make.height.equalTo(@(52));
        }];
        _iconImgView.layer.cornerRadius = 26;
        _iconImgView.clipsToBounds = YES;
        
        
        // 昵称Lb
        _nickName = [[UILabel alloc] init];
        [self.contentView addSubview:_nickName];
        [_nickName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImgView).with.offset(6);
            make.left.equalTo(_iconImgView.mas_right).with.offset(12);
            make.height.equalTo(@(15));
        }];
        _nickName.font = [UIFont systemFontOfSize:15];
        _nickName.textColor = FUIColorFromRGB(0x212121);
        
        // 关注的人数
        _followNumLb = [[UILabel alloc] init];
        [self.contentView addSubview:_followNumLb];
        [_followNumLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_iconImgView).with.offset(-6);
            make.left.equalTo(_nickName);
            make.height.equalTo(@(14));
        }];
        _followNumLb.textColor = FUIColorFromRGB(0x999999);
        _followNumLb.font = [UIFont systemFontOfSize:13];
        
        // 个性签名
        _signLb = [[UILabel alloc] init];
        [self.contentView addSubview:_signLb];
        [_signLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_nickName);
            make.left.equalTo(_nickName.mas_right).with.offset(12);
            make.height.equalTo(@(14));
        }];
        _signLb.textColor = FUIColorFromRGB(0x999999);
        _signLb.font = [UIFont systemFontOfSize:13];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
