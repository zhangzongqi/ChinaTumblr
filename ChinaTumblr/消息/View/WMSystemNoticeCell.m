//
//  WMSystemNoticeCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/10/26.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "WMSystemNoticeCell.h"

@implementation WMSystemNoticeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    
    //   640 * 95
    
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        // 背景图
        self.backImgView = [[UIImageView alloc] init];
        [self addSubview:self.backImgView];
        [self.backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.bottom.equalTo(self);
            make.right.equalTo(self);
        }];
        [self.backImgView setContentMode:UIViewContentModeScaleAspectFill];
        self.backImgView.clipsToBounds = YES;
        
        // 遮罩层
        UIImageView *imgView = [[UIImageView alloc] init];
        [self.backImgView addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backImgView);
            make.right.equalTo(self.backImgView);
            make.top.equalTo(self.backImgView);
            make.bottom.equalTo(self.backImgView);
        }];
        imgView.backgroundColor = [UIColor blackColor];
        imgView.alpha = 0.3;
        
        // 文字
        self.lbTitle = [[UILabel alloc] init];
        [self addSubview:self.lbTitle];
        [self.lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        _lbTitle.font = [UIFont systemFontOfSize:19];
        _lbTitle.textColor = FUIColorFromRGB(0xffffff);
    }
    
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
