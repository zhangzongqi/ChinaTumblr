//
//  SmallTableViewCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/24.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmallTableViewCell : UITableViewCell

@property (nonatomic, copy) UIImageView *iconImgView;
@property (nonatomic, copy) UILabel *nickNameLb;
@property (nonatomic, copy) UILabel *signLb;

// 头像点击事件
@property (nonatomic, strong) void (^iconImgViewClick)();


// 重写init方法
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
