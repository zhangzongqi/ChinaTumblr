//
//  SheZhiCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/15.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SheZhiCell : UITableViewCell

@property (nonatomic, copy) UILabel *titleLb; // 标题
@property (nonatomic, copy) UILabel *huancunLb; // 缓存

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
