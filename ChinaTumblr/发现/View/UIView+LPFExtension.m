//
//  UIView+LPFExtension.m
//  匹克托福
//
//  Created by apple on 2017/2/3.
//  Copyright © 2017年 flying. All rights reserved.
//

#import "UIView+LPFExtension.h"

@implementation UIView (LPFExtension)
// getter
- (CGSize)lpf_size {
    return self.frame.size;
}
- (CGFloat)lpf_width {
    return self.frame.size.width;
}
- (CGFloat)lpf_height {
    return self.frame.size.height;
}
- (CGFloat)lpf_x {
    return self.frame.origin.x;
}
- (CGFloat)lpf_y {
    return self.frame.origin.y;
}
- (CGFloat)lpf_centerX {
    return self.center.x;
}
- (CGFloat)lpf_centerY {
    return self.center.y;
}
- (CGFloat)lpf_right {
 // return self.lpf_x + self.lpf_width;
    return CGRectGetMaxX(self.frame);
}
- (CGFloat)lpf_bottom {
 // return self.lpf_y + self.lpf_height;
    return CGRectGetMaxY(self.frame);
}
// setter
- (void)setLpf_size:(CGSize)lpf_size {
    CGRect frame      = self.frame;
    frame.size        = lpf_size;
    self.frame        = frame;
}
- (void)setLpf_width:(CGFloat)lpf_width {
    CGRect frame      = self.frame;
    frame.size.width  = lpf_width;
    self.frame        = frame;
}
- (void)setLpf_height:(CGFloat)lpf_height {
    CGRect frame      = self.frame;
    frame.size.height = lpf_height;
    self.frame        = frame;
}
- (void)setLpf_x:(CGFloat)lpf_x {
    CGRect frame      = self.frame;
    frame.origin.x    = lpf_x;
    self.frame        = frame;
}
- (void)setLpf_y:(CGFloat)lpf_y {
    CGRect frame      = self.frame;
    frame.origin.y    = lpf_y;
    self.frame        = frame;
}
- (void)setLpf_centerX:(CGFloat)lpf_centerX {
    CGPoint center    = self.center;
    center.x          = lpf_centerX;
    self.center       = center;
}
- (void)setLpf_centerY:(CGFloat)lpf_centerY {
    CGPoint center    = self.center;
    center.y          = lpf_centerY;
    self.center       = center;
}
- (void)setLpf_right:(CGFloat)lpf_right {
    self.lpf_x        = lpf_right - self.lpf_width;
}
- (void)setLpf_bottom:(CGFloat)lpf_bottom {
    self.lpf_y        = lpf_bottom - self.lpf_height;
}
+ (instancetype)viewFromNib {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil][0];
}

/** 获取当前View的控制器对象 */
- (UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

- (UIViewController *)activityViewController {
    
    
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    //    如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        //        UINavigationController * nav = tabbar.selectedViewController ; 上下两种写法都行
        result=nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    
    return result;  }

- (CGFloat)heightForText:(NSString *)text width:(CGFloat)width font:(UIFont *)font {

    CGSize textSize = CGSizeMake(width, CGFLOAT_MAX);
    
    // 一个label的高度
    NSDictionary *attributes = @{NSFontAttributeName : font};
    CGSize labelSize = [text boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    return labelSize.height;
    
}


@end
