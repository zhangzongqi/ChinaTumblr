//
//  SearchLabelCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/14.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchLabelCell : UITableViewCell

@property (nonatomic, copy) UILabel *titleLb; // 标题label
@property (nonatomic, copy) UILabel *NumLb; // 帖子数量Label

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
