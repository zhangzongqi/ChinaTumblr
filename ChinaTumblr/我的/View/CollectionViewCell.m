//
//  CollectionViewCell.m
//  FJTagCollectionView
//
//  Created by fujin on 16/1/12.
//  Copyright © 2016年 fujin. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    
    self.backGroupView.layer.masksToBounds = YES;
    self.backGroupView.layer.cornerRadius = 12;
    self.backGroupView.layer.borderWidth = 0.5;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClcik)];
    [self.backGroupView addGestureRecognizer:tap];
    
    
}
- (void)itemClcik {
    if (_selectOrCancelSelect) {
        _selectOrCancelSelect(0);
    }
}


- (IBAction)cancel:(UIButton *)sender {
    if (_cancelItem) {
        _cancelItem();
    }
}

@end
