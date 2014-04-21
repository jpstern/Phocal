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

@property (nonatomic, strong) UIScrollView *imageScroll;
@property (nonatomic, strong) LikeGestureView* likeView;
@property (nonatomic, strong) UIButton* voteHeart;

@property (nonatomic, strong) NSMutableDictionary *photoDict;

@property (nonatomic,strong) UIAlertView *alert;

@property (nonatomic, assign) BOOL expanded;

- (id)initWithFrame:(CGRect)frame andImageView:(IndexUIImageView *)imageView;
- (void)animateFromCellinRect:(CGRect)rect withCompletion:(void (^)())completion;
- (void)animateFromScratchWithLabel:(UILabel *)label;


@end
