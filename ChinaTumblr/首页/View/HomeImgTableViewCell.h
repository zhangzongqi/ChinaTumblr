//
//  HomeImgTableViewCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/7/27.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeImgTableViewCell : UITableViewCell {
    
    NSArray *arrForLabel;
    
    NSInteger navIndexForTiaoZhuan;
}


@property (nonatomic, copy) UIView *backView;
@property (nonatomic, copy) UIImageView *iconImgView; // 头像图片
@property (nonatomic, copy) UILabel *nickNameLb; // 昵称
@property (nonatomic, copy) UILabel *timeLb; // 时间label
@property (nonatomic, copy) UIImageView *showImgView; // 发布的图片
@property (nonatomic, copy) UILabel *imgNumLb; // 图片张数
@property (nonatomic, copy) UIButton *gerenBtn; // 个人操作按钮


@property (nonatomic, copy) UIButton *pinglunBtn; // 评论按钮
@property (nonatomic, copy) UIButton *shareBtn; // 分享按钮
@property (nonatomic, copy) UIButton *pinglunNumBtn; // 评论条数按钮
@property (nonatomic, copy) UIButton *dongtaiBtn; // 动态Btn
@property (nonatomic, copy) UILabel *textLb; // 文字label


// 个人操作点击事件
@property (nonatomic, strong) void (^gerenBtnViewClick)();
// 头像点击事件
@property (nonatomic, strong) void (^iconImgViewClick)();
// 展示图片点击事件
@property (nonatomic, strong) void(^showImgViewClick)();
// 评论点击事件
@property (nonatomic, strong) void (^pinglunBtnClick)();
// 动态点击事件
@property (nonatomic, strong) void (^dongtaiBtnClick)();
// 分享点击事件
@property (nonatomic, strong) void (^shareBtnClick)();


// 喜欢按钮block和点击效果
@property (nonatomic, strong) void (^LoveButtonClick)();
@property (nonatomic, strong) UIButton *praiseBtn;
@property (nonatomic, strong) UIButton *coverBtn;
@property (nonatomic, strong) UIImageView *cancelPraiseImg;

// 重写init方法
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
// 创建标签
- (void) giveArrForbiaoqian:(NSArray *)arr andNavIndex:(NSInteger)navIndex;

@end
