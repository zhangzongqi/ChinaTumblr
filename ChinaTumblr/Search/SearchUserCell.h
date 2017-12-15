//
//  SearchUserCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/4.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchUserCell : UITableViewCell

@property (nonatomic, copy) UIImageView *iconImgView; // 用户头像
@property (nonatomic, copy) UILabel *nickName; // 昵称Label
@property (nonatomic, copy) UILabel *followNumLb; // 关注人数Lb
@property (nonatomic, copy) UILabel *signLb; // 个性签名Lb


// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
