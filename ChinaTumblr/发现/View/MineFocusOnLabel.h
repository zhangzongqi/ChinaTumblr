//
//  MineFocusOnLabel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/15.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineFocusOnLabel : UIView {
    
    UILabel *lbTip;
}


// 重写init方法
- (id) initWithFrame:(CGRect)frame;

// 创建标签
- (void) giveBiaoQianWithArr:(NSArray *)titleArr;

@end
