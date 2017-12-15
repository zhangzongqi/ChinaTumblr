//
//  SelectAddressTableViewCell.m
//  EasyLink
//
//  Created by 琦琦 on 17/3/14.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import "SelectAddressTableViewCell.h"

#define Width self.frame.size.width
#define Height self.frame.size.height

@implementation SelectAddressTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    
//    46
    
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
        // 地址小图片
        _imgView = [[UIImageView alloc] init];
        [self addSubview:_imgView];
        _imgView.image = [UIImage imageNamed:@"order_location"];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(Width * 3/64);
            make.centerY.equalTo(self);
            make.width.equalTo(@(13.2));
            make.height.equalTo(@(15.6));
        }];
        _imgView.hidden = YES;
        
        // 对号
        _yesImgView = [[UIImageView alloc] init];
        [self addSubview:_yesImgView];
        [_yesImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).with.offset(- Width /32);
            make.centerY.equalTo(self);
            make.width.equalTo(@(14.175));
            make.height.equalTo(@(13.5));
        }];
        _yesImgView.image = [UIImage imageNamed:@"order_confirm_select"];
        _yesImgView.hidden = YES;
        
        // 地址label
        _lbAddress = [[UILabel alloc] init];
        [self addSubview:_lbAddress];
        [_lbAddress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_imgView.mas_right).with.offset(Width / 64);
            make.right.equalTo(_yesImgView.mas_left).with.offset(- Width / 64);
            make.centerY.equalTo(self);
            make.height.equalTo(@(15));
        }];
        _lbAddress.textColor = FUIColorFromRGB(0x4e4e4e);
        _lbAddress.font = [UIFont systemFontOfSize:15];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
