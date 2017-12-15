//
//  FindTuijianCollectionCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/15.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindTuijianCollectionCell : UICollectionViewCell



@property (nonatomic, copy) UILabel *signLb; // 签名
@property (nonatomic, copy) UIView *tieziView; // 帖子视图
@property (nonatomic, copy) UIImageView *tieziImgView0; // 帖子图片文字视图
@property (nonatomic, copy) UIImageView *tieziImgView1; // 帖子图片文字视图
@property (nonatomic, copy) UIImageView *tieziImgView2; // 帖子图片文字视图
@property (nonatomic, copy) UILabel *lb0;
@property (nonatomic, copy) UILabel *lb1;
@property (nonatomic, copy) UILabel *lb2;
@property (nonatomic, copy) UIImageView *imgvideo0;
@property (nonatomic, copy) UIImageView *imgvideo1;
@property (nonatomic, copy) UIImageView *imgvideo2;


// 头像点击事件
@property (nonatomic, strong) void (^iconImgViewClick)();
// 帖子点击事件
@property (nonatomic, strong) void (^tieziViewClick1)();
// 帖子点击事件
@property (nonatomic, strong) void (^tieziViewClick2)();
// 帖子点击事件
@property (nonatomic, strong) void (^tieziViewClick3)();
// 关注按钮点击事件
@property (nonatomic, strong) void (^followBlock)();


@property (weak, nonatomic) IBOutlet UIView      *headerView; //
@property (weak, nonatomic) IBOutlet UIButton    *backButton;
@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *followListTableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView; // 背景图
@property (weak, nonatomic) IBOutlet UIImageView *headPortraitImageView; // 头像
@property (weak, nonatomic) IBOutlet UILabel     *signatureLabel; // 昵称
@property (weak, nonatomic) IBOutlet UIButton    *followButton; // 关注按钮
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portraitImgViewWidth; // 


#pragma mark - lallaalalalallalalal
@property (weak, nonatomic) IBOutlet UIView      *firstBgView;

@property (nonatomic, copy) NSString *imageName; // 签名


// 创建frame
//- (id)initWithFrame:(CGRect)frame;

///** 关注按钮block */
//@property (nonatomic, copy) void(^followBlock)(UIButton *);


@end


