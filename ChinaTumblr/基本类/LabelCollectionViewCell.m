//
//  LabelCollectionViewCell.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/11.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "LabelCollectionViewCell.h"

@implementation LabelCollectionViewCell

// 创建frame
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        _labelBtn = [[UIButton alloc] init];
        [self addSubview:_labelBtn];
        [_labelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
        }];
        
    }
 
    return self;
}

@end
