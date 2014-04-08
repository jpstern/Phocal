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

@interface PhotosContainer : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IndexUIImageView *masterImageView;
@property (nonatomic, strong) NSMutableArray *imageViews;

@property (nonatomic, strong) NSArray *imagePaths;
@property (nonatomic, strong) UIScrollView *imageScroll;
@property (nonatomic, strong) LikeGestureView* likeView;

@property (nonatomic, assign) BOOL expanded;

- (id)initWithFrame:(CGRect)frame andImagePaths:(NSArray *)paths;

- (void)cellDidGrowToHeight:(CGFloat)height;
- (void)cellDidShrink;

@end
