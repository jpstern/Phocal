//
//  PhotosContainer.m
//  Phocal
//
//  Created by Josh Stern on 4/6/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "LikeGestureView.h"
#import "MomentCell.h"
#import "PhocalCore.h"
#import "PhotosContainerView.h"

const int kScrollHeight = 100;
const int kImagePaneOffset = 60;
const int kMomentLabelOffset = 20;
const int kImageSize = 320;
const int kScrollMargin = 15;
const int kThumbSize = 80;

@interface PhotosContainerView ()

@property (nonatomic, retain) UIGestureRecognizer* tapRecognizer;

@property (nonatomic, strong) IndexUIImageView *initialMaster;

@end

@implementation PhotosContainerView

- (id)initWithWindow:(UIWindow *)window andImageView:(IndexUIImageView *)imageView {
    
    self = [super initWithFrame:window.frame];
    
    if (self) {
        self.frame = window.frame;
        
        // Set our main image view.
        self.masterImageView = imageView;
        self.masterImageView.sortIndex = 0;
        _masterImageView.votedView.hidden=NO;
        
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
           self.backgroundColor = [UIColor colorWithHue:300.0 saturation:0.1 brightness:0.5 alpha:.95];
         } completion:^(BOOL finished) {
         // Empty.
         }];
        
        _imageViews = [[NSMutableArray alloc] init];
        _likeView = [[LikeGestureView alloc] initWithFrame:CGRectMake(0, kImagePaneOffset, self.frame.size.width, 300)];

        //_likeView.currectImgView=imageView;
        _likeView.target = self;
        _likeView.selector = @selector(voted);
        
        // Add the scroll view.
        int imageBottom = kImagePaneOffset + kImageSize;
        int scrollTop = (((window.bounds.size.height - imageBottom) / 2) + imageBottom) - (kScrollHeight / 2);
        _imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollTop, kImageSize, kScrollHeight)];
        _imageScroll.delegate = self;
        _imageScroll.contentSize = CGSizeMake(0, kScrollHeight);
        [_imageScroll setShowsHorizontalScrollIndicator:NO];
        [_imageScroll setShowsVerticalScrollIndicator:NO];
        
        // Add the views in order.
        [self addSubview:_likeView];
        [self addSubview:_imageScroll];
        
        // Fetch the nearest photos.
        [self getClosestPhotos];
    }
    
    return self;
}

- (void)getClosestPhotos {
    // Fetch the closest photos to this one.
    [[PhocalCore sharedClient] getClosestPhotosForLat:self.masterImageView.lat andLng:self.masterImageView.lng completion:^(NSArray * photos) {
        if (!photos) {
            return;
        }
        
        NSLog(@"Got %d closest photos", photos.count);
        int thumbTop = (kScrollHeight / 2 - kThumbSize / 2);
        int index = 0;
        for (NSDictionary* photoDict in photos) {
            // If this photo is the one we're currently looking at, don't add it.
            NSString* newPhotoURL = [[PhocalCore sharedClient] photoURLForId:photoDict[@"_id"]];
            if ([newPhotoURL isEqualToString:self.masterImageView.URL]) {
                continue;
            }
            
            IndexUIImageView* thumb = [[IndexUIImageView alloc] initWithFrame:
                                       CGRectMake(kScrollMargin + index*kThumbSize + index*kScrollMargin,
                                                  thumbTop,
                                                  kThumbSize,
                                                  kThumbSize)];
            thumb.sortIndex = index + 1;
            thumb.userInteractionEnabled = YES;
            [thumb addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(swapImages:)]];
            thumb.contentMode = UIViewContentModeScaleAspectFill;
            
            // Set the image properties.
            thumb.lat = photoDict[@"lat"];
            thumb.lng = photoDict[@"lng"];
            thumb.URL = newPhotoURL;
            [thumb setImageWithURL:[NSURL URLWithString:newPhotoURL]
                  placeholderImage:[UIImage imageNamed:@"placeholder"]];
            
            // Add the image to the scroll view and our image views array.
            [_imageScroll addSubview:thumb];
            _imageScroll.contentSize = CGSizeMake(_imageScroll.contentSize.width + kScrollMargin + kThumbSize,
                                                  kScrollHeight);
            [_imageViews addObject:thumb];
            
            UIButton *test = [UIButton buttonWithType:UIButtonTypeCustom];
            test.frame = CGRectMake(15, 335, 30, 30);
            //test.center = CGPointMake(_listButton.center.x, _bottomContainer.frame.size.height / 2);
            [test setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
            [test addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:test];
            
            index++;
        }
        
        // Add a margin to the right side of the scroll.
        _imageScroll.contentSize = CGSizeMake(_imageScroll.contentSize.width + kScrollMargin, kScrollHeight);
    }];
}

- (void)voted
{
    if (_masterImageView == _initialMaster) {
        
        _photoDict[@"voted"] = @(YES);
    }
    
    NSLog(@"Voted");
    _masterImageView.voted=YES;
    [_masterImageView.votedView setImage:[UIImage imageNamed:@"fullHeart"]forState:UIControlStateNormal];
}

- (void)download{
    self.alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Saved to camera roll!"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    
    [self.alert show];
    
    [self timedAlert];
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(self.masterImageView.image, nil, nil, nil);
    });
}
-(void)timedAlert
{
    
    [self performSelector:@selector(dismissAlert:) withObject:self.alert afterDelay:1.5];
}

-(void)dismissAlert:(UIAlertView *) alertView
{
    
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)animateFromCellinRect:(CGRect)rect {

    // Take the image out of the cell.
    [self.masterImageView removeFromSuperview];
    [self insertSubview:self.masterImageView belowSubview:self.likeView];
    self.masterImageView.frame = rect;
    
    // Take the label out of the cell.
    for (UIView* subview in self.masterImageView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            self.momentLabel = (UILabel *)subview;
        }
    }
    [self.momentLabel removeFromSuperview];
    [self insertSubview:self.momentLabel aboveSubview:self.likeView];
    self.momentLabel.frame = CGRectMake(kLabelHorizontalOffset,
                                        rect.origin.y + kLabelVerticalOffset,
                                        kLabelWidth,
                                        kLabelHeight);
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
        self.momentLabel.frame = CGRectMake(kLabelHorizontalOffset, kMomentLabelOffset, kLabelWidth, kLabelHeight);
        self.masterImageView.frame = CGRectMake(0, kImagePaneOffset, kImageSize, kImageSize);
        
    } completion:^(BOOL finished) {
        // Empty.
        
    }];
}

- (void)animateFromScratchWithLabel:(UILabel *)label {
    // Animate from off screen.
    self.momentLabel = label;
    self.momentLabel.frame = CGRectMake(kLabelHorizontalOffset, self.frame.size.height + kMomentLabelOffset,
                                        kLabelWidth, kLabelHeight);
    self.masterImageView.frame = CGRectMake(0, self.frame.size.height, kImageSize, kImageSize);
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
        self.momentLabel.frame = CGRectMake(kLabelHorizontalOffset, kMomentLabelOffset, kLabelWidth, kLabelHeight);
        self.masterImageView.frame = CGRectMake(0, kImagePaneOffset, kImageSize, kImageSize);

    } completion:^(BOOL finished) {
        // Empty.
        
    }];
}

- (void)swapImages:(UITapGestureRecognizer *)gesture {

    if (gesture.view == _masterImageView) {
        NSLog(@"master view click");
        return;
    }
    
    NSInteger removalIndex = [_imageViews indexOfObject:gesture.view];
    
    self.masterImageView.votedView.hidden=YES;
    
    IndexUIImageView *imageView = _imageViews[removalIndex];
    
    [_imageViews removeObjectAtIndex:removalIndex];
    int insertIndex = _masterImageView.sortIndex;
    if (insertIndex > removalIndex) {
        insertIndex--;
    }
    [_imageViews insertObject:_masterImageView atIndex:insertIndex];
    
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
        
        self.masterImageView.votedView.hidden=NO;
        
        [_imageViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
           
            NSNumber *tag1 = @([obj1 sortIndex]);
            NSNumber *tag2 = @([obj2 sortIndex]);
            
            return [tag1 compare:tag2];
        }];
        
        CGFloat currentX = 0;
        int thumbTop = (kScrollHeight / 2 - kThumbSize / 2);
        for (UIImageView *view in _imageViews) {
        
            view.frame = CGRectMake(currentX + kScrollMargin, thumbTop, kThumbSize, kThumbSize);
            currentX += kThumbSize + kScrollMargin;
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

@end
