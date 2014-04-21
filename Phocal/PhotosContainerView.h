//
//  PhotosContainer.h
//  Phocal
//
//  Created by Josh Stern on 4/6/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IndexUIImageView.h"

@class LikeGestureView;
@class ImageCell;
@class IndexUIImageView;

@interface PhotosContainerView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView* imageViewerPane;
@property (nonatomic, strong) IndexUIImageView *masterImageView;
@property (nonatomic, strong) UILabel* momentLabel;
@property (nonatomic, strong) NSMutableArray *imageViews;

@property (nonatomic, strong) NSArray *imagePaths;
@property (nonatomic, strong) UIScrollView *imageScroll;
@property (nonatomic, strong) LikeGestureView* likeView;
@property (nonatomic, strong) UIImageView *heartView;

@property (nonatomic,strong) UIAlertView *alert;

@property (nonatomic, assign) BOOL expanded;

- (id)initWithWindow:(UIWindow *)window andImageView:(IndexUIImageView *)imageView inRect:(CGRect)rect;

- (void)cellDidGrowToHeight:(CGFloat)height;
- (void)cellDidShrink;

@end
