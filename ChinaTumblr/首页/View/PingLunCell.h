//
//  PingLunCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/10.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PingLunCell : UITableViewCell {
    
    UIView *backView;
}

@property (nonatomic, copy) UIImageView *iconImgView; // 头像图片
@property (nonatomic, copy) UILabel *nickNameLb; // 昵称
@property (nonatomic, copy) UILabel *timeLb; // 时间label
@property (nonatomic, copy) UILabel *lbText; // 发布的内容
@property (nonatomic, copy) UILabel *lbTargetNickName; // 被回复人昵称
@property (nonatomic, copy) UILabel *lbHuiFuLe;


// 头像点击事件
@property (nonatomic, strong) void (^iconImgViewClick)();


// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
