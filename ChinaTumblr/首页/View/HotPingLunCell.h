//
//  HotPingLunCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/22.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotPingLunCell : UITableViewCell {
    
    UIView *backView;
}

@property (nonatomic, copy) UILabel *hotPingLunLb; // 头像图片

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
