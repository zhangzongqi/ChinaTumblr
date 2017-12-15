//
//  FindTuijianTableViewCell.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/16.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindTuiJianTableViewCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) NSArray *dataSource;

// 刷新的方法
- (void) requestData;

@end
