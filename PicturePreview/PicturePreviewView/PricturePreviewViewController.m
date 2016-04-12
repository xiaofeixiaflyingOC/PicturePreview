//
//  PricturePreviewViewController.m
//  PicturePreview
//
//  Created by shengxin on 16/4/12.
//  Copyright © 2016年 shengxin. All rights reserved.
//

#import "PricturePreviewViewController.h"
#import "PicturePreviewCollectionViewCell.h"

@interface PricturePreviewViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *iCollectionView;
@property (nonatomic, strong) NSArray *iCollectionViewArr;
@property (nonatomic, strong) UIToolbar *iNavBar;

@end

@implementation PricturePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initCollectionView];
    [self initNavView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrHideBar) name:@"singleTapNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init

- (void)initCollectionView{
    
    self.iCollectionViewArr = [NSArray arrayWithObjects:@"http://s.tx2010.com/d7f9d8ec-1410-4a00-a8ec-0d5c4c2b5db4?imageView2/1/format/jpg/w/750/h/457",@"http://s.tx2010.com/c9c193fe-b34e-47e7-bbc0-ef3e232f9656?imageView2/1/format/jpg",@"http://s.tx2010.com/ebcdd72f-12f7-4000-bdbb-52ff39849250?imageView2/1/format/jpg",@"http://s.tx2010.com/0889c7b3-8395-4b59-aa27-679fd3b44455?imageView2/1/format/jpg",@"http://s.tx2010.com/c0cf087f-aacb-486e-95d4-0a20b49e638a?imageView2/1/format/jpg",nil];
    
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc] init];
    layOut.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.iCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layOut];
    self.iCollectionView.dataSource = self;
    self.iCollectionView.delegate = self;
    self.iCollectionView.pagingEnabled = YES;
    [self.view addSubview:self.iCollectionView];
    
    [self.iCollectionView registerClass:[PicturePreviewCollectionViewCell class] forCellWithReuseIdentifier:@"PicturePreviewCollectionViewCell"];
}

- (void)initNavView{
    self.iNavBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 20,44, 44)];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];

    button.imageEdgeInsets = UIEdgeInsetsMake(20, -20, 0, 0);
    [button addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *a = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.iNavBar setItems:[NSArray arrayWithObjects:a, nil]];
    [self.view addSubview:self.iNavBar];
}

- (void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.iCollectionViewArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PicturePreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PicturePreviewCollectionViewCell" forIndexPath:indexPath];
    [cell setImageUrl:[self.iCollectionViewArr objectAtIndex:indexPath.row]];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.view.frame.size.width,self.view.frame.size.height);
}

// 设置最小行间距，也就是前一行与后一行的中间最小间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

// 设置最小列间距，也就是左行与右一行的中间最小间隔  根据最小距离推算一共有每行有多少个cell
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - NSNotification

- (void)showOrHideBar{
    __weak PricturePreviewViewController *weself = self;
    if(self.iNavBar.alpha==0){
        [UIView animateWithDuration:0.5 animations:^{
            weself.iNavBar.alpha = 1.0;
        }];
    }else{
        [UIView animateWithDuration:1.0 animations:^{
            weself.iNavBar.alpha = 0.0;
        }];
    }
}
@end
