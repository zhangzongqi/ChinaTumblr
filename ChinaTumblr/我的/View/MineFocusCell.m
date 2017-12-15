//
//  MineFocusCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/11.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "MineFocusCell.h"

@implementation MineFocusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    // 640 * 100
    
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // 头像
        _iconImgView = [[UIImageView alloc] init];
        [self addSubview:_iconImgView];
        [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).with.offset(-1);
            make.left.equalTo(self).with.offset(CellW / 32);
            make.height.equalTo(@(66));
            make.width.equalTo(@(66));
        }];
        _iconImgView.layer.cornerRadius = 33;
        _iconImgView.clipsToBounds = YES;
        _iconImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconImgClick:)];
        [_iconImgView addGestureRecognizer:tap];
        
        // 昵称
        _nickNameLb = [[UILabel alloc] init];
        [self addSubview:_nickNameLb];
        [_nickNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(26);
            make.left.equalTo(_iconImgView.mas_right).with.offset(0.13 * CellH);
            make.height.equalTo(@(14));
        }];
        _nickNameLb.textColor = FUIColorFromRGB(0x212121);
        _nickNameLb.font = [UIFont systemFontOfSize:14];
        
        
        // 关注人数label
        _focusNumLb = [[UILabel alloc] init];
        [self addSubview:_focusNumLb];
        [_focusNumLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).with.offset(-26);
            make.left.equalTo(_nickNameLb);
            make.height.equalTo(@(12));
        }];
        _focusNumLb.textColor = FUIColorFromRGB(0x999999);
        _focusNumLb.font = [UIFont systemFontOfSize:12];
        
        // 分割线
        UILabel *lbFenge = [[UILabel alloc] init];
        [self addSubview:lbFenge];
        [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.left.equalTo(_nickNameLb);
            make.height.equalTo(@(1));
            make.right.equalTo(self);
        }];
        lbFenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
        
        
        // 关注按钮
        _focusBtn = [[UIButton alloc] init];
        [self addSubview:_focusBtn];
        [_focusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).with.offset(- 0.0234375 * CellW);
            make.height.equalTo(@(30));
            make.width.equalTo(@(60));
        }];
        _focusBtn.layer.cornerRadius = 15;
        _focusBtn.clipsToBounds = YES;
        _focusBtn.layer.borderColor = [[UIColor colorWithRed:250/255.0 green:170/255.0 blue:44/255.0 alpha:1.0] CGColor];
        _focusBtn.layer.borderWidth = 1.0;
        _focusBtn.selected = YES;
        [_focusBtn setTitle:@"已关注" forState:UIControlStateSelected];
        [_focusBtn setTitleColor:[UIColor colorWithRed:250/255.0 green:170/255.0 blue:44/255.0 alpha:1.0] forState:UIControlStateSelected];
        _focusBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_focusBtn setTitle:@"＋关注" forState:UIControlStateNormal];
        [_focusBtn setTitleColor:FUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [_focusBtn addTarget:self action:@selector(focusBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 个性签名
        _signLb = [[UILabel alloc] init];
        [self addSubview:_signLb];
        [_signLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_nickNameLb);
            make.right.equalTo(_focusBtn.mas_left).with.offset(5);
            make.left.equalTo(_nickNameLb.mas_right).with.offset(0.1 * CellH);
            make.height.equalTo(@(13));
        }];
        _signLb.font = [UIFont systemFontOfSize:13];
        _signLb.textColor = FUIColorFromRGB(0x999999);
        _signLb.textAlignment = NSTextAlignmentLeft;
        
    }
    
    return self;
}


// 头像点击事件
- (void) focusBtnClick:(UIImageView *)sender {
    if (self.focusBtnViewClick) {
        self.focusBtnViewClick();
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
