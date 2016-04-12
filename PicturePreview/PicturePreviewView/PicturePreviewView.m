//
//  PicturePreviewView.m
//  PicturePreview
//
//  Created by shengxin on 16/4/12.
//  Copyright © 2016年 shengxin. All rights reserved.
//

#import "PicturePreviewView.h"
#import "UIImageView+WebCache.h"
#import "DACircularProgressView.h"

#define MaximumZoomScale 3.0
#define MinimumZoomScale 1.0

@interface PicturePreviewView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *iImageView;
@property (nonatomic, strong) DACircularProgressView *loadingIndicator;

@end

@implementation PicturePreviewView

#pragma mark - public

- (void)setImageUrl:(NSString*)aUrl{
    __weak PicturePreviewView *weself = self;

    [self.iImageView sd_setImageWithURL:[NSURL URLWithString:aUrl] placeholderImage:nil options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize){
        weself.loadingIndicator.progress = MAX(MIN(1, (1.0*receivedSize)/expectedSize), 0);
    }completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
         [weself displayImage];
        weself.loadingIndicator.hidden = YES;
    }];
}

#pragma mark - private

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.delegate = self;
        if (self.iImageView==nil) {
            self.iImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            self.iImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:self.iImageView];
            
            _loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 30.0f, 40.0f, 40.0f)];
            _loadingIndicator.userInteractionEnabled = NO;
            _loadingIndicator.thicknessRatio = 0.2;
            _loadingIndicator.roundedCorners = YES;
            _loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
            [self addSubview:_loadingIndicator];
            _loadingIndicator.center = self.center;
            
            
            UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
            g.numberOfTapsRequired = 2;
            [self addGestureRecognizer:g];
            
            UITapGestureRecognizer *s = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
            s.numberOfTapsRequired = 1;
            [s requireGestureRecognizerToFail:g];
            [self addGestureRecognizer:s];
        }

    }
    return self;
}

// Get and display image
- (void)displayImage {
    // Reset
    self.maximumZoomScale = MinimumZoomScale;
    self.minimumZoomScale = MinimumZoomScale;
    self.zoomScale = MinimumZoomScale;
    self.contentSize = CGSizeMake(0, 0);
    
    // Get image from browser as it handles ordering of fetching
    UIImage *img = self.iImageView.image;
    if (img) {
        // Set image
        self.iImageView.image = img;
        self.iImageView.hidden = NO;
        
        // Setup photo frame
        CGRect photoImageViewFrame;
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = img.size;
        self.iImageView.frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        
        // Set zoom to minimum zoom
        [self setMaxMinZoomScalesForCurrentBounds];
        
    } else {
        // Failed no image
    }
    [self setNeedsLayout];
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Reset
    self.maximumZoomScale = MinimumZoomScale;
    self.minimumZoomScale = MinimumZoomScale;
    self.zoomScale = MinimumZoomScale;
    
    // Bail if no image
    if (_iImageView.image == nil) return;
    
    // Reset position
    _iImageView.frame = CGRectMake(0, 0, _iImageView.frame.size.width, _iImageView.frame.size.height);
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _iImageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = MinimumZoomScale;
    }

    // Set min/max zoom
    self.maximumZoomScale = MaximumZoomScale;
    self.minimumZoomScale = minScale;
    // Initial zoom
    self.zoomScale = [self initialZoomScaleWithMinScale];
    
    // If we're zooming to fill then centralise
    if (self.zoomScale != minScale) {
        // Centralise
        self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                                     (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);
        // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
        self.scrollEnabled = NO;
    }
    
    // Layout
    [self setNeedsLayout];
    
}

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_iImageView ) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _iImageView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        
        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = MAX(xScale, yScale);
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
        }
        
        if (imageSize.width==boundsSize.width) {
            zoomScale = 1.0;
        }
    }
    return zoomScale;
}

#pragma mark - UITouch

- (void)doubleTap:(id)aTapRecognizer{
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer*)aTapRecognizer;
    CGPoint point = [tapRecognizer locationInView:self.iImageView];
    [self handleDoubleTap:point];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    
    // Zoom
    if (self.zoomScale != self.minimumZoomScale && self.zoomScale != [self initialZoomScaleWithMinScale]) {
        
        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
        
    } else {
        
        // Zoom in to twice the size
        CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(CGPoint)touchPoint{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"singleTapNotification" object:nil];
}

#pragma mark - Layout

- (void)layoutSubviews {
    // Super
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _iImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_iImageView.frame, frameToCenter))
        _iImageView.frame = frameToCenter;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _iImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


@end
