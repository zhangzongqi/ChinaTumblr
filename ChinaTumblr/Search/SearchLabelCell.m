//
//  SearchLabelCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/14.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "SearchLabelCell.h"

@implementation SearchLabelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    // 640*68
    
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // #label
        UILabel *lb = [[UILabel alloc] init];
        [self addSubview:lb];
        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).with.offset(30);
        }];
        lb.textColor = FUIColorFromRGB(0x999999);
        lb.text = @"#";
        lb.font = [UIFont systemFontOfSize:14];
        
        
        // 标题label
        _titleLb = [[UILabel alloc] init];
        [self addSubview:_titleLb];
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(lb.mas_right).with.offset(13);
        }];
        _titleLb.textColor = FUIColorFromRGB(0x212121);
        _titleLb.font = [UIFont systemFontOfSize:15];
        
        // 帖子数量label
        _NumLb = [[UILabel alloc] init];
        [self addSubview:_NumLb];
        [_NumLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLb);
            make.left.equalTo(_titleLb.mas_right).with.offset(13);
            make.height.equalTo(@(14));
        }];
        _NumLb.textColor = FUIColorFromRGB(0x999999);
        _NumLb.font = [UIFont systemFontOfSize:14];
     
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
