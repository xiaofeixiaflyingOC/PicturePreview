//
//  PicturePreviewCollectionViewCell.m
//  PicturePreview
//
//  Created by shengxin on 16/4/12.
//  Copyright © 2016年 shengxin. All rights reserved.
//

#import "PicturePreviewCollectionViewCell.h"
#import "PicturePreviewView.h"

@interface PicturePreviewCollectionViewCell()<UIScrollViewDelegate>

@property (nonatomic, strong) PicturePreviewView *iPicturePreviewView;

@end

@implementation PicturePreviewCollectionViewCell

#pragma mark - public

- (void)setImageUrl:(NSString*)aUrl{
    [self.iPicturePreviewView setImageUrl:aUrl];
}

#pragma mark - init

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView{
    self.iPicturePreviewView = [[PicturePreviewView alloc] initWithFrame:self.bounds];
    [self.contentView addSubview:self.iPicturePreviewView];
}

@end
