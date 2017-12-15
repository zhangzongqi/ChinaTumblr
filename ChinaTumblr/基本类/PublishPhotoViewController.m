//
//  PublishPhotoViewController.m
//  ChinaTumblr
//
//  Created by 张宗琦 on 2017/8/8.
//  Copyright © 2017年 张宗琦. All rights reserved.
//

#import "PublishPhotoViewController.h"
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


#import "AddLabelViewController.h" // 添加标签页面

@interface PublishPhotoViewController ()<UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,TZImagePickerControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UIActionSheetDelegate> {
    
    
    
    NSMutableDictionary *_dicData; // 需要上传的内容
    NSString *strTuPianId;
    NSString *isFailure; // 上传图片是否发生错误
    
    UIButton *labelBtn; // 标签
    UIButton *locationBtn; // 当前位置
    UIButton *quanxianBtn; // 权限
    
    
    BOOL _isSelectOriginalPhoto; // 是否选了原图
    int maxCountTF; // 最大选择照片数
    int columnNumberTF; // 调起的相册每行可显示的数量
    
    
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    
    
    CGFloat _itemWH; // collectionItem的宽高
    CGFloat _margin; // 边缘空白
    
    
    NSInteger countNum; // 上传成功次数
    
    NSString *_strForModelImgId; // 模型传过来的图片id
    
}

@property (nonatomic,strong) UITextView *tfView; // 输入框
@property (nonatomic,strong) UICollectionView *collectionView; // collectionview

@property (strong, nonatomic) CLLocation *location;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (assign, nonatomic) BOOL allowPickingGifSwitch; // 是否允许选择gif


@property (nonatomic, copy) MBProgressHUD *HUD; // 动画

@end

@implementation PublishPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 上传成功次数
    countNum = 0;
    
    // 背景色
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:21/255.0 blue:22/255.0 alpha:1.0];
    
    
    maxCountTF = 9; // 最大可选照片数
    columnNumberTF = 4; // 每行显示的照片数
    _allowPickingGifSwitch = YES; // 允许
    
    
    // 初始化数组
    [self initDataSource];
    
    
    // 布局页面
    [self layoutViews];
}

// 初始化数组
- (void) initDataSource {
    
    _dicData = [[NSMutableDictionary alloc] init];
    [_dicData setValue:@"1" forKey:@"type"];
    [_dicData setValue:@"0" forKey:@"privateFlag"];
    [_dicData setValue:@"" forKey:@"position"];
    
    // 初始化
    if (_model == nil) {
        
    }else {
        for (int i = 0; i < _model.files.count; i++) {
            // 拿到图片id
            NSString *strId = [_model.files[i] valueForKey:@"id"];
            //
            if (i == 0) {
                _strForModelImgId = strId;
            }else {
                _strForModelImgId = [NSString stringWithFormat:@"%@,%@",_strForModelImgId,strId];
            }
        }
    }
    
}


// 布局页面
- (void) layoutViews {
    
    // 文字
    UILabel *titleLb = [[UILabel alloc] init];
    [self.view addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(34);
    }];
    titleLb.font = [UIFont systemFontOfSize:16];
    titleLb.textColor = [UIColor whiteColor];
    titleLb.text = @"照片";
    
    // 取消按钮
    UIButton *cancleBtn = [[UIButton alloc] init];
    [self.view addSubview:cancleBtn];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLb);
        make.left.equalTo(self.view).with.offset(18);
    }];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor colorWithRed:124/255.0 green:125/255.0 blue:126/255.0 alpha:1.0] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancleBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 发布按钮
    UIButton *publishBtn = [[UIButton alloc] init];
    [self.view addSubview:publishBtn];
    [publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLb);
        make.right.equalTo(self.view).with.offset(-18);
    }];
    [publishBtn setTitle:@"发布" forState:UIControlStateNormal];
    [publishBtn setTitleColor:[UIColor colorWithRed:124/255.0 green:125/255.0 blue:126/255.0 alpha:1.0] forState:UIControlStateNormal];
    publishBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [publishBtn addTarget:self action:@selector(publishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 白色背景
    UIView *whiteBackView = [[UIView alloc] init];
    [self.view addSubview:whiteBackView];
    [whiteBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view).with.offset(64);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(W * 0.4375));
    }];
    whiteBackView.backgroundColor = [UIColor whiteColor];
    
    
    // 输入框
    _tfView = [[UITextView alloc] init];
    [whiteBackView addSubview:_tfView];
    [_tfView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(whiteBackView).with.offset(10);
        make.left.equalTo(whiteBackView).with.offset(10);
        make.right.equalTo(whiteBackView).with.offset(-10);
        make.height.equalTo(@(W * 0.4375 - 18));
    }];
    // 是否可编辑
    _tfView.editable = YES;
    //设置代理
    _tfView.delegate = self;
    if (_model == nil) {
        //设置内容
        _tfView.text = @"说点什么吧...";
        //字体颜色
        _tfView.textColor = FUIColorFromRGB(0x999999);
    }else {
        //设置内容
        _tfView.text = _model.content;
        //字体颜色
        _tfView.textColor = FUIColorFromRGB(0x4e4e4e);
    }
    //设置字体
    _tfView.font = [UIFont systemFontOfSize:14];
    // 变成第一响应者
    [_tfView becomeFirstResponder];
    [_tfView layoutIfNeeded];
    [self.view layoutIfNeeded];
    
    
    // 创建collectionview
    LxGridViewFlowLayout *layout = [[LxGridViewFlowLayout alloc] init];
    _margin = 4;
    _itemWH = (W - 50) / 4;
    layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tfView.frame)+10, W, (W-50)/4+20) collectionViewLayout:layout];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TZTestCell class] forCellWithReuseIdentifier:@"TZTestCell"];
    if (_model == nil) {
        // 发帖
        
    }else {
        // 修改
        _collectionView.userInteractionEnabled = NO;
    }
    
    
    
    // 标签
    labelBtn = [[UIButton alloc] init];
    [self.view addSubview:labelBtn];
    [labelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_collectionView.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        make.height.equalTo(@(H * 0.0546));
    }];
    labelBtn.backgroundColor = [UIColor whiteColor];
    labelBtn.imageView.sd_layout
    .centerYEqualToView(labelBtn)
    .leftSpaceToView(labelBtn,22)
    .heightIs(13)
    .widthIs(11);
    labelBtn.titleLabel.sd_layout
    .centerYEqualToView(labelBtn)
    .leftSpaceToView(labelBtn.imageView, 12)
    .heightRatioToView(labelBtn, 0.5);
    [labelBtn setImage:[UIImage imageNamed:@"add_icon2"] forState:UIControlStateNormal];
    [labelBtn setTitle:@"标签" forState:UIControlStateNormal];
    [labelBtn setTitleColor:FUIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    labelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [labelBtn addTarget:self action:@selector(labelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    labelBtn.selected = NO;
    
    
    // 分割线
    UILabel *fengeLb = [[UILabel alloc] init];
    [self.view addSubview:fengeLb];
    [fengeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labelBtn.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        make.height.equalTo(@(1.5));
    }];
    fengeLb.backgroundColor = FUIColorFromRGB(0xeeeeee);
    
    
    // 当前位置
    locationBtn = [[UIButton alloc] init];
    [self.view addSubview:locationBtn];
    [locationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fengeLb.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        make.height.equalTo(@(H * 0.0546 + 1));
    }];
    locationBtn.backgroundColor = [UIColor whiteColor];
    locationBtn.imageView.sd_layout
    .centerYEqualToView(locationBtn)
    .leftSpaceToView(locationBtn,22)
    .heightIs(14)
    .widthIs(14);
    locationBtn.titleLabel.sd_layout
    .centerYEqualToView(locationBtn).offset(-1)
    .leftSpaceToView(locationBtn.imageView, 12)
    .heightRatioToView(locationBtn, 0.5);
    [locationBtn setImage:[UIImage imageNamed:@"publish_icon4"] forState:UIControlStateNormal];
    [locationBtn setTitleColor:FUIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    locationBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    if (_model == nil) {
        [locationBtn setTitle:@"当前位置" forState:UIControlStateNormal];
    }else {
        [locationBtn setTitle:_model.position forState:UIControlStateNormal];
    }
    locationBtn.hidden = YES;
    
    // 分割线
//    UILabel *lbFenge2 = [[UILabel alloc] init];
//    [locationBtn addSubview:lbFenge2];
//    [lbFenge2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(locationBtn);
//        make.left.equalTo(self.view).with.offset(20);
//        make.width.equalTo(@(W - 20));
//        make.height.equalTo(@(1));
//    }];
//    lbFenge2.backgroundColor = FUIColorFromRGB(0xeeeeee);
    
    
    // 权限btn
    quanxianBtn = [[UIButton alloc] init];
    [self.view addSubview:quanxianBtn];
    [quanxianBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(locationBtn);
        make.left.equalTo(self.view);
        make.width.equalTo(@(W));
        make.height.equalTo(@(H * 0.0546));
    }];
    quanxianBtn.backgroundColor = [UIColor whiteColor];
    quanxianBtn.imageView.sd_layout
    .centerYEqualToView(quanxianBtn)
    .leftSpaceToView(quanxianBtn, 22)
    .heightIs(13)
    .widthIs(13);
    quanxianBtn.titleLabel.sd_layout
    .centerYEqualToView(quanxianBtn)
    .leftSpaceToView(quanxianBtn.imageView, 10)
    .heightRatioToView(quanxianBtn, 0.5);
    [quanxianBtn setImage:[UIImage imageNamed:@"publish_icon5"] forState:UIControlStateNormal];
    [quanxianBtn setTitleColor:FUIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    quanxianBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [quanxianBtn addTarget:self action:@selector(quanxianBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    if (_model == nil) {
        [quanxianBtn setTitle:@"公开" forState:UIControlStateNormal];
    }else {
        if ([_model.private_flag isEqualToString:@"0"]) {
            [quanxianBtn setTitle:@"公开" forState:UIControlStateNormal];
        }else {
            [quanxianBtn setTitle:@"私有" forState:UIControlStateNormal];
            [_dicData setValue:@"1" forKey:@"privateFlag"];
        }
    }
    
}


// 权限点击事件
- (void) quanxianBtnClick:(UIButton *)btn {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"公开", @"私有",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
    actionSheet.delegate = self;
}

// 弹出代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        [_dicData setValue:@"0" forKey:@"privateFlag"];
        [quanxianBtn setTitle:@"公开" forState:UIControlStateNormal];
        
    }else if (buttonIndex == 1) {
        
        [_dicData setValue:@"1" forKey:@"privateFlag"];
        [quanxianBtn setTitle:@"私有" forState:UIControlStateNormal];
        
    }else {
        
        NSLog(@"取消");
    }
}


// labelBtn点击事件
- (void) labelBtnClick:(UIButton *)labelBtn1 {
    
    
    AddLabelViewController *vc = [[AddLabelViewController alloc] init];
    if (labelBtn.selected == NO) {
        
    }else {
        vc.strCurrentLabel = labelBtn.titleLabel.text;
    }
    [self presentViewController:vc animated:YES completion:nil];
    
}


#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    
    if (_model == nil) {
        // 发帖
        if (_selectedPhotos.count == 0) {
            
            return 1;
            
        }else {
            
            if (_selectedPhotos.count>0&&_selectedPhotos.count<=3){
                collectionView.frame = CGRectMake(0, CGRectGetMaxY(_tfView.frame)+10, W, (W-50)/4+20);
            }else if (_selectedPhotos.count>3&&_selectedPhotos.count<=7){
                collectionView.frame = CGRectMake(0, CGRectGetMaxY(_tfView.frame)+10, W, (W-50)/2+30);
            }else {
                collectionView.frame = CGRectMake(0, CGRectGetMaxY(_tfView.frame)+10, W, (W-50)/4*3+40);
            }
            
            return _selectedPhotos.count+1;
        }
    }else {
        
        // 修改
        if (_model.files.count>0&&_model.files.count<=4) {
            collectionView.frame = CGRectMake(0, CGRectGetMaxY(_tfView.frame)+10, W, (W-50)/4+20);
        }else if (_model.files.count>4&&_model.files.count<=8) {
            collectionView.frame = CGRectMake(0, CGRectGetMaxY(_tfView.frame)+10, W, (W-50)/2+30);
        }else {
            collectionView.frame = CGRectMake(0, CGRectGetMaxY(_tfView.frame)+10, W, (W-50)/4*3+40);
        }
        
        return _model.files.count;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (_model == nil) {
        // 发帖
        TZTestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZTestCell" forIndexPath:indexPath];
        cell.videoImageView.hidden = YES;
        if (indexPath.row == _selectedPhotos.count) {
            
            cell.imageView.image = [UIImage imageNamed:@"AlbumAddBtn"];
            //        cell.backgroundColor = FUIColorFromRGB(0xeeeeee);
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
        
    }else {
        
        // 修改
        TZTestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZTestCell" forIndexPath:indexPath];
        cell.videoImageView.hidden = YES;
        
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[_model.files[indexPath.row] valueForKey:@"path"]] placeholderImage:[UIImage imageNamed:@""]];
        cell.deleteBtn.hidden = YES;
        cell.gifLable.hidden = YES;
        
        return cell;
    }
    
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
//- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 0) { // take photo / 去拍照
//        [self takePhoto];
//    } else if (buttonIndex == 1) {
//        [self pushTZImagePickerController];
//    }
//}

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




#pragma mark - UITextViewDelegate协议中的方法
//将要进入编辑模式
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if ([_tfView.text isEqualToString:@"说点什么吧..."]) {
        
        //设置内容
        _tfView.text = @"";
        //字体颜色
        _tfView.textColor = FUIColorFromRGB(0x4e4e4e);
        //设置字体
        _tfView.font = [UIFont systemFontOfSize:16];
    }
    
    return YES;
}
//已经进入编辑模式
- (void)textViewDidBeginEditing:(UITextView *)textView{}
//将要结束/退出编辑模式
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{return YES;}
//已经结束/退出编辑模式
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    [_dicData setValue:textView.text forKey:@"content"];
    
    if ([_tfView.text isEqualToString:@""]) {
        //设置字体
        _tfView.font = [UIFont systemFontOfSize:12];
        //设置内容
        _tfView.text = @"说点什么吧...";
        //字体颜色
        _tfView.textColor = FUIColorFromRGB(0x999999);
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
    
    if ([_tfView isFirstResponder]) {
        [_tfView resignFirstResponder];
    }
}


// 发布按钮点击事件
- (void) publishBtnClick {
    
    // 获取用户加密信息
    NSArray *userJiaMiArr = [GetUserJiaMi getUserTokenAndCgAndKey];
    
    // 进行发帖请求
    HttpRequest *http = [[HttpRequest alloc] init];
    
    // 释放第一响应者
    [_tfView resignFirstResponder];
    
    if ([[[_dicData objectForKey:@"content"] stringByReplacingOccurrencesOfString:@" "  withString:@""] isEqualToString:@""]) {
        
        // 内容
        [MBHUDView hudWithBody:@"说点什么吧" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
    }else if([[_dicData objectForKey:@"keywords"] isEqualToString:@""]){
        
        // 关键词
        [MBHUDView hudWithBody:@"标签为空" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
    }else if (_selectedPhotos.count == 0 && _model == nil){
        
        // 关键词
        [MBHUDView hudWithBody:@"至少一张图片" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
        
    }else if (_tfView.text.length > 300) {
        
        // 关键词
        [MBHUDView hudWithBody:@"最多300字~" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
    }else {
        
        
        
        if (_model == nil) {
            // 发新帖
            // 创建动画
            _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _HUD.labelText = @"正在上传第1张图片";
            // 展示动画
            [_HUD show:YES];
            
            
            NSDictionary *dicDataForTuPian = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2]};
            
            
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
                            
                            [_dicData setValue:strTuPianId forKey:@"files"];
                            
                            // 获取到用户相关的加密信息
                            NSString *dataStrJiaMi = [[MakeJson createJson:_dicData] AES128EncryptWithKey:userJiaMiArr[3]];
                            
                            NSDictionary *dicData111 = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStrJiaMi};
                            
                            NSLog(@"dicData111:%@",dicData111);
                            
                            [http PostAddNoteWithDic:dicData111 Success:^(id userInfo) {
                                
                                if ([userInfo isEqualToString:@"0"]) {
                                    
                                    // 隐藏动画
                                    [_HUD hide:YES];
                                    
                                    // 上传成功次数
                                    countNum = 0;
                                    
                                }
                                if ([userInfo isEqualToString:@"1"]) {
                                    
                                    // 隐藏动画
                                    [_HUD hide:YES];
                                    
                                    // 发帖成功
                                    [MBHUDView hudWithBody:@"发帖成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                                    
                                    // 上传成功次数
                                    countNum = 0;
                                    
//                                    // 创建消息中心
//                                    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
//                                    // 在消息中心发布自己的消息
//                                    [notiCenter postNotificationName:@"fatieChengGong" object:@"20"];
                                    
                                    // 等一秒跳转回首页
                                    // 1秒后，跳转
                                    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(tiaozhuanEvent) userInfo:nil repeats:NO];
                                }
                                
                            } failure:^(NSError *error) {
                                
                                // 网络请求失败
                                // 上传成功次数
                                countNum = 0;
                                // 隐藏动画
                                [_HUD hide:YES];
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
        }else {
            
            // 修改帖子
            
            
            // 创建动画
            _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            // 展示动画
            [_HUD show:YES];
            
            [_dicData setValue:_model.id1 forKey:@"id"];
            // 图片id
            [_dicData setValue:_strForModelImgId forKey:@"files"];
            
            NSLog(@"*&*&*&*&*&*&*&:::%@",_dicData);
            
            // 获取到用户相关的加密信息
            NSString *dataStrJiaMi = [[MakeJson createJson:_dicData] AES128EncryptWithKey:userJiaMiArr[3]];
            
            NSDictionary *dicData111 = @{@"tk":userJiaMiArr[0],@"key":userJiaMiArr[1],@"cg":userJiaMiArr[2],@"data":dataStrJiaMi};
            
            [http PostEditNoteWithDic:dicData111 Success:^(id userInfo) {
                
                if ([userInfo isEqualToString:@"0"]) {
                    
                    // 发帖失败,有后台提示
                    // 隐藏动画
                    [_HUD hide:YES];
                }else {
                    // 隐藏动画
                    [_HUD hide:YES];
                    // 发帖成功
                    [MBHUDView hudWithBody:@"修改成功" type:MBAlertViewHUDTypeLabelIcon hidesAfter:1.f backGroundColorWithWhite:0.0 show:YES];
                    
                    
                    
                    
                    
                    
                    
                    NSLog(@":::::::%@:::::::",_dicData);
                    
                    
                    // 创建消息中心
                    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
                    // 在消息中心发布自己的消息,
                    [notiCenter postNotificationName:@"reviseTieZiSuccess" object:@"6666" userInfo:_dicData];
                    
                    
                    
                    
                    
                    
                    
                    // 等一秒跳转
                    // 1秒后，跳转
                    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(tiaozhuanEvent) userInfo:nil repeats:NO];
                }
                
                
            } failure:^(NSError *error) {
                // 网络错误
                // 隐藏动画
                [_HUD hide:YES];
            }];
        }
        
        
    }
}

// 发帖成功后消失当前页
- (void) tiaozhuanEvent {
    
    // 标签数组消失
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"labelArr"];
    
    // 消失本页面
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 取消按钮点击事件
- (void) cancleBtnClick {
    
    // 标签数组消失
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"labelArr"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 页面将要消失
- (void) viewWillDisappear:(BOOL)animated {
    
    //这个接口可以动画的改变statusBar的前景色
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

// 页面将要显示
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [user objectForKey:@"labelArr"];
    if (arr.count == 0) {
        
        [_dicData setValue:@"" forKey:@"keywords"];
        
        if (_model == nil) {
            
            [labelBtn setTitle:@"标签" forState:UIControlStateNormal];
            labelBtn.selected = NO;
        }else {
            if (_model.kwList == nil) {
                [labelBtn setTitle:@"标签" forState:UIControlStateNormal];
                labelBtn.selected = NO;
            }else {
                
                NSString *str = [_model.kwList stringByReplacingOccurrencesOfString:@"," withString:@" "];
                
                [labelBtn setTitle:str forState:UIControlStateNormal];
                labelBtn.selected = YES;
                // 加入需要传入的参数字典
                [_dicData setValue:_model.kwList forKey:@"keywords"];
            }
        }
        
    }else {
        
        NSString *strLabel = [[NSString alloc] init];
        NSString *strLableForDicData = [[NSString alloc] init];
        for (int i = 0; i < arr.count; i++) {
            
            if (i == 0) {
                
                strLabel = arr[i];
                strLableForDicData = arr[i];
                
            }else {
                strLabel = [NSString stringWithFormat:@"%@ %@",strLabel,arr[i]];
                strLableForDicData = [NSString stringWithFormat:@"%@,%@",strLableForDicData,arr[i]];
            }
        }
        
        [labelBtn setTitle:strLabel forState:UIControlStateNormal];
        labelBtn.selected = YES;
        
        // 加入需要传入的参数字典
        [_dicData setValue:strLableForDicData forKey:@"keywords"];
        
        
    };
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
