//
//  ZLShowBigImage.m
//  点击图片放大
//
//  Created by qianfeng on 15-1-9.
//  Copyright (c) 2015年 张龙. All rights reserved.
//

#import "ZLShowBigImage.h"
#import "MBHUDView.h"

static CGRect oldframe;
static CGRect originalFrame;
static UIImage *BigImage;

@implementation ZLShowBigImage 

+ (void)showBigImage:(UIImageView *)selectedImageView
{
    BigImage = selectedImageView.image;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    backgroundView.tag = 100;
    //存储旧的frame
    oldframe = [selectedImageView convertRect:selectedImageView.bounds toView:window];
    
    originalFrame = oldframe;
    
    //创建黑色背景
    backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    
    //[UIColor colorWithRed:0.3green:0.3blue:0.3alpha:0.7];
    backgroundView.alpha = 0;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:oldframe];
    
    //设置圆角
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 3.0f;
    
    imageView.image = BigImage;
    imageView.tag = 1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    //添加拖拽和缩放手势
//    imageView.userInteractionEnabled = YES;
//    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
//    [imageView addGestureRecognizer:pinch];
//
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
//    [imageView addGestureRecognizer:pan];
//
    
    
    
    //添加长摁手势
    imageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    //设置长按时间
    longPressGesture.minimumPressDuration = 0.5;//(2秒)
    [imageView addGestureRecognizer:longPressGesture];
    
    
    // 动画
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = CGRectMake(0,([UIScreen mainScreen].bounds.size.height-BigImage.size.height*[UIScreen mainScreen].bounds.size.width/BigImage.size.width)/2, [UIScreen mainScreen].bounds.size.width, BigImage.size.height*[UIScreen mainScreen].bounds.size.width/BigImage.size.width);
        backgroundView.alpha = 1;
        originalFrame = oldframe = imageView.frame;
    }];
}

//常摁手势触发方法
+ (void)longPressGesture:(UILongPressGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateBegan)
        
    {
        
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"保存到相册？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        [alter show];
    }
}

// 弹出框代理事件
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex  {
    
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"取消");
        }
            break;
        case 1:
        {
            [self loadImageFinished:BigImage];
            NSLog(@"确定");
        }
            break;
            
        default:
            break;
    }
}

// 保存到相册
+ (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}
// 打印结果
+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    
    // 0.5秒后执行弹出,防止和系统的弹出消失冲突
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(TipAlert) userInfo:nil repeats:NO];
    
    
}

// 弹出提示
+ (void) TipAlert {
    
    [MBHUDView hudWithBody:@"保存成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
}


// 让大图片消失
+ (void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView = tap.view;
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = originalFrame;
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
    
}

//缩放效果
//+ (void)pinchAction:(UIPinchGestureRecognizer *)pinch
//{
//    UIImageView *imageView = (UIImageView *)pinch.view;
//    //[imageView setTransform:CGAffineTransformMakeScale(pinch.scale, pinch.scale)];
//    CGFloat width = oldframe.size.width*pinch.scale;
//    CGFloat height = oldframe.size.height*pinch.scale;
//    imageView.frame = CGRectMake(CGRectGetMidX(oldframe)-width/2, CGRectGetMidY(oldframe)-height/2, width, height);
//    if (pinch.state == UIGestureRecognizerStateEnded) {
//        oldframe = imageView.frame;
//    }
//}
////拖拽效果
//+ (void)panAction:(UIPanGestureRecognizer *)pan
//{
//    UIImageView *imageView = (UIImageView *)pan.view;
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    UIView *backgroundView = [window viewWithTag:100];
//    
//    CGPoint oldPoint = imageView.center;
//    CGPoint newPoint = [pan translationInView:backgroundView];
//    imageView.center = CGPointMake(oldPoint.x+newPoint.x, oldPoint.y+newPoint.y);
//    [pan setTranslation:CGPointZero inView:backgroundView];
//    oldframe = imageView.frame;
//}

@end
