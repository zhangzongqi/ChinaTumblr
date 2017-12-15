//
//  BannerModel.h
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/11/1.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "JSONModel.h"

@interface BannerModel : JSONModel

@property (nonatomic, copy) NSString *id1;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *target_type;
@property (nonatomic, copy) NSString *data_id;

@end
