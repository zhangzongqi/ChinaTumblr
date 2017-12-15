//
//  ShengShiXianTableViewCell.m
//  EasyLink
//
//  Created by 琦琦 on 17/3/15.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import "ShengShiXianTableViewCell.h"

#define Width self.frame.size.width
#define Height self.frame.size.height

@implementation ShengShiXianTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
//    35
    
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
        _titleLb = [[UILabel alloc] init];
        [self addSubview:_titleLb];
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).with.offset(Width / 32);
            make.height.equalTo(@(15));
        }];
        _titleLb.textColor = FUIColorFromRGB(0x4e4e4e);
        _titleLb.font = [UIFont systemFontOfSize:15];
        
        _imgView = [[UIImageView alloc] init];
        [self addSubview:_imgView];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(_titleLb.mas_right).with.offset(Width * 0.025);
            make.width.equalTo(@(14.175));
            make.height.equalTo(@(13.5));
        }];
        _imgView.image = [UIImage imageNamed:@"order_confirm_select"];
        _imgView.hidden = YES;
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
