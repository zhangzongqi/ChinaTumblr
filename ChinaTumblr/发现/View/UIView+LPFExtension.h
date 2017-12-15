//
//  UIView+LPFExtension.h
//  匹克托福
//
//  Created by apple on 2017/2/3.
//  Copyright © 2017年 flying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LPFExtension)
@property (assign, nonatomic) CGSize lpf_size;
@property (assign, nonatomic) CGFloat lpf_width;
@property (assign, nonatomic) CGFloat lpf_height;
@property (assign, nonatomic) CGFloat lpf_x;
@property (assign, nonatomic) CGFloat lpf_y;
@property (assign, nonatomic) CGFloat lpf_centerX;
@property (assign, nonatomic) CGFloat lpf_centerY;
@property (assign, nonatomic) CGFloat lpf_right;
@property (assign, nonatomic) CGFloat lpf_bottom;

+ (instancetype)viewFromNib;
/** 获取当前View的控制器对象 */
- (UIViewController *)getCurrentViewController;
- (UIViewController *)activityViewController;


- (CGFloat)heightForText:(NSString *)text width:(CGFloat)width font:(UIFont *)font;
@end
