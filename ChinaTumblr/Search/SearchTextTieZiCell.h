//
//  SearchTieZiCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/5.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTextTieZiCell : UITableViewCell

@property (nonatomic, copy) UILabel *tieziLb; // 帖子文字
@property (nonatomic, copy) UILabel *timeLb; // 时间label

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
