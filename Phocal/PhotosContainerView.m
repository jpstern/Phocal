//
//  PhotosContainer.m
//  Phocal
//
//  Created by Josh Stern on 4/6/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "LikeGestureView.h"
#import "PhotosContainerView.h"

const int kScrollHeight = 100;

@interface PhotosContainerView ()

@property (nonatomic, assign) CGFloat originalHeight;
@property (nonatomic, retain) UIGestureRecognizer* tapRecognizer;

@end

@implementation PhotosContainerView

- (id)initWithFrame:(CGRect)frame andImageView:(UIImageView *)imageView {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.frame = frame;
        
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
            self.backgroundColor = [UIColor darkGrayColor];
        } completion:^(BOOL finished) {
            // Empty.
        }];
        

        
        _imageViews = [[NSMutableArray alloc] init];
        _likeView = [[LikeGestureView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 300)];

        _imagePaths = [[NSMutableArray alloc] init];
        _originalHeight = 200;
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        //UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        self.masterImageView = [[IndexUIImageView alloc] initWithFrame:self.frame];
        [self.masterImageView addGestureRecognizer:
            [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(takeDownViewer:)]];
        self.masterImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.masterImageView setImage:imageView.image];
        //self.masterImageView.frame = imageView.frame;
        [self addSubview:self.masterImageView];
        
        self.masterImageView.sortIndex = 0;
        
        //_imagePaths = [_imagePaths subarrayWithRange:NSMakeRange(1, _imagePaths.count - 1)];
    }
    
    return self;
}

- (void)takeDownViewer:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        [self removeFromSuperview];
    }
}

- (void)cellDidGrowToHeight:(CGFloat)height {
    
    _expanded = YES;
    CGFloat currentX = 30;
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
        self.frame = CGRectMake(0, 0, 320, height);
        self.masterImageView.frame = CGRectMake(0, 0, 320, height);
    } completion:^(BOOL finished) {
        // Empty.
    }];
    
    // Add the like view.
    if (![[self subviews] containsObject:self.likeView]) {
        [self addSubview:_likeView];
    }
    
    _imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, height-kScrollHeight, 320, kScrollHeight)];
    _imageScroll.delegate = self;
    //        _imageScroll.backgroundColor = [UIColor greenColor];
    //        _imageScroll.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //        _imageScroll.userInteractionEnabled = NO;
    _imageScroll.contentSize = CGSizeMake(900, kScrollHeight);
    [self addSubview:_imageScroll];
    _imageScroll.scrollEnabled = NO;

    // Make the large image interactable.
    self.imageScroll.scrollEnabled = YES;
    
    NSInteger index = 1;
    for (NSString *path in _imagePaths) {
        
        IndexUIImageView *imageView = [[IndexUIImageView alloc] initWithFrame:CGRectMake(320, 0, 80, 80)];
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
    self.imageScroll.scrollEnabled = NO;
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
        self.frame = CGRectMake(0, 0, 320, _originalHeight);
        self.masterImageView.frame = CGRectMake(0, 0, 320, _originalHeight);
    } completion:^(BOOL finished) {
        // Empty.
    }];
    
    
}

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _masterImageView.frame = CGRectMake(scrollView.contentOffset.x, 0, _masterImageView.frame.size.width, _masterImageView.frame.size.height);

}*/

- (void)swapImages:(UITapGestureRecognizer *)gesture {

    if (gesture.view == _masterImageView) {
        NSLog(@"master view click");
        return;
    }
    
    NSInteger index = [_imageViews indexOfObject:gesture.view];
    
    IndexUIImageView *imageView = _imageViews[index];
    
    [_imageViews removeObjectAtIndex:index];
    [_imageViews insertObject:_masterImageView atIndex:_masterImageView.tag];
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
        
        
        // Remove gesture recognizer on small image.
        for (UIGestureRecognizer* recognizer in imageView.gestureRecognizers) {
            [imageView removeGestureRecognizer:recognizer];
        }
        
        // Take the images to be swapped out of their superviews.
        [_masterImageView removeFromSuperview];
        [imageView removeFromSuperview];
        
        // Add the images their new views.
        [self insertSubview:imageView belowSubview:_likeView];
        [_imageScroll addSubview:_masterImageView];
        
        // Attach tap handler for new thumb.
        _masterImageView.userInteractionEnabled = YES;
        [_masterImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(swapImages:)]];

        // Make new large image.
        imageView.frame = _masterImageView.frame;
        _masterImageView = imageView;
        
        [_imageViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
           
            NSNumber *tag1 = @([obj1 sortIndex]);
            NSNumber *tag2 = @([obj2 sortIndex]);
            
            return [tag1 compare:tag2];
        }];
        
        CGFloat currentX = 30;
        for (UIImageView *view in _imageViews) {
        
            view.frame = CGRectMake(currentX - 25, 0, 80, 80);
            currentX += 100;
        }
        
    } completion:^(BOOL finished) {
        // Empty.
    }];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (gestureRecognizer.view == _masterImageView) {
        NSLog(@"not recognizing tap");
        return NO;
    }
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
