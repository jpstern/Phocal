//
//  PhotosContainer.m
//  Phocal
//
//  Created by Josh Stern on 4/6/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "LikeGestureView.h"
#import "PhotosContainer.h"

@interface PhotosContainer ()

@property (nonatomic, assign) CGFloat originalHeight;

@end

@implementation PhotosContainer


- (id)initWithFrame:(CGRect)frame andImagePaths:(NSArray *)paths {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _imageViews = [[NSMutableArray alloc] init];
        _likeView = [[LikeGestureView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

        _imagePaths = paths;
        _originalHeight = 200;
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        _imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
        _imageScroll.delegate = self;
//        _imageScroll.backgroundColor = [UIColor greenColor];
//        _imageScroll.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//        _imageScroll.userInteractionEnabled = NO;
        _imageScroll.contentSize = CGSizeMake(900, frame.size.height);
        [self addSubview:_imageScroll];
        
//        _masterImageView =
        IndexUIImageView *mainImageView = [[IndexUIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        mainImageView.userInteractionEnabled = YES;
        UIGestureRecognizer *tap = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(swapImages:)];
        tap.delegate = self;
        mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        [mainImageView addGestureRecognizer:tap];
//        [mainImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapImages:)]];
//        [mainImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapImages:)]];
        mainImageView.sortIndex = 0;
//        mainImageView.backgroundColor = color;//[UIColor darkGrayColor];
        [_imageScroll addSubview:mainImageView];

        _masterImageView = mainImageView;
        
//        [_imageViews addObject:_masterImageView];
        
        NSString *rootPath = [paths firstObject];
        
        NSURL *rootURL = [NSURL URLWithString:rootPath];

        [_masterImageView setImageWithURL:rootURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        _imagePaths = [_imagePaths subarrayWithRange:NSMakeRange(1, _imagePaths.count - 1)];
    }
    
    return self;
}

- (void)cellDidGrowToHeight:(CGFloat)height {
    
    _expanded = YES;
    CGFloat currentX = 30;
    
    self.frame = CGRectMake(0, 0, 320, height);
    _imageScroll.frame = CGRectMake(0, 0, 320, height);
    
    // Add the like view.
    if (![[self subviews] containsObject:self.likeView]) {
        [self addSubview:_likeView];
    }
    
    
    NSInteger index = 1;
    for (NSString *path in _imagePaths) {
        
//        _masterImageView.frame.size.height + _masterImageView.frame.origin.y + (self.frame.size.height - (_masterImageView.frame.size.height + _masterImageView.frame.origin.y)) / 2
        
        IndexUIImageView *imageView = [[IndexUIImageView alloc] initWithFrame:CGRectMake(320, 200, 80, 80)];
        imageView.sortIndex = index;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapImages:)]];
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
//        imageView.backgroundColor = color;
        [imageView setImageWithURL:[NSURL URLWithString:path]];
        [_imageViews addObject:imageView];
        [_imageScroll addSubview:imageView];
        
        [UIView animateWithDuration:0.5 delay:0.25 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:0 animations:^{
           
            imageView.center = CGPointMake(currentX, imageView.center.y);
            
        } completion:^(BOOL finished) {
                        
        }];
        
        index ++;
        currentX += 100;
    }
    
}

- (void)cellDidShrink {
    
    _expanded = NO;
    [self.likeView removeFromSuperview];
    
    self.frame = CGRectMake(0, 0, 320, _originalHeight);
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    _masterImageView.frame = CGRectMake(scrollView.contentOffset.x, 0, _masterImageView.frame.size.width, _masterImageView.frame.size.height);
}

- (void)swapImages:(UITapGestureRecognizer *)gesture {

    if (gesture.view == _masterImageView) return;
    
    NSInteger index = [_imageViews indexOfObject:gesture.view];
    
    IndexUIImageView *imageView = _imageViews[index];
    
    [_imageViews removeObjectAtIndex:index];
    [_imageViews insertObject:_masterImageView atIndex:_masterImageView.tag];
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
        
        imageView.frame = _masterImageView.frame;
        _masterImageView = imageView;
        
        [_imageViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
           
            NSNumber *tag1 = @([obj1 sortIndex]);
            NSNumber *tag2 = @([obj2 sortIndex]);
            
            return [tag1 compare:tag2];
        }];
        
        CGFloat currentX = 30;
        for (UIImageView *view in _imageViews) {
        
            view.frame = CGRectMake(currentX - 25, _originalHeight, 80, 80);
            currentX += 100;
        }
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (gestureRecognizer.view == _masterImageView) return NO;
    return _expanded;
}
//
//- (void)swapLarge:(UIImageView *)mainView WithSmall:(UIImageView*)smallView {
//    
//    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.75 options:0 animations:^{
//        CGRect tmp = mainView.frame;
//        
//        mainView.frame = smallView.frame;
//        smallView.frame = tmp;
//    } completion:^(BOOL finished) {
//        
//    }];
//
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
