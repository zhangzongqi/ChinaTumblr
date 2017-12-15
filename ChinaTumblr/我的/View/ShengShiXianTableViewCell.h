//
//  ShengShiXianTableViewCell.h
//  EasyLink
//
//  Created by 琦琦 on 17/3/15.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShengShiXianTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLb;
@property (nonatomic, strong) UIImageView *imgView;

// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
