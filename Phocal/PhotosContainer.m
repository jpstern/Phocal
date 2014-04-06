//
//  PhotosContainer.m
//  Phocal
//
//  Created by Josh Stern on 4/6/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "PhotosContainer.h"

@interface PhotosContainer ()

@property (nonatomic, assign) CGFloat originalHeight;

@end

@implementation PhotosContainer


- (id)initWithFrame:(CGRect)frame andImagePaths:(NSArray *)paths {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _imageViews = [[NSMutableArray alloc] init];

        _imagePaths = paths;
        _originalHeight = frame.size.height;
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        _imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.width)];
        _imageScroll.delegate = self;
        _imageScroll.contentSize = CGSizeMake(640, frame.size.height);
        [self addSubview:_imageScroll];
        
//        _masterImageView =
        IndexUIImageView *mainImageView = [[IndexUIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        mainImageView.userInteractionEnabled = YES;
        [mainImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapImages:)]];
        mainImageView.sortIndex = 0;
        mainImageView.backgroundColor = color;//[UIColor darkGrayColor];
        [_imageScroll addSubview:mainImageView];

        _masterImageView = mainImageView;
        
//        [_imageViews addObject:_masterImageView];
        
        NSString *rootPath = [paths firstObject];
        
        NSURL *rootURL = [NSURL URLWithString:rootPath];
        
        
    }
    
    return self;
}

- (void)cellDidGrowToHeight:(CGFloat)height {
    
    CGFloat currentX = 35;
    
    self.frame = CGRectMake(0, 0, 320, height);
    
    NSInteger index = 1;
    for (NSString *path in _imagePaths) {
        
        IndexUIImageView *imageView = [[IndexUIImageView alloc] initWithFrame:CGRectMake(320, _originalHeight, 50, 50)];
        imageView.sortIndex = index;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapImages:)]];
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        imageView.backgroundColor = color;
        [imageView setImageWithURL:[NSURL URLWithString:path]];
        [_imageViews addObject:imageView];
        [_imageScroll addSubview:imageView];
        
        [UIView animateWithDuration:0.5 delay:1 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:0 animations:^{
           
            imageView.center = CGPointMake(currentX, imageView.center.y);
            
        } completion:^(BOOL finished) {
            
        }];
        
        index ++;
        currentX += 70;
    }
    
}

- (void)cellDidShrink {
    
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
        
        CGFloat currentX = 35;
        for (UIImageView *view in _imageViews) {
        
            view.frame = CGRectMake(currentX - 25, _originalHeight, 50, 50);
            currentX += 70;
        }
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)swapLarge:(UIImageView *)mainView WithSmall:(UIImageView*)smallView {
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.75 options:0 animations:^{
        CGRect tmp = mainView.frame;
        
        mainView.frame = smallView.frame;
        smallView.frame = tmp;
    } completion:^(BOOL finished) {
        
    }];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
