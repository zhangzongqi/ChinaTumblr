//
//  WMTrendsLikeUserTableViewCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/20.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OtherMineViewController.h"
#import "AppDelegate.h"

@interface WMTrendsLikeUserTableViewCell : UITableViewCell {

    
    
    NSArray *_arrForLike;
}

@property (nonatomic, copy) UIImageView *iconImgView; // 头像
@property (nonatomic, copy) UILabel *nickNameLb; // 昵称
@property (nonatomic, copy) UILabel *noticeTipLb; // 消息提示
@property (nonatomic, copy) UILabel *timeLb; // 时间label
@property (nonatomic, copy) UIView *backView; //


// 头像点击事件
@property (nonatomic, strong) void (^iconImgViewClick)();


// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

// 创建喜欢关注内容视图
//- (void) giveArrForLike:(NSArray *)arr;

- (void) createNewViewWithStartNum:(int) startNum andAllNum:(int) allNum;

// 给视图赋值
- (void) giveArrForAlreadyHaveView:(NSArray *)arr;

@end
