//
//  SearchImgVedioTieZiCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/21.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "SearchImgVedioTieZiCell.h"

#define Width [[UIScreen mainScreen] bounds].size.width

@implementation SearchImgVedioTieZiCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
        UIView *backView = [[UIView alloc] init];
        [self.contentView addSubview:backView];
        backView.backgroundColor = FUIColorFromRGB(0xffffff);
        
        
        // 展示图
        _showImgView = [[UIImageView alloc] init];
        [backView addSubview:_showImgView];
        [_showImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(backView).with.offset(8);
            make.right.equalTo(backView).with.offset(- 10);
            make.height.equalTo(@(60));
            make.width.equalTo(@(60));
        }];
        _showImgView.layer.cornerRadius = 5;
        [self.showImgView setContentMode:UIViewContentModeScaleAspectFill];
        _showImgView.clipsToBounds = YES;
        
        // 播放小图标
        _playImgView = [[UIImageView alloc] init];
        [_showImgView addSubview:_playImgView];
        [_playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_showImgView);
            make.width.equalTo(@(30));
            make.height.equalTo(@(30));
        }];
        _playImgView.image = [UIImage imageNamed:@"video_list_cell_big_icon"];
        
        
        _tieziLb = [[UILabel alloc] init];
        [backView addSubview:_tieziLb];
        [_tieziLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(backView).with.offset(12);
            make.left.equalTo(backView).with.offset(0.03125 * Width);
            make.width.equalTo(@(Width - 0.03125 * Width - 70));
        }];
        _tieziLb.font = [UIFont systemFontOfSize:14];
        _tieziLb.textColor = FUIColorFromRGB(0x4e4e4e);
        _tieziLb.numberOfLines = 2;
        
        // 时间label
        _timeLb = [[UILabel alloc] init];
        [backView addSubview:_timeLb];
        [_timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_tieziLb.mas_bottom).with.offset(8);
            make.left.equalTo(_tieziLb);
            make.height.equalTo(@(13));
        }];
        _timeLb.textColor = FUIColorFromRGB(0x999999);
        _timeLb.font = [UIFont systemFontOfSize:12];
        
        // 分隔线
        UILabel *lbfenge = [[UILabel alloc] init];
        [backView addSubview:lbfenge];
        [lbfenge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_showImgView.mas_bottom).with.offset(8);
            make.left.equalTo(_tieziLb);
            make.right.equalTo(backView);
            make.height.equalTo(@(0.5));
        }];
        lbfenge.backgroundColor = FUIColorFromRGB(0xeeeeee);
        
        
        
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
            make.bottom.equalTo(lbfenge.mas_bottom).with.offset(0);
        }];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end