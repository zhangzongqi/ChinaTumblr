//
//  TopScrollView.m
//  无限轮播
//
//  Created by 刘浩浩 on 16/6/12.
//  Copyright © 2016年 CodingFire. All rights reserved.
//

#import "TopScrollView.h"
#import "BannerModel.h"
#import "UIImageView+WebCache.h"
#define WIDTH [[[UIApplication sharedApplication] delegate] window].frame.size.width
#define HEIGHT [[[UIApplication sharedApplication] delegate] window].frame.size.height

@implementation TopScrollView
{
    UIScrollView *_mainScrollView;
    UILabel *contentLabel;
    UIImageView *currentImageView;
    NSInteger _currentIndex;
    NSMutableArray *_dataArray;
    UIView *pageSubView;
}
/*
 *初始化部件，添加点击手势和定时器
 */
-(instancetype)initWithDataArray:(NSMutableArray *)dataArray
{
    if (self=[super initWithFrame:CGRectMake(0, 0, WIDTH, 0.1875 * HEIGHT)]) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.frame = CGRectMake(0, 0, WIDTH, 0.1875 * HEIGHT);
        if (dataArray.count == 1) {
            _mainScrollView.contentSize = CGSizeMake(WIDTH, 0.1875 * HEIGHT);
        }else {
            _mainScrollView.contentSize = CGSizeMake(WIDTH*3, 0.1875 * HEIGHT);
        }
        _mainScrollView.backgroundColor = [UIColor whiteColor];
        _mainScrollView.delegate = self;
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.userInteractionEnabled=YES;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.showsVerticalScrollIndicator=NO;
        _mainScrollView.bounces = NO;
        [_mainScrollView setContentOffset:CGPointMake(WIDTH, 0)];
        [self addSubview:_mainScrollView];
        _currentIndex = 0;
        _dataArray=[NSMutableArray arrayWithArray:dataArray];
      
        [self setUpWithDataArray:_dataArray];
        
        if (_dataArray.count == 1) {
            // 不用添加小圆点
        }else {
            // 添加标题和小圆点
            [self cretPageControlAndTitle];
        }
        
        if (_dataArray.count == 1) {
            // 不用添加定时器和手势
        }else {
            // 添加定时器和手势
            _timer = [NSTimer scheduledTimerWithTimeInterval:4.f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        }
        
        // 手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [self addGestureRecognizer:tap];

    }
    return self;
}
/*
 *创建标题和pageControl，此处pageCOntrol为自定义的，如需要可修改为系统的，或更换图片即可
 */
-(void)cretPageControlAndTitle
{
//    contentLabel = [[UILabel alloc] init];
//    contentLabel.frame = CGRectMake(0, self.frame.size.height-30, WIDTH, 30);
//    contentLabel.textAlignment = NSTextAlignmentLeft;
//    contentLabel.font=[UIFont systemFontOfSize:12];
//    contentLabel.text = ((BannerModel *)[_dataArray firstObject]).title;
//    contentLabel.backgroundColor = [UIColor blackColor];
//    contentLabel.textColor=[UIColor whiteColor];
//    contentLabel.alpha=0.6;
//    [self addSubview:contentLabel];
    
    pageSubView=[[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-30, WIDTH, 30)];
    pageSubView.backgroundColor=[UIColor clearColor];
    [self addSubview:pageSubView];

    for(int i=0;i<_dataArray.count;i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"News_Pic_Number02.png"]];
        imageView.frame = CGRectMake(WIDTH-(_dataArray.count*12)-10+i*12, 11, 7, 7);
        imageView.layer.cornerRadius = 3.5;
        imageView.clipsToBounds = YES;
        if(i == 0)
        {
            imageView.image = [UIImage imageNamed:@"News_Pic_Number01.png"];
        }
        [pageSubView addSubview:imageView];
        
    }

}
/*
 *定时器方法，使banner页无限轮播
 */
-(void)timerAction
{
    UIImageView *imageView = [pageSubView.subviews objectAtIndex:_currentIndex];
    imageView.image = [UIImage imageNamed:@"News_Pic_Number02.png"];
    
    if (_currentIndex+1<_dataArray.count) {
        _currentIndex++;
    }
    else
    {
        _currentIndex=0;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [_mainScrollView setContentOffset:CGPointMake(WIDTH*2, 0)];
    } completion:^(BOOL finished) {
        [_mainScrollView setContentOffset:CGPointMake(WIDTH, 0)];
        [self setUpWithDataArray:_dataArray];
    }];
    
//    contentLabel.text = ((BannerModel *)[_dataArray objectAtIndex:_currentIndex]).title;
    
    UIImageView *imageView1 = [pageSubView.subviews objectAtIndex:_currentIndex];
    imageView1.image = [UIImage imageNamed:@"News_Pic_Number01.png"];
    imageView.layer.cornerRadius = 3.5;
    imageView.clipsToBounds = YES;
    
}

/*
 *此处为scrollView的复用，比目前网上大部分的同类型控件油画效果好，只需要三张图片依次替换即可实现轮播，不需要有几张图就使scrollView的contentSize为图片数＊宽度
 */
-(void)setUpWithDataArray:(NSArray *)dataArray
{
    for(UIView *view in _mainScrollView.subviews)
    {
        if([view isKindOfClass:[UIImageView class]])
            [view removeFromSuperview];
    }
    
    // 中间图
    currentImageView = [[UIImageView alloc] init];
    [currentImageView sd_setImageWithURL:[NSURL URLWithString:((BannerModel *)[dataArray objectAtIndex:_currentIndex]).img]];
    currentImageView.userInteractionEnabled=YES;
    currentImageView.frame = CGRectMake(WIDTH, 0, WIDTH, 0.1875 * HEIGHT);
    [currentImageView setContentMode:UIViewContentModeScaleAspectFill];
    currentImageView.clipsToBounds = YES;
    [_mainScrollView addSubview:currentImageView];
    // 左侧图
    UIImageView *preImageView = [[UIImageView alloc] init];
    NSString *imageStr = _currentIndex-1>=0?((BannerModel *)[dataArray objectAtIndex:_currentIndex-1]).img:((BannerModel *)[dataArray lastObject]).img;
    preImageView.userInteractionEnabled=YES;
    [preImageView sd_setImageWithURL:[NSURL URLWithString:imageStr]];
    preImageView.frame = CGRectMake(0, 0, WIDTH, 0.1875 * HEIGHT);
    [preImageView setContentMode:UIViewContentModeScaleAspectFill];
    preImageView.clipsToBounds = YES;
    [_mainScrollView addSubview:preImageView];
    // 右侧
    UIImageView *nextImageView = [[UIImageView alloc] init];
    nextImageView.userInteractionEnabled=YES;
    NSString *imageStr1 = _currentIndex+1<dataArray.count?((BannerModel *)[dataArray objectAtIndex:_currentIndex+1]).img:((BannerModel *)[dataArray firstObject]).img;
    [nextImageView sd_setImageWithURL:[NSURL URLWithString:imageStr1]];
    nextImageView.frame = CGRectMake(WIDTH*2, 0, WIDTH, 0.1875 * HEIGHT);
    [nextImageView setContentMode:UIViewContentModeScaleAspectFill];
    nextImageView.clipsToBounds = YES;
    [_mainScrollView addSubview:nextImageView];
}
/*
 *图片的点击响应方法
 */
-(void)tapClick
{
    if ([self.delegate respondsToSelector:@selector(didClickScrollViewWithIndex:)]) {
        [self.delegate didClickScrollViewWithIndex:_currentIndex];
    }

}
/*
 *UIScrollViewDelegate  协议方法，拖动图片的处理方法
 */
#pragma mark - UIScrollViewDelegate
// 将要拖拽
- (void) scrollViewWillBeginDragging {
    
    // 暂停计时器
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // 4秒后开始工作
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:4.f]];
    
    if(scrollView == _mainScrollView)
    {
        UIImageView *imageView = [pageSubView.subviews objectAtIndex:_currentIndex];
        imageView.image = [UIImage imageNamed:@"News_Pic_Number02.png"];
        
        int index = scrollView.contentOffset.x/WIDTH;
        if(index>1)
        {
            _currentIndex = _currentIndex+1<_dataArray.count?_currentIndex+1:0;
            [UIView animateWithDuration:1 animations:^{
                [_mainScrollView setContentOffset:CGPointMake(WIDTH*2, 0)];
            } completion:^(BOOL finished) {
                [_mainScrollView setContentOffset:CGPointMake(WIDTH, 0)];
                [self setUpWithDataArray:_dataArray];
            }];        }
        else if(index<1)
        {
            _currentIndex = _currentIndex-1>=0?_currentIndex-1:_dataArray.count-1;
            [UIView animateWithDuration:1 animations:^{
                [_mainScrollView setContentOffset:CGPointMake(0, 0)];
            } completion:^(BOOL finished) {
                [_mainScrollView setContentOffset:CGPointMake(WIDTH, 0)];
                [self setUpWithDataArray:_dataArray];
            }];
        }
        else
            NSLog(@"没滚动不做任何操作");
        
//        contentLabel.text = ((BannerModel *)[_dataArray objectAtIndex:_currentIndex]).title;
        
        UIImageView *imageView1 = [pageSubView.subviews objectAtIndex:_currentIndex];
        imageView1.image = [UIImage imageNamed:@"News_Pic_Number01.png"];
        imageView.layer.cornerRadius = 3.5;
        imageView.clipsToBounds = YES;
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
