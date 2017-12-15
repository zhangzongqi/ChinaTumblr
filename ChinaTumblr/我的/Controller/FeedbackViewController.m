//
//  FeedbackViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/9/5.
//  Copyright © 2017年 张宗琦. All rights reserved.
//  意见反馈

#import "FeedbackViewController.h"
#import "AddPhotoCollectionViewCell.h" // cell
#import "ZLPhotoActionSheet.h"
#import "ZLDefine.h"
#import "ZLCollectionCell.h"
#import "ZLShowBigImage.h" // 查看大图
#import "TZTestCell.h" // collectionView 的cell


#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import "TZTestCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "LxGridViewFlowLayout.h"
#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import "TZPhotoPreviewController.h"
#import "TZGifPhotoPreviewController.h"
#import "TZLocationManager.h"

@interface FeedbackViewController ()<UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,TZImagePickerControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UITextFieldDelegate> {
    
    BOOL _isSelectOriginalPhoto; // 是否选了原图
    int maxCountTF; // 最大选择照片数
    int columnNumberTF; // 调起的相册每行可显示的数量
    
    
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    
    
    CGFloat _itemWH; // collectionItem的宽高
    CGFloat _margin; // 边缘空白
    
    
    NSMutableDictionary *_mutDicData; // 用于保存要提交的信息
    
    
    NSString *isFailure; // 上传图片是否发生错误
    
    NSInteger countNum; // 上传成功张数
    
    
    NSString *strTuPianId; // 图片id
}


@property (nonatomic, copy) UILabel *lbFenGe2;// 分隔线2

@property (assign, nonatomic) BOOL allowPickingGifSwitch; // 是否允许选择gif
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;


@property (nonatomic, strong) UICollectionView *collectionView; // collectionview

@property (nonatomic, copy) UITextField *titleTextField; // 标题Tf
@property (nonatomic, copy) UITextView *detailTextView; // 内容Tf

// 动画
@property (nonatomic, copy) MBProgressHUD *HUD;


@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // 初始化数据
    [self initDataSource];
    
    // 设置导航栏标题
    UILabel *lbItemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    lbItemTitle.text = @"意见反馈";
    lbItemTitle.textColor = FUIColorFromRGB(0x212121);
    lbItemTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = lbItemTitle;
    
    // 上传成功张数为0
    countNum = 0;
    
    maxCountTF = 9; // 最大可选照片数
    columnNumberTF = 4; // 每行显示的照片数
    _allowPickingGifSwitch = YES; // 允许
    
    
    // 右侧按钮
    [self createRightBtn];
    
    // 布局页面
    [self createUI];
}

// 初始化数据
- (void) initDataSource {
    
    _mutDicData = [[NSMutableDictionary alloc] init];
}

// 导航栏右侧按钮和视图
- (void) createRightBtn {
    
    // 右侧按钮
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 28, 15);
    [menuBtn setTitle:@"提交" forState:UIControlStateNormal];
    menuBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [menuBtn setTitleColor:FUIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
}

// 右侧按钮点击事件（提交）
- (void) rightBtnClick:(UIButton *)menuBtn {
    
    if ([_titleTextField.text isEqualToString:@""]) {
        
        [MBHUDView hudWithBody:@"请输入标题" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0 show:YES];
        
    }else if ([_detailTextView.text isEqualToString:@"请输入您要反馈的内容"] || [_detailTextView.text isEqualToString:@""]) {
        
        [MBHUDView hudWithBody:@"内容为空" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0 show:YES];
    }else {
        
        if ([_titleTextField isFirstResponder]) {
            [_titleTextField resignFirstResponder];
        }
        if ([_detailTextView isFirstResponder]) {
            [_detailTextView resignFirstResponder];
        }
        
        
        // 获取用于相关的加密
        NSArray *arrForUserJiaMi = [GetUserJiaMi getUserTokenAndCgAndKey];
        
        
        
        if (_selectedPhotos.count == 0) {
            
            NSString *jsonStr = [MakeJson createJson:_mutDicData];
            NSString *dataJiaMi = [jsonStr AES128EncryptWithKey:arrForUserJiaMi[3]];
            NSDictionary *dicData = @{@"tk":arrForUserJiaMi[0],@"key":arrForUserJiaMi[1],@"cg":arrForUserJiaMi[2],@"data":dataJiaMi};
            
            // 进行数据请求
            HttpRequest *http = [[HttpRequest alloc] init];
            [http PostAddUserFeedbackWithDic:dicData Success:^(id userInfo) {
                
                if ([userInfo isEqualToString:@"0"]) {
                    // 失败
                }
                if ([userInfo isEqualToString:@"1"]) {
                    
                    // 成功
                    
                    // 1.5秒返回上一级
                    [NSTimer scheduledTimerWithTimeInterval:1.f repeats:NO block:^(NSTimer * _Nonnull timer) {
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
                
            } failure:^(NSError *error) {
                
                
            }];
            
            
        }else {
            
            HttpRequest *http = [[HttpRequest alloc] init];
            
            // 图片不为空
            // 创建动画
            _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _HUD.labelText = @"正在上传第1张图片";
            // 展示动画
            [_HUD show:YES];
            
            
            NSDictionary *dicDataForTuPian = @{@"tk":arrForUserJiaMi[0],@"key":arrForUserJiaMi[1],@"cg":arrForUserJiaMi[2]};
            
            
            // 上传图片是否发生错误
            isFailure = @"NO";
            
            
            // 发布图片网络请求
            for (int i = 0; i < _selectedPhotos.count; i++) {
                
                NSLog(@"%d",i);
                
                // 上传图片
                [http PostImgToServerWithUserInfo:dicDataForTuPian andImg:_selectedPhotos[i] Success:^(id arrForDetail) {
                    
                    // 错误
                    if ([arrForDetail isEqualToString:@"false"]) {
                        
                        // 隐藏动画
                        [_HUD hide:YES];
                        isFailure = @"YES";
                        // 上传成功次数
                        countNum = 0;
                        
                    }else {
                        
                        if (countNum == 0) {
                            _HUD.labelText = [NSString stringWithFormat:@"正在上传第%ld张图片",countNum+1];
                            strTuPianId = arrForDetail;
                            countNum ++;
                        }else {
                            _HUD.labelText = [NSString stringWithFormat:@"正在上传第%ld张图片",countNum+1];
                            strTuPianId = [NSString stringWithFormat:@"%@,%@",strTuPianId,arrForDetail];
                            countNum ++;
                        }
                        
                        // 图片上传完成
                        NSArray *arr = [strTuPianId componentsSeparatedByString:@","];
                        
                        if ([arr count] == [_selectedPhotos count]) {
                            
                            [_HUD hide:YES];
                            
                            NSLog(@"hhhhhhhhh%@",strTuPianId);
                            [_mutDicData setObject:strTuPianId forKey:@"images"];
                            NSLog(@"hhhhhhhhhfasdfsafs%@",_mutDicData);
                            
                            // 获取到用户相关的加密信息
                            NSString *jsonStr = [MakeJson createJson:_mutDicData];
                            NSString *dataJiaMi = [jsonStr AES128EncryptWithKey:arrForUserJiaMi[3]];
                            
                            NSDictionary *dicData111 = @{@"tk":arrForUserJiaMi[0],@"key":arrForUserJiaMi[1],@"cg":arrForUserJiaMi[2],@"data":dataJiaMi};
                            
                            [http PostAddUserFeedbackWithDic:dicData111 Success:^(id userInfo) {
                                
                                if ([userInfo isEqualToString:@"0"]) {
                                    
                                    // 反馈失败
                                }
                                if ([userInfo isEqualToString:@"1"]) {
                                    

                                    // 反馈成功
                                    // 1.5秒返回上一级
                                    [NSTimer scheduledTimerWithTimeInterval:1.f repeats:NO block:^(NSTimer * _Nonnull timer) {
                                        
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }];
                                }
                                
                            } failure:^(NSError *error) {
                                
                                
                            }];
                            
                            
                            
                        }else {
                            
                            NSLog(@"我日,还没传完图片");
                        }
                    }
                    
                } failure:^(NSError *error) {
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    
                    // 上传成功次数
                    countNum = 0;
                    isFailure = @"YES";
                }];
                
                
                if ([isFailure isEqualToString:@"YES"]) {
                    
                    // 隐藏动画
                    [_HUD hide:YES];
                    
                    break;
                }
            }

        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
}

// 布局页面
- (void) createUI {
    
    // 分隔线
    UILabel *lbFenge1 = [[UILabel alloc] init];
    [self.view addSubview:lbFenge1];
    [lbFenge1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(20);
        make.right.equalTo(self.view);
        make.height.equalTo(@(0.5));
        make.top.equalTo(self.view).with.offset(50);
    }];
    lbFenge1.backgroundColor = FUIColorFromRGB(0xeeeeee);
    
    // 标题Lb
    UILabel *titleLb = [[UILabel alloc] init];
    [self.view addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(17.5);
        make.left.equalTo(lbFenge1);
        make.height.equalTo(@(15));
    }];
    titleLb.textColor = FUIColorFromRGB(0x4e4e4e);
    titleLb.font = [UIFont systemFontOfSize:15];
    titleLb.text = @"标题";
    
    // 标题Tf
    _titleTextField = [[UITextField alloc] init];
    [self.view addSubview:_titleTextField];
    [_titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(10);
        make.left.equalTo(titleLb.mas_right).with.offset(20);
        make.height.equalTo(@(32.5));
    }];
    _titleTextField.font = [UIFont systemFontOfSize:14];
    _titleTextField.textAlignment = NSTextAlignmentLeft;
    _titleTextField.placeholder = @"请输入您反馈的标题";
    _titleTextField.delegate = self;
    
    // 内容Lb
    UILabel *detailLb = [[UILabel alloc] init];
    [self.view addSubview:detailLb];
    [detailLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbFenge1.mas_bottom).with.offset(17.5);
        make.left.equalTo(titleLb);
        make.height.equalTo(@(15));
    }];
    detailLb.font = [UIFont systemFontOfSize:15];
    detailLb.textColor = FUIColorFromRGB(0x4e4e4e);
    detailLb.text = @"内容";
    
    // 内容Tf
    _detailTextView = [[UITextView alloc] init];
    [self.view addSubview:_detailTextView];
    [_detailTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbFenge1.mas_bottom).with.offset(9.5);
        make.right.equalTo(self.view).with.offset(-10);
        make.left.equalTo(_titleTextField).with.offset(-6);
        make.height.equalTo(@(W * 0.6));
    }];
    // 是否可编辑
    _detailTextView.editable = YES;
    //设置代理
    _detailTextView.delegate = self;
    //设置内容
    _detailTextView.text = @"请输入您要反馈的内容";
    //字体颜色
    _detailTextView.textColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
    //设置字体
    _detailTextView.font = [UIFont systemFontOfSize:14];
    
    
    // 分隔线
    _lbFenGe2 = [[UILabel alloc] init];
    [self.view addSubview:_lbFenGe2];
    [_lbFenGe2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_detailTextView.mas_bottom).with.offset(10);
        make.left.equalTo(lbFenge1);
        make.right.equalTo(self.view);
        make.height.equalTo(@(1));
    }];
    _lbFenGe2.backgroundColor = FUIColorFromRGB(0xeeeeee);
    [_lbFenGe2 layoutIfNeeded];
    [self.view layoutIfNeeded];
    
    
    LxGridViewFlowLayout *layout = [[LxGridViewFlowLayout alloc] init];
    _margin = 4;
    _itemWH = (W - 50) / 4;
    layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_lbFenGe2.frame), W, (W-50)/4+20) collectionViewLayout:layout];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TZTestCell class] forCellWithReuseIdentifier:@"TZTestCell"];
    
}

#pragma  mark - textField delegate
// 已经结束输入
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"3");//文本彻底结束编辑时调用
    
    if ([textField.text isEqualToString:@""]) {
        
    }else {
        // 修改用户资料字典
        [_mutDicData setObject:textField.text forKey:@"title"];
    }
}


#pragma mark - UITextViewDelegate协议中的方法
//将要进入编辑模式
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if ([_detailTextView.text isEqualToString:@"请输入您要反馈的内容"]) {
        
        //设置内容
        _detailTextView.text = @"";
        //字体颜色
        _detailTextView.textColor = FUIColorFromRGB(0x4e4e4e);
    }
    
    return YES;
}
//已经进入编辑模式
- (void)textViewDidBeginEditing:(UITextView *)textView{}
//将要结束/退出编辑模式
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{return YES;}
//已经结束/退出编辑模式
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    if ([_detailTextView.text isEqualToString:@""]) {
        //设置内容
        _detailTextView.text = @"请输入您要反馈的内容";
        //字体颜色
        _detailTextView.textColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
    }else {
        
        [_mutDicData setObject:_detailTextView.text forKey:@"content"];
    }
    
}
//当textView的内容发生改变的时候调用
- (void)textViewDidChange:(UITextView *)textView{}
//选中textView 或者输入内容的时候调用
- (void)textViewDidChangeSelection:(UITextView *)textView{}
//从键盘上将要输入到textView 的时候调用
//rangge  光标的位置
//text  将要输入的内容
//返回YES 可以输入到textView中  NO不能
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{return YES;}


// 触摸屏幕触发事件
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if ([_detailTextView isFirstResponder]) {
        [_detailTextView resignFirstResponder];
    }
    
    if ([_titleTextField isFirstResponder]) {
        [_titleTextField resignFirstResponder];
    }
}




#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    if (_selectedPhotos.count == 0) {
        
        return 1;
        
    }else {
        
        if (_selectedPhotos.count>0&&_selectedPhotos.count<=3){
            collectionView.frame = CGRectMake(0, CGRectGetMaxY(_lbFenGe2.frame), W, (W-50)/4+20);
        }else if (_selectedPhotos.count>3&&_selectedPhotos.count<=7){
            collectionView.frame = CGRectMake(0, CGRectGetMaxY(_lbFenGe2.frame), W, (W-50)/2+30);
        }else {
            collectionView.frame = CGRectMake(0, CGRectGetMaxY(_lbFenGe2.frame), W, (W-50)/4*3+40);
        }
        
        return _selectedPhotos.count+1;
    }

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TZTestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZTestCell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    if (indexPath.row == _selectedPhotos.count) {
        
        cell.imageView.image = [UIImage imageNamed:@"AlbumAddBtn"];
        cell.deleteBtn.hidden = YES;
        cell.gifLable.hidden = YES;
    } else {
        cell.imageView.image = _selectedPhotos[indexPath.row];
        cell.asset = _selectedAssets[indexPath.row];
        cell.deleteBtn.hidden = NO;
    }
    if (!self.allowPickingGifSwitch == YES) {
        cell.gifLable.hidden = YES;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 得到的所选图片数组
    NSLog(@"%@",_selectedPhotos);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedPhotos.count) {
        BOOL showSheet = NO;
        if (showSheet) {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"去相册选择", nil];
            [sheet showInView:self.view];
        } else {
            [self pushTZImagePickerController];
        }
    } else { // preview photos or video / 预览照片或者视频
        id asset = _selectedAssets[indexPath.row];
        BOOL isVideo = NO;
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = asset;
            isVideo = phAsset.mediaType == PHAssetMediaTypeVideo;
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = asset;
            isVideo = [[alAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo];
        }
        if ([[asset valueForKey:@"filename"] containsString:@"GIF"] && self.allowPickingGifSwitch == YES) {
            TZGifPhotoPreviewController *vc = [[TZGifPhotoPreviewController alloc] init];
            TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypePhotoGif timeLength:@""];
            vc.model = model;
            [self presentViewController:vc animated:YES completion:nil];
        } else if (isVideo) { // perview video / 预览视频
            TZVideoPlayerController *vc = [[TZVideoPlayerController alloc] init];
            TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypeVideo timeLength:@""];
            vc.model = model;
            [self presentViewController:vc animated:YES completion:nil];
        } else { // preview photos / 预览照片
            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row];
            imagePickerVc.maxImagesCount = maxCountTF; // 最大选择照片数
            imagePickerVc.allowPickingOriginalPhoto = YES; // 允许选择原图
            imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                _selectedPhotos = [NSMutableArray arrayWithArray:photos];
                _selectedAssets = [NSMutableArray arrayWithArray:assets];
                _isSelectOriginalPhoto = isSelectOriginalPhoto;
                [_collectionView reloadData];
                _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3) * (_margin + _itemWH));
            }];
            [self presentViewController:imagePickerVc animated:YES completion:nil];
        }
    }
}

#pragma mark - LxGridViewDataSource

/// 以下三个方法为长按排序相关代码
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.item < _selectedPhotos.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath canMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    return (sourceIndexPath.item < _selectedPhotos.count && destinationIndexPath.item < _selectedPhotos.count);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    [_selectedPhotos removeObjectAtIndex:sourceIndexPath.item];
    [_selectedPhotos insertObject:image atIndex:destinationIndexPath.item];
    
    id asset = _selectedAssets[sourceIndexPath.item];
    [_selectedAssets removeObjectAtIndex:sourceIndexPath.item];
    [_selectedAssets insertObject:asset atIndex:destinationIndexPath.item];
    
    [_collectionView reloadData];
}

#pragma mark - TZImagePickerController

- (void)pushTZImagePickerController {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCountTF columnNumber:columnNumberTF delegate:self pushPhotoPickerVc:YES];
    
    
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    if (maxCountTF > 1) {
        // 1.设置目前已经选中的图片数组
        imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    }
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = true;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = YES; // 单选模式下允许裁剪
    imagePickerVc.needCircleCrop = NO; // 圆形裁剪框
    imagePickerVc.circleCropRadius = 100;
    imagePickerVc.isStatusBarDefault = NO;
    /*
     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    //imagePickerVc.allowPreview = NO;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        // 所选的照片
        //        NSLog(@"%@",photos);
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - UIImagePickerController

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS7Later) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (iOS7Later) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self takePhoto];
                    });
                }
            }];
        } else {
            [self takePhoto];
        }
        // 拍照之前还需要检查相册权限
    } else if ([TZImageManager authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 1;
        [alert show];
    } else if ([TZImageManager authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    // 提前定位
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(CLLocation *location, CLLocation *oldLocation) {
        _location = location;
    } failureBlock:^(NSError *error) {
        _location = nil;
    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        if(iOS8Later) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        tzImagePickerVc.sortAscendingByModificationDate = YES; ///< 照片排列按修改时间升序
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                NSLog(@"图片保存失败 %@",error);
            } else {
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        //                        if (self.allowCropSwitch.isOn) { // 允许裁剪,去裁剪
                        TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                            [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                        }];
                        imagePicker.needCircleCrop = NO;
                        imagePicker.circleCropRadius = 100;
                        [self presentViewController:imagePicker animated:YES completion:nil];
                        //                        }
                        //                        else {
                        //                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                        //                        }
                    }];
                }];
            }
        }];
    }
}

- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {
    [_selectedAssets addObject:asset];
    [_selectedPhotos addObject:image];
    [_collectionView reloadData];
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = asset;
        NSLog(@"location:%@",phAsset.location);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // take photo / 去拍照
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self pushTZImagePickerController];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            NSURL *privacyUrl;
            if (alertView.tag == 1) {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
            } else {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            }
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            } else {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"抱歉" message:@"无法跳转到隐私设置页面，请手动前往设置页面，谢谢" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}
// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
    
    // 1.打印图片名字
    [self printAssetsName:assets];
    // 2.图片位置信息
    if (iOS8Later) {
        for (PHAsset *phAsset in assets) {
            NSLog(@"location:%@",phAsset.location);
        }
    }
}

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    // open this code to send video / 打开这段代码发送视频
    // [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
    // NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
    // Export completed, send video here, send by outputPath or NSData
    // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
    
    // }];
    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}

// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    [_collectionView reloadData];
}

// Decide album show or not't
// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    /*
     if ([albumName isEqualToString:@"个人收藏"]) {
     return NO;
     }
     if ([albumName isEqualToString:@"视频"]) {
     return NO;
     }*/
    return YES;
}

// Decide asset show or not't
// 决定asset显示与否
- (BOOL)isAssetCanSelect:(id)asset {
    /*
     if (iOS8Later) {
     PHAsset *phAsset = asset;
     switch (phAsset.mediaType) {
     case PHAssetMediaTypeVideo: {
     // 视频时长
     // NSTimeInterval duration = phAsset.duration;
     return NO;
     } break;
     case PHAssetMediaTypeImage: {
     // 图片尺寸
     if (phAsset.pixelWidth > 3000 || phAsset.pixelHeight > 3000) {
     // return NO;
     }
     return YES;
     } break;
     case PHAssetMediaTypeAudio:
     return NO;
     break;
     case PHAssetMediaTypeUnknown:
     return NO;
     break;
     default: break;
     }
     } else {
     ALAsset *alAsset = asset;
     NSString *alAssetType = [[alAsset valueForProperty:ALAssetPropertyType] stringValue];
     if ([alAssetType isEqualToString:ALAssetTypeVideo]) {
     // 视频时长
     // NSTimeInterval duration = [[alAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
     return NO;
     } else if ([alAssetType isEqualToString:ALAssetTypePhoto]) {
     // 图片尺寸
     CGSize imageSize = alAsset.defaultRepresentation.dimensions;
     if (imageSize.width > 3000) {
     // return NO;
     }
     return YES;
     } else if ([alAssetType isEqualToString:ALAssetTypeUnknown]) {
     return NO;
     }
     }*/
    return YES;
}


#pragma mark - Click Event

- (void)deleteBtnClik:(UIButton *)sender {
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [_selectedAssets removeObjectAtIndex:sender.tag];
    
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [_collectionView reloadData];
    }];
}



#pragma mark - Private

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        //NSLog(@"图片名字:%@",fileName);
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
