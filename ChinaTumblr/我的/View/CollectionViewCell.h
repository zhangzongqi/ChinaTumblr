//
//  CollectionViewCell.h
//  FJTagCollectionView
//
//  Created by fujin on 16/1/12.
//  Copyright © 2016年 fujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIView *backGroupView;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic,copy) void (^selectOrCancelSelect)();
@property (nonatomic,copy) void (^cancelItem)();


@end
