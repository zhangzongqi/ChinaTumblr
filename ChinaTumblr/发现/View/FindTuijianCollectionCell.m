//
//  FindTuijianCollectionCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/15.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "FindTuijianCollectionCell.h"
#import "UIView+LPFExtension.h"
#import "UIImage+LPFExtension.h"
#import "LPFTableDataSource.h"

#define  Width self.frame.size.width

@interface FindTuijianCollectionCell ()

@end

@implementation FindTuijianCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.layer.cornerRadius = 5.f;
    self.contentView.layer.masksToBounds = YES;
    
    // 头像的宽高
//    self.portraitImgViewWidth.constant = 0.2405 * CellH;
    
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    self.bgImageView.userInteractionEnabled = YES;
    
    
    NSLog(@"tieziViewWidth:%f",self.bgImageView.frame.size.width);
    
    // 帖子视图
    _tieziView = [[UIView alloc] init];
    [self.bgImageView addSubview:_tieziView];
    [_tieziView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgImageView);
        make.width.equalTo(self.bgImageView);
        make.bottom.equalTo(self.bgImageView);
        if (iPhone6S) {
            make.height.equalTo(@((self.bgImageView.frame.size.width - 12) / 3));
        }else if (iPhone6SP) {
            make.height.equalTo(@(self.bgImageView.frame.size.width / 3));
        }else if (iPhone5S) {
            make.height.equalTo(@((self.bgImageView.frame.size.width - 40) / 3));
        }else {
            make.height.equalTo(@((self.bgImageView.frame.size.width - 12) / 3));
        }
    }];
    _tieziView.backgroundColor = FUIColorFromRGB(0xffffff);
    _tieziView.clipsToBounds = YES;
    _tieziView.layer.cornerRadius = 5.f;
    _tieziView.userInteractionEnabled = YES;
    [_tieziView layoutIfNeeded];
    
    CGFloat tieziViewWidth = self.frame.size.width;
    NSLog(@"tieziViewWidth:%f",tieziViewWidth);
    
    // 个性签名
    _signLb = [[UILabel alloc] init];
    [self.bgImageView addSubview:_signLb];
    [_signLb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (iPhone5S) {
            make.bottom.equalTo(_tieziView.mas_top).with.offset(- 2);
            make.centerX.equalTo(self.contentView);
            _signLb.font = [UIFont systemFontOfSize:10];
        }else if (iPhone6S) {
            make.bottom.equalTo(_tieziView.mas_top).with.offset(- 3);
            make.centerX.equalTo(self.contentView);
            _signLb.font = [UIFont systemFontOfSize:11];
        }else {
            make.bottom.equalTo(_tieziView.mas_top).with.offset(- 3);
            make.centerX.equalTo(self.contentView);
            _signLb.font = [UIFont systemFontOfSize:12];
        }
        
        
    }];
    _signLb.textColor = FUIColorFromRGB(0x999999);
    
    
    
    // 昵称
    [_signatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (iPhone5S) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(_signLb.mas_top).with.offset(- 1);
            _signatureLabel.font = [UIFont systemFontOfSize:12];
        }else if (iPhone6S) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(_signLb.mas_top).with.offset(- 2);
            _signatureLabel.font = [UIFont systemFontOfSize:13];
        }else {
            make.centerX.equalTo(self);
            make.bottom.equalTo(_signLb.mas_top).with.offset(- 2);
            _signatureLabel.font = [UIFont systemFontOfSize:14];
        }
        
    }];
    
    // 头像
    [_headPortraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (iPhone5S) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(_signatureLabel.mas_top).with.offset(- 1);
            make.width.height.equalTo(@(CellW * 0.18));
            // 切圆角
            self.headPortraitImageView.layer.cornerRadius = CellW * 0.18 * 0.5;
        }else if (iPhone6S) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(_signatureLabel.mas_top).with.offset(- 3);
            make.width.height.equalTo(@(CellW * 0.2));
            // 切圆角
            self.headPortraitImageView.layer.cornerRadius = CellW * 0.2 * 0.5;
        }else {
            make.centerX.equalTo(self);
            make.bottom.equalTo(_signatureLabel.mas_top).with.offset(- 4);
            make.width.height.equalTo(@(CellW * 0.22));
            // 切圆角
            self.headPortraitImageView.layer.cornerRadius = CellW * 0.22 * 0.5;
        }
        
    }];
    self.headPortraitImageView.clipsToBounds = YES;
    self.headPortraitImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconImgClick:)];
    [self.headPortraitImageView addGestureRecognizer:tap];
    
    
    
    self.followButton.imageView.sd_layout
    .widthIs(12)
    .heightIs(12)
    .centerYEqualToView(self.followButton);
    // 未选中
    self.followButton.selected = NO;
    [self.followButton setTitle:@"关注" forState:UIControlStateNormal];
    [self.followButton setTitle:@"已关注" forState:UIControlStateSelected];
    [self.followButton setImage:[UIImage imageNamed:@"index_add"] forState:UIControlStateNormal];
    [self.followButton setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [self.followButton setTitleColor:FUIColorFromRGB(0xfeaa0a) forState:UIControlStateSelected];
    [self.followButton setTitleColor:FUIColorFromRGB(0xfeaa0a) forState:UIControlStateNormal];
    [self.followButton addTarget:self action:@selector(followClick:) forControlEvents:UIControlEventTouchUpInside];

    
    // 帖子图片文字视图
    _tieziImgView0 = [[UIImageView alloc] init];
    [self.tieziView addSubview:_tieziImgView0];
    [_tieziImgView0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgImageView).with.offset(3);
        make.centerY.equalTo(self.tieziView);
        if (iPhone6SP) {
            make.width.equalTo(@((tieziViewWidth - 18) / 3));
            make.height.equalTo(@((tieziViewWidth - 18) / 3));
        }else if (iPhone6S) {
            make.width.equalTo(@((tieziViewWidth - 40) / 3));
            make.height.equalTo(@((tieziViewWidth - 40) / 3));
        }else if (iPhone5S) {
            make.width.equalTo(@((tieziViewWidth - 72) / 3));
            make.height.equalTo(@((tieziViewWidth - 72) / 3));
        }else {
            make.width.equalTo(@((tieziViewWidth - 18) / 3));
            make.height.equalTo(@((tieziViewWidth - 18) / 3));
        }
    }];
    _tieziImgView0.backgroundColor = FUIColorFromRGB(0xeeeeee);
    self.tieziImgView0.userInteractionEnabled = YES;
    [self.tieziImgView0 setContentMode:UIViewContentModeScaleAspectFill];
    self.tieziImgView0.clipsToBounds = YES;
    // 帖子点击事件
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziClick1:)];
    [self.tieziImgView0 addGestureRecognizer:tap1];
    
    // 帖子图片文字视图
    _tieziImgView1 = [[UIImageView alloc] init];
    [self.tieziView addSubview:_tieziImgView1];
    [_tieziImgView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_tieziImgView0.mas_right).with.offset(3);
        make.centerY.equalTo(self.tieziView);
        if (iPhone6SP) {
            make.width.equalTo(@((tieziViewWidth - 18) / 3));
            make.height.equalTo(@((tieziViewWidth - 18) / 3));
        }else if (iPhone6S) {
            make.width.equalTo(@((tieziViewWidth - 40) / 3));
            make.height.equalTo(@((tieziViewWidth - 40) / 3));
        }else if (iPhone5S) {
            make.width.equalTo(@((tieziViewWidth - 72) / 3));
            make.height.equalTo(@((tieziViewWidth - 72) / 3));
        }else {
            make.width.equalTo(@((tieziViewWidth - 18) / 3));
            make.height.equalTo(@((tieziViewWidth - 18) / 3));
        }
    }];
    _tieziImgView1.backgroundColor = FUIColorFromRGB(0xeeeeee);
    self.tieziImgView1.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziClick2:)];
    [self.tieziImgView1 addGestureRecognizer:tap2];
    [self.tieziImgView1 setContentMode:UIViewContentModeScaleAspectFill];
    self.tieziImgView1.clipsToBounds = YES;
    
    // 帖子图片文字视图
    _tieziImgView2 = [[UIImageView alloc] init];
    [self.tieziView addSubview:_tieziImgView2];
    [_tieziImgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tieziImgView1.mas_right).with.offset(3);
        make.centerY.equalTo(self.tieziView);
        if (iPhone6SP) {
            make.width.equalTo(@((tieziViewWidth - 18) / 3));
            make.height.equalTo(@((tieziViewWidth - 18) / 3));
        }else if (iPhone6S) {
            make.width.equalTo(@((tieziViewWidth - 40) / 3));
            make.height.equalTo(@((tieziViewWidth - 40) / 3));
        }else if (iPhone5S) {
            make.width.equalTo(@((tieziViewWidth - 72) / 3));
            make.height.equalTo(@((tieziViewWidth - 72) / 3));
        }else {
            make.width.equalTo(@((tieziViewWidth - 18) / 3));
            make.height.equalTo(@((tieziViewWidth - 18) / 3));
        }
    }];
    _tieziImgView2.backgroundColor = FUIColorFromRGB(0xeeeeee);
    self.tieziImgView2.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tieziClick3:)];
    [self.tieziImgView2 addGestureRecognizer:tap3];
    [self.tieziImgView2 setContentMode:UIViewContentModeScaleAspectFill];
    self.tieziImgView2.clipsToBounds = YES;
    
    
    _lb0 = [[UILabel alloc] init];
    _lb1 = [[UILabel alloc] init];
    _lb2 = [[UILabel alloc] init];
    [_tieziImgView0 addSubview:_lb0];
    [_tieziImgView1 addSubview:_lb1];
    [_tieziImgView2 addSubview:_lb2];
    [_lb0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_tieziImgView0);
    }];
    [_lb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_tieziImgView1);
    }];
    [_lb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_tieziImgView2);
    }];
    
    _imgvideo0 = [[UIImageView alloc] init];
    _imgvideo1 = [[UIImageView alloc] init];
    _imgvideo2 = [[UIImageView alloc] init];
    [_tieziImgView0 addSubview:_imgvideo0];
    [_tieziImgView1 addSubview:_imgvideo1];
    [_tieziImgView2 addSubview:_imgvideo2];
    [_imgvideo0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_tieziImgView0);
        make.height.width.equalTo(@((_tieziView.width - 18)/6));
    }];
    [_imgvideo1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_tieziImgView1);
        make.height.width.equalTo(@((_tieziView.width - 18)/6));
    }];
    [_imgvideo2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_tieziImgView2);
        make.height.width.equalTo(@((_tieziView.width - 18)/6));
    }];
    _imgvideo0.image = [UIImage imageNamed:@"video_list_cell_big_icon"];
    _imgvideo1.image = [UIImage imageNamed:@"video_list_cell_big_icon"];
    _imgvideo2.image = [UIImage imageNamed:@"video_list_cell_big_icon"];
    
}

- (void)setImageName:(NSArray *)imageNameArr {
//    _imageName = imageName;
//    [_bgImageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@""]];
//    _headPortraitImageView.image = [[UIImage imageNamed:imageName] circleImage];
}

//// 创建frame
//- (id)initWithFrame:(CGRect)frame {
//
//    self = [super initWithFrame:frame];
//
//    if (self) {
//
//        //        365*316
//
//        // 给cell切圆角
//        self.layer.cornerRadius = 5;
//        self.clipsToBounds      = YES;
//
//
//        // 背景图
//        _backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CellW, CellH)];
//        [self addSubview:_backImgView];
//
//        // 头像
//        _iconImgView = [[UIImageView alloc] init];
//        [self addSubview:_iconImgView];
//        [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self).with.offset(0.079114 * CellH);
//            make.centerX.equalTo(self);
//            make.width.equalTo(@(0.2405 * CellH));
//            make.height.equalTo(@(0.2405 * CellH));
//        }];
//        _iconImgView.layer.cornerRadius = 0.2405 * CellH / 2;
//        _iconImgView.clipsToBounds      = YES;
//        _iconImgView.backgroundColor    = [UIColor redColor];
//
//        // 昵称
//        _iconLb = [[UILabel alloc] init];
//        [self addSubview:_iconLb];
//        [_iconLb mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_iconImgView.mas_bottom).with.offset(0.05 * CellH);
//            make.centerX.equalTo(self);
//            make.height.equalTo(@(15));
//        }];
//        _iconLb.textColor = FUIColorFromRGB(0xffffff);
//        _iconLb.font      = [UIFont systemFontOfSize:15];
//
//        // 签名
//        _signLb = [[UILabel alloc] init];
//        [self addSubview:_signLb];
//        [_signLb mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_iconLb.mas_bottom).with.offset(0.05 * CellH);
//            make.centerX.equalTo(self);
//            make.height.equalTo(@(13));
//        }];
//        _signLb.textColor = [UIColor colorWithRed:186/255.0 green:187/255.0 blue:188/255.0 alpha:1.0];
//        _signLb.font      = [UIFont systemFontOfSize:13];
//
//        _followBtn = [[UIButton alloc] init];
//        [self addSubview:_followBtn];
//        [_followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self);
//            make.right.equalTo(self);
//            make.height.equalTo(@(CellH * 0.177));
//            make.width.equalTo(@(135));
//        }];
//        _followBtn.selected = NO;
//
//        _followBtn.titleLabel.sd_layout
//        .centerYEqualToView(_followBtn)
//        .rightSpaceToView(_followBtn, CellW * 0.246 * 2 / 9)
//        .widthIs(27)
//        .heightIs(13);
//        _followBtn.imageView.sd_layout
//        .centerYEqualToView(_followBtn)
//        .rightSpaceToView(_followBtn.titleLabel, 4)
//        .widthIs(12)
//        .heightIs(12);
//        [_followBtn setTitle:@"关注" forState:UIControlStateNormal];
//        [_followBtn setImage:[UIImage imageNamed:@"discover_add2"] forState:UIControlStateNormal];
//        [_followBtn setTitle:@"已关注" forState:UIControlStateSelected];
//        _followBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//        [_followBtn setTitleColor:[UIColor colorWithRed:252/255.0 green:169/255.0 blue:44/255.0 alpha:1.0] forState:UIControlStateNormal];
//
//        [self.followBtn addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
//    }
//
//    return self;
//}


//- (IBAction)followButtonClick:(UIButton *)followButton {
//    
//    
//    
//}

- (IBAction)backButtonClick:(UIButton *)backButton {
    
    [UIView animateWithDuration:0.5f animations:^{
    
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:self
                                 cache:YES];
        
        self.firstBgView.hidden = NO;
    }];
}




// 头像点击事件
- (void) iconImgClick:(UIImageView *)sender {
    if (self.iconImgViewClick) {
        self.iconImgViewClick();
    }
}
// 帖子点击事件
- (void) tieziClick1:(UIImageView *)sender {
    if (self.tieziViewClick1) {
        self.tieziViewClick1();
    }
}
// 帖子点击事件
- (void) tieziClick2:(UIImageView *)sender {
    if (self.tieziViewClick2) {
        self.tieziViewClick2();
    }
}
// 帖子点击事件
- (void) tieziClick3:(UIImageView *)sender {
    if (self.tieziViewClick3) {
        self.tieziViewClick3();
    }
}
// 关注按钮点击
- (void) followClick:(UIButton *)sender {
    if (self.followBlock) {
        self.followBlock();
    }
}

@end


