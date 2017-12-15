//
//  SelectAddressTableViewCell.h
//  EasyLink
//
//  Created by 琦琦 on 17/3/14.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAddressTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *lbAddress;
@property (nonatomic, strong) UIImageView *yesImgView;

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
