//
//  FindFenleiImgCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/16.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindFenleiImgCell : UICollectionViewCell

@property (nonatomic, copy) UIImageView *backImgView; // 背景图

@property (nonatomic, copy) UILabel *lbBack; // 背景文字

@property (nonatomic, copy) UIImageView *videoImgView; // 视频类型的播放按钮



// 图片点击事件
//@property (nonatomic, strong) void (^backImgViewClick)();



- (id) initWithFrame:(CGRect)frame;

@end
