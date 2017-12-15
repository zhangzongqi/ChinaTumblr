//
//  MineFocusOnLabel.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/15.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "MineFocusOnLabel.h"

#define Width self.frame.size.width
#define Height self.frame.size.height

@implementation MineFocusOnLabel

// 重写init方法
- (id) initWithFrame:(CGRect)frame{
    
    // 640*142
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
//        25   38
        
        // ViewTip
        lbTip = [[UILabel alloc] init];
        [self addSubview:lbTip];
        [lbTip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(Height * 25 / 142);
            make.left.equalTo(self).with.offset(20);
            make.height.equalTo(@(Height * 38 / 142));
        }];
        lbTip.textColor = [UIColor colorWithRed:118/255.0 green:119/255.0 blue:120/255.0 alpha:1.0];
        lbTip.font = [UIFont systemFontOfSize:13];
        lbTip.textAlignment = NSTextAlignmentCenter;
        lbTip.text = @"我关注的标签";
        
    }
    
    return self;
}


// 创建标签
- (void) giveBiaoQianWithArr:(NSArray *)titleArr {
    
    // 标签按钮
    
    int width = 0;
    int height = 0;
    int number = 0;
    int han = 0;
    int countNum = 0;
    
    //创建button
    for (int i = 0; i < titleArr.count; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        
        CGSize titleSize = [titleArr[i] boundingRectWithSize:CGSizeMake(999, 25) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        titleSize.width += 15;
        
        //            if (countNum == 0) {
        
        //自动的折行
        //            if (countNum == 0) {
        han = han +titleSize.width + 35;
        //            }else {
        //                han = han +titleSize.width + 30;
        //            }
        
        if (han > [[UIScreen mainScreen]bounds].size.width) {
            han = 0;
            han = han + titleSize.width;
            height++;
            width = 0;
            width = width + titleSize.width;
            number = 0;
            
            if (countNum == 0) {
                button.frame = CGRectMake(15, Height * 25 / 142 + Height * 38 / 142 + Height * 16 / 142*height, titleSize.width, Height * 38 / 142);
            }else {
                break;
            }
            
            countNum ++;
            
        }else{
            
            if (countNum == 0) {
                button.frame = CGRectMake(width+15+(number*10) + 98, Height * 25 / 142, titleSize.width, Height * 38 / 142);
            }else if (countNum == 1) {
                button.frame = CGRectMake(width+15+(number*10), (Height * 38 / 142 + Height * 25 / 142 + Height * 16 / 142)*height, titleSize.width, Height * 38 / 142);
            }else {
                
                break;
            }
            
            
            width = width+titleSize.width;
        }
        number++;
        //                button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = Height * 38 / 142 / 2;
        button.layer.borderColor = [[UIColor grayColor] CGColor];
        button.layer.borderWidth = 1.0;
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor colorWithRed:185/255.0 green:186/255.0 blue:187/255.0 alpha:1.0] forState:UIControlStateNormal];
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        [self addSubview:button];
    }
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
