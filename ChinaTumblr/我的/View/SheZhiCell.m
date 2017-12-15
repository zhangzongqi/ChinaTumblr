//
//  SheZhiCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/15.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "SheZhiCell.h"

@implementation SheZhiCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
        // 标题
        _titleLb = [[UILabel alloc] init];
        [self addSubview:_titleLb];
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).with.offset(5);
            make.left.equalTo(self).with.offset(20);
//            make.width.equalTo(@(60));
        }];
        _titleLb.textColor = FUIColorFromRGB(0x212121);
        _titleLb.font = [UIFont systemFontOfSize:15];

        
        // huancunLb
        _huancunLb = [[UILabel alloc] init];
        [self addSubview:_huancunLb];
        [_huancunLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).with.offset(5);
            make.left.equalTo(_titleLb.mas_right).with.offset(12);
        }];
        _huancunLb.textColor = FUIColorFromRGB(0x999999);
        _huancunLb.font = [UIFont systemFontOfSize:13];
        
        // 右侧小图标
        UIImageView *imgView = [[UIImageView alloc] init];
        [self addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).with.offset(-20);
            make.bottom.equalTo(_titleLb);
            make.height.equalTo(@(15));
            make.width.equalTo(@(15));
        }];
        imgView.image = [UIImage imageNamed:@"publish_icon6"];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
