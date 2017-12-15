//
//  SearchImgVedioTieZiCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/21.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchImgVedioTieZiCell : UITableViewCell

@property (nonatomic, copy) UILabel *tieziLb; // 帖子文字
@property (nonatomic, copy) UILabel *timeLb; // 时间label
@property (nonatomic, copy) UIImageView *showImgView; // 展示图
@property (nonatomic, copy) UIImageView *playImgView; // 播放小图

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
