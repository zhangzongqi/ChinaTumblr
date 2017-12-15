//
//  LPFTableDataSource.m
//  ESDemo
//
//  Created by 李鹏飞 on 2017/7/26.
//  Copyright © 2017年 李鹏飞. All rights reserved.
//

#import "LPFTableDataSource.h"
#import "UIView+LPFExtension.h"

@interface LPFTableDataSource()

/**
 标识符
 */
@property (nonatomic, copy) NSString *cellReuseIdentifier;

/**
 cell
 */
@property (nonatomic, assign) Class cell;

/**
 tableView Style
 */
@property (nonatomic, assign) NSInteger tableStyle;

/**
 是否从 xib 加载
 */
@property (nonatomic, assign) BOOL isNib;

/**
 初始化
 
 @param dataArray 数据源
 @param reuseIdentifier 标识符
 @param configureBlock 回调
 */
- (instancetype)initWithDataArray:(NSArray *)dataArray
              cellReuseIdentifier:(NSString *)reuseIdentifier
               cellConfigureBlock:(CellconfigureBlock)configureBlock;

//- (instancetype)initWithCell:(Class)cell
//                  tableStyle:(UITableViewCellStyle)tableStyle
//               sectionsCount:(NSInteger)sectionsCount
//                   dataArray:(NSArray *)dataArray
//         cellReuseIdentifier:(NSString *)reuseIdentifier
//          cellConfigureBlock:(CellconfigureBlock)configureBlock;

- (instancetype)initWithCell:(Class)cell
                        tableStyle:(UITableViewCellStyle)tableStyle
                             isNib:(BOOL)isNib
                     sectionsCount:(NSInteger)sectionsCount
                         dataArray:(NSArray *)dataArray
                cellConfigureBlock:(CellconfigureBlock)configureBlock;


@end

@implementation LPFTableDataSource

+ (instancetype)dataSourceWithDataArray:(NSArray *)dataArray
                    cellReuseIdentifier:(NSString *)reuseIdentifier
                     cellConfigureBlock:(CellconfigureBlock)configureBlock {
    return [[LPFTableDataSource alloc] initWithDataArray:dataArray
                                     cellReuseIdentifier:reuseIdentifier
                                      cellConfigureBlock:configureBlock];
}

+ (instancetype)dataSourceWithCell:(Class)cell
                        tableStyle:(UITableViewCellStyle)tableStyle
                             isNib:(BOOL)isNib
                     sectionsCount:(NSInteger)sectionsCount
                         dataArray:(NSArray *)dataArray
                cellConfigureBlock:(CellconfigureBlock)configureBlock {
    
    return [[LPFTableDataSource alloc] initWithCell:cell
                                         tableStyle:tableStyle
                                              isNib:isNib
                                      sectionsCount:sectionsCount
                                          dataArray:dataArray
                                 cellConfigureBlock:configureBlock];
    
    
}

+ (instancetype)dataSourceWithCell:(Class)cell
                        tableStyle:(UITableViewCellStyle)tableStyle
                             isNib:(BOOL)isNib
                     sectionsCount:(NSInteger)sectionsCount
                         dataArray:(NSArray *)dataArray
               cellReuseIdentifier:(NSString *)reuseIdentifier
                cellConfigureBlock:(CellconfigureBlock)configureBlock {
    return [[LPFTableDataSource alloc] initWithCell:cell
                                         tableStyle:tableStyle
                                              isNib:isNib
                                      sectionsCount:sectionsCount
                                          dataArray:dataArray
                                cellReuseIdentifier:reuseIdentifier
                                 cellConfigureBlock:configureBlock];;
}

- (instancetype)initWithDataArray:(NSArray *)dataArray
              cellReuseIdentifier:(NSString *)reuseIdentifier cellConfigureBlock:(CellconfigureBlock)configureBlock {
    
   self = [self initWithCell:nil
                  tableStyle:UITableViewCellStyleDefault
                       isNib:NO
               sectionsCount:1
                   dataArray:dataArray
          cellConfigureBlock:[configureBlock copy]];
    
    return self;
    
}

- (instancetype)initWithCell:(Class)cell
                  tableStyle:(UITableViewCellStyle)tableStyle
                       isNib:(BOOL)isNib
               sectionsCount:(NSInteger)sectionsCount
                   dataArray:(NSArray *)dataArray
          cellConfigureBlock:(CellconfigureBlock)configureBlock {
    
    if (!self) return nil;
    _cell = cell;
    _isNib = isNib;
    _sectionsCount = sectionsCount;
    _tableStyle = tableStyle;
    _dataArray = dataArray;
    _cellReuseIdentifier = NSStringFromClass(cell);
    _cellconfigureBlock = [configureBlock copy];
    
    return self;
    
}

- (instancetype)initWithCell:(Class)cell
                  tableStyle:(UITableViewCellStyle)tableStyle
                       isNib:(BOOL)isNib
               sectionsCount:(NSInteger)sectionsCount
                   dataArray:(NSArray *)dataArray
         cellReuseIdentifier:(NSString *)reuseIdentifier
          cellConfigureBlock:(CellconfigureBlock)configureBlock {
    if (!self) return nil;
    _cell = cell;
    _isNib = isNib;
    _sectionsCount = sectionsCount;
    _tableStyle = tableStyle;
    _dataArray = dataArray;
    _cellReuseIdentifier = reuseIdentifier;
    _cellconfigureBlock = [configureBlock copy];
    
    return self;
}

- (BOOL)isSections {
    return _sectionsCount > 1;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray == nil || self.dataArray.count == 0) return nil;
    if ([self isSections]) return self.dataArray[indexPath.section][indexPath.row];
    return self.dataArray[indexPath.row];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionsCount;
}

- (NSInteger) tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isSections]) return [self.dataArray[section] count];
    return self.dataArray.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionIndexTitles;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id cell = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier];
    if (!cell) {
        
        if (_isNib) {
            cell = [_cell viewFromNib];
        } else {
        cell = [[_cell alloc] initWithStyle:_tableStyle
                            reuseIdentifier:_cellReuseIdentifier];
        }
        
    }
    id item = [self itemAtIndexPath:indexPath];
    !self.cellconfigureBlock ? : self.cellconfigureBlock(cell, item);
    
    return cell;
}

/**
 点击右侧索引表项时调用
 */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSString *key = _sectionIndexTitles[index];
    NSLog(@"sectionForSectionIndexTitle key=%@",key);
    if (key == UITableViewIndexSearch) {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

    !self.selectIndexTitleBlock ? : self.selectIndexTitleBlock();
    
//    [LPFProgressHUD hide];
//    [LPFProgressHUD showMessage:key inView:tableView.superview];
//    LPFHUD.hudSize = CGSizeMake(70, 70);
//    LPFHUD.detailLabelfont = [UIFont systemFontOfSize:35];
    

    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    return self.titleForHeaderBlock(section);

}


@end
