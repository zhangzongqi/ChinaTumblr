//
//  WMSystemNoticeCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/10/26.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSystemNoticeCell : UITableViewCell

@property (nonatomic, strong) UIImageView *backImgView; // 背景图
@property (nonatomic, strong) UILabel *lbTitle; // 标题

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
