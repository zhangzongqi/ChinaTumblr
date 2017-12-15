//
//  HotPingLunCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/22.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "HotPingLunCell.h"

#define Width [[UIScreen mainScreen] bounds].size.width

@implementation HotPingLunCell

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
        backView.backgroundColor = [UIColor colorWithRed:247/255.0 green:248/255.0 blue:249/255.0 alpha:1.0];
        
        UILabel *lbTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Width - 16, 1)];
        [backView addSubview:lbTop];
        lbTop.backgroundColor = FUIColorFromRGB(0xffffff);
        
        // 热门评论
        _hotPingLunLb = [[UILabel alloc] init];
        [backView addSubview:_hotPingLunLb];
        [_hotPingLunLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lbTop).with.offset(10);
            make.left.equalTo(backView).with.offset(8);
            make.width.equalTo(@(Width - 16));
        }];
        _hotPingLunLb.font = [UIFont systemFontOfSize:14];
        _hotPingLunLb.numberOfLines = 0;
        [_hotPingLunLb layoutIfNeeded];
        [backView layoutIfNeeded];
        
        
        UIView *vc = [[UIView alloc] init];
        [backView addSubview:vc];
        [vc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_hotPingLunLb.mas_bottom).with.offset(10);
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.height.equalTo(@(8));
        }];
        vc.backgroundColor = FUIColorFromRGB(0xffffff);
        
        // 约束
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
            make.left.equalTo(lbTop).with.offset(8);
            make.right.equalTo(self.contentView).with.offset(- 8);
            make.bottom.equalTo(vc.mas_bottom).with.offset(0);
        }];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
