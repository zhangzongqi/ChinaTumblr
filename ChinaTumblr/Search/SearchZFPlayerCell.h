//
//  SearchZFPlayerCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/7.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayer.h"
#import "UserLikeTieZiListModel.h"

@interface SearchZFPlayerCell : UITableViewCell{
    
    UIView *backView;
    
    NSArray *arrForLabel;
    
    NSInteger navIndexForTiaoZhuan;
}

@property (copy, nonatomic) UIImageView          *iconImgView;    // 用户头像
@property (copy, nonatomic) UIImageView          *picView;  // 视频图片
@property (copy, nonatomic) UILabel              *titleLabel; // 视频标题
@property (copy, nonatomic) UILabel *nickNameLb;  // 昵称label
@property (copy, nonatomic) UILabel *timeLb; // 时间label
@property (nonatomic, copy) UIButton *rightBtn; // 右侧按钮

@property (nonatomic, strong) UIButton *playBtn;

/** 播放按钮block */
@property (nonatomic, strong) void(^playBlock)(UIButton *);

// 评论按钮
@property (copy, nonatomic) UIButton *pinglunBtn;
// 分享按钮
@property (copy, nonatomic) UIButton *shareBtn;

@property (nonatomic, copy) UIButton *gerenBtn; // 个人操作按钮


// 个人操作点击事件
@property (nonatomic, strong) void (^gerenBtnViewClick)();
// 头像点击block
@property (nonatomic, strong) void (^iconImgViewClick)();
// 右侧按钮block
@property (nonatomic, strong) void (^rightButtonClick)();
// 评论点击事件
@property (nonatomic, strong) void (^pinglunBtnClick)();
// 动态点击事件
@property (nonatomic, strong) void (^dongtaiBtnClick)();
// 分享点击事件
@property (nonatomic, strong) void (^shareBtnClick)();


// 喜欢按钮block和点击效果
@property (nonatomic, strong) void (^LoveButtonClick)();
@property (nonatomic, copy) UIButton *praiseBtn;
@property (nonatomic, strong) UIButton *coverBtn;
@property (nonatomic, strong) UIImageView *cancelPraiseImg;


@property (copy, nonatomic) UIButton *dongtaiBtn; // 动态Btn
@property (copy, nonatomic) UIButton *pinglunNumBtn; // 评论数量Btn

// 文字label
@property (copy, nonatomic) UILabel *textLb;

@property (copy, nonatomic) UIView *biaoqianView;


// 重写init方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
// 创建标签
- (void) giveArrForbiaoqian:(NSArray *)arr andNavIndex:(NSInteger)navIndex;

@end
