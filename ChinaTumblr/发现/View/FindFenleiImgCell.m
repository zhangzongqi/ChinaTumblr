//
//  FindFenleiImgCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/16.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "FindFenleiImgCell.h"

@implementation FindFenleiImgCell


- (id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // 切cell的圆角
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        // 背景图
        _backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CellW, CellH)];
        [self addSubview:_backImgView];
        self.backImgView.userInteractionEnabled = YES;
        [self.backImgView setContentMode:UIViewContentModeScaleAspectFill];
        self.backImgView.clipsToBounds = YES;
        
        
        // 播放小图标
        _videoImgView = [[UIImageView alloc] init];
        [_backImgView addSubview:_videoImgView];
        [_videoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_backImgView);
            make.width.equalTo(@(CellW / 3));
            make.height.equalTo(@(CellH / 3));
        }];
        _videoImgView.image = [UIImage imageNamed:@"video_list_cell_big_icon"];
        
        
        // 背景文字
        _lbBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CellW, CellH)];
        [self addSubview:_lbBack];
        _lbBack.textAlignment = NSTextAlignmentCenter;
        _lbBack.textColor = FUIColorFromRGB(0x4e4e4e);
        _lbBack.backgroundColor = FUIColorFromRGB(0xffffff);
        _lbBack.font = [UIFont systemFontOfSize:13];
        
    }
    
    return self;
}

//// 头像点击事件
//- (void) backImgClick:(UIImageView *)sender {
//    if (self.backImgViewClick) {
//        self.backImgViewClick();
//    }
//}

@end
