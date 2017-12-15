//
//  ZFPlayerCell.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFPlayerCell.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"
#import "Masonry/Masonry.h"

#define KPraiseBtnWH 30
#define KToBrokenHeartWH    120/195

#define Width  [[UIScreen mainScreen] bounds].size.width


@interface ZFPlayerCell ()

@end

@implementation ZFPlayerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self layoutIfNeeded];
    
    
    // 头像
    [self cutRoundView:self.iconImgView];
    
    
    // 昵称
    [self.nickNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconImgView);
        make.left.equalTo(self.iconImgView.mas_right).with.offset(0.0234375 * Width);
    }];
    self.nickNameLb.font = [UIFont systemFontOfSize:15];
    self.nickNameLb.textColor = FUIColorFromRGB(0x212121);
    
    // 时间label
    [self.timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_nickNameLb);
        make.right.equalTo(self).with.offset(-0.0234375 * Width);
    }];
    self.timeLb.textColor = FUIColorFromRGB(0x4e4e4e);
    self.timeLb.font = [UIFont systemFontOfSize:13];
    self.timeLb.text = @"昨天";
    
    
    // 设置imageView的tag，在PlayerView中取（建议设置100以上）
    self.picView.tag = 101;
    
    
    // 代码添加playerBtn到imageView上
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"video_list_cell_big_icon"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [self.picView addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.picView);
        make.width.height.mas_equalTo(50);
    }];
    
    
    // 喜欢按钮
    [_praiseBtn setImage:[UIImage imageNamed:@"index_icon1"] forState:UIControlStateNormal];
    [_praiseBtn setImage:[UIImage imageNamed:@"index_icon1on"] forState:UIControlStateSelected];
    
    [_praiseBtn layoutIfNeeded];

    
    _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.coverBtn];
    [_coverBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.praiseBtn);
        make.left.equalTo(self.praiseBtn);
        make.width.equalTo(@(20));
        make.height.equalTo(@(20));
    }];;
    _coverBtn.alpha = 0;
    [_coverBtn setImage:[UIImage imageNamed:@"big"] forState:UIControlStateSelected];
    [_coverBtn setImage:[UIImage imageNamed:@"big"] forState:UIControlStateNormal];
    
    [self insertSubview:self.coverBtn belowSubview:self.praiseBtn];
    _cancelPraiseImg = [[UIImageView alloc]init];
    [self addSubview:self.cancelPraiseImg];
    [_cancelPraiseImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.praiseBtn).with.offset(-15);
        make.top.equalTo(self.praiseBtn).with.offset(-40);
        make.width.equalTo(@(KPraiseBtnWH*1.5));
        make.height.equalTo(@(KPraiseBtnWH*1.5*KToBrokenHeartWH));
    }];
    _cancelPraiseImg.hidden = YES;
    _cancelPraiseImg.centerX = _praiseBtn.centerX;
    [self.praiseBtn addTarget:self action:@selector(loveBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 评论条数
    [_pinglunNumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.praiseBtn);
        make.right.equalTo(self.contentView).with.offset(- 0.03125 * Width);
    }];
    [_pinglunNumBtn setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
    _pinglunNumBtn.titleLabel.font = [UIFont systemFontOfSize:12.5];
    
    
    // 动态按钮
    [_dongtaiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.praiseBtn);
        make.right.equalTo(_pinglunNumBtn.mas_left).with.offset(- 0.03125 * Width);
    }];
    [_dongtaiBtn setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
    _dongtaiBtn.titleLabel.font = [UIFont systemFontOfSize:12.5];
    
    
    // 文字label
    _textLb.numberOfLines = 0;
    _textLb.textColor = FUIColorFromRGB(0x212121);
    _textLb.font = [UIFont systemFontOfSize:14];
    
    
    
    
    // 设置标签视图的高
    self.biaoqianView.height = 6;
    
    // 两个Cell之间的分隔
    UILabel *lbFenge = [[UILabel alloc] init];
    [self.biaoqianView addSubview:lbFenge];
    [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.biaoqianView);
        make.left.equalTo(self.biaoqianView);
        make.right.equalTo(self.biaoqianView);
        make.height.equalTo(@(6));
    }];
    lbFenge.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    lbFenge.tag = 5;
}


// 创建标签
- (void) giveArrForbiaoqian:(NSArray *)arr {
    
    
    [self.biaoqianView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(20 + 0.034375 * Width));
    }];
    
    UILabel *lbFenGe = [self viewWithTag:5];
    [lbFenGe removeFromSuperview];
    
    // #
    UILabel *jinghaoLb = [[UILabel alloc] init];
    [self.biaoqianView addSubview:jinghaoLb];
    [jinghaoLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.biaoqianView);
        make.left.equalTo(self.textLb);
        make.width.equalTo(@(14));
        make.height.equalTo(@(14));
    }];
    jinghaoLb.textColor = FUIColorFromRGB(0x999999);
    jinghaoLb.text = @"#";
    jinghaoLb.font = [UIFont systemFontOfSize:13];
    
    
    UILabel *lab;
    
    for (int i = 0; i < arr.count; i++) {
        
        UILabel *lb = [[UILabel alloc] init];
        [self.biaoqianView addSubview:lb];
        lb.numberOfLines = 1;
        lb.textColor = FUIColorFromRGB(0x999999);
        lb.font = [UIFont systemFontOfSize:14];
        if (i == 0) {
            [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(jinghaoLb);
                make.left.equalTo(jinghaoLb.mas_right).with.offset(0.015625 * Width);
                make.height.equalTo(@(14));
            }];
        }else {
            
            [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(jinghaoLb);
                make.left.equalTo(lab.mas_right).with.offset(0.025 * Width);
                make.height.equalTo(@(14));
            }];
        }
        // 赋值text
        lb.text = arr[i];
        
        lab = lb;
    }
    
    // 两个Cell之间的分隔
    UILabel *lbFenge = [[UILabel alloc] init];
    [self.biaoqianView addSubview:lbFenge];
    [lbFenge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(jinghaoLb.mas_bottom).with.offset(0.034375 * Width);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@(6));
    }];
    lbFenge.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
}


// 喜欢按钮的点击事件
- (void)loveBtnAction:(UIButton *)sender
{
    if (self.LoveButtonClick) {
        
        self.LoveButtonClick();
    }
}

// 切圆角
- (void)cutRoundView:(UIImageView *)imageView {
    CGFloat corner = imageView.frame.size.width / 2;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(corner, corner)];
    shapeLayer.path = path.CGPath;
    imageView.layer.mask = shapeLayer;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(ZFVideoModel *)model {
    [self.picView sd_setImageWithURL:[NSURL URLWithString:model.coverForFeed] placeholderImage:[UIImage imageNamed:@"loading_bgView"]];
    self.titleLabel.text = model.title;
}

- (void)play:(UIButton *)sender {
    if (self.playBlock) {
        self.playBlock(sender);
    }
}

@end
