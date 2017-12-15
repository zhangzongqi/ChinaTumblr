//
//  WMNoticeTableViewCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/1.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMNoticeTextCell : UITableViewCell


@property (nonatomic, copy) UIImageView *iconImgView; // 头像
@property (nonatomic, copy) UILabel *nickNameLb; // 昵称
@property (nonatomic, copy) UILabel *noticeTipLb; // 消息提示
@property (nonatomic, copy) UILabel *timeLb; // 时间label


// 头像点击事件
@property (nonatomic, strong) void (^iconImgViewClick)();

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
