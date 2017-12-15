//
//  MineFocusCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/11.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineFocusCell : UITableViewCell

@property (nonatomic, copy) UIImageView *iconImgView; // 头像
@property (nonatomic, copy) UILabel *nickNameLb; // 昵称
@property (nonatomic, copy) UILabel *focusNumLb; // 关注人数label
@property (nonatomic, copy) UILabel *signLb; // 签名label
@property (nonatomic, copy) UIButton *focusBtn; // 关注Btn


// 头像点击事件
@property (nonatomic, strong) void (^iconImgViewClick)();
// 关注按钮点击事件
@property (nonatomic, strong) void (^focusBtnViewClick)();

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
