//
//  LPFTableDataSource.h
//  ESDemo
//
//  Created by 李鹏飞 on 2017/7/26.
//  Copyright © 2017年 李鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^CellconfigureBlock)(id cell ,id item);

typedef void (^SelectIndexTitleBlock)();

typedef NSString * (^TitleForHeaderBlock)(NSInteger section);

@interface LPFTableDataSource : NSObject <UITableViewDataSource>

/** 创建 cell 的回调 */
@property (nonatomic, copy) CellconfigureBlock cellconfigureBlock;
/** 点击右侧索引的回调 */
@property (nonatomic, copy) SelectIndexTitleBlock selectIndexTitleBlock;
/** section 标题回调 */
@property (nonatomic, copy) TitleForHeaderBlock titleForHeaderBlock;

/**
 数据源
 */
@property (nonatomic, strong) NSArray *dataArray;

/**
 sections Count
 */
@property (nonatomic, assign) NSInteger sectionsCount;

/**
 字母索引
 */
@property (nonatomic, strong) NSArray *sectionIndexTitles;

/**
 <#Property Name#>
 */
@property (nonatomic, strong) NSArray *sectionTitles;

#pragma mark - 初始化

+ (instancetype)dataSourceWithDataArray:(NSArray *)dataArray
                    cellReuseIdentifier:(NSString *)reuseIdentifier
                     cellConfigureBlock:(CellconfigureBlock)configureBlock;

+ (instancetype)dataSourceWithCell:(Class)cell
                        tableStyle:(UITableViewCellStyle)tableStyle
                             isNib:(BOOL)isNib
                     sectionsCount:(NSInteger)sectionsCount
                         dataArray:(NSArray *)dataArray
                cellConfigureBlock:(CellconfigureBlock)configureBlock;

+ (instancetype)dataSourceWithCell:(Class)cell
                        tableStyle:(UITableViewCellStyle)tableStyle
                             isNib:(BOOL)isNib
                     sectionsCount:(NSInteger)sectionsCount
                         dataArray:(NSArray *)dataArray
               cellReuseIdentifier:(NSString *)reuseIdentifier
                cellConfigureBlock:(CellconfigureBlock)configureBlock;

/**
 得到对应 indexPath 的Model
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
