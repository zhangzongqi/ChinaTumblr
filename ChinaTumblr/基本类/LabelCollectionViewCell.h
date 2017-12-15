//
//  LabelCollectionViewCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/11.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LabelCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) UIButton *labelBtn;

// 创建frame
- (id)initWithFrame:(CGRect)frame;

@end
