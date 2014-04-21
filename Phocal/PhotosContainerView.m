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
const int kMomentLabelOffset = 20;
const int kImageSize = 320;
const int kScrollMargin = 15;
const int kThumbSize = 80;

@interface PhotosContainerView ()

@property (nonatomic, retain) UIGestureRecognizer* tapRecognizer;

@end

@implementation PhotosContainerView

- (id)initWithFrame:(CGRect)frame andImageView:(IndexUIImageView *)imageView {

    self = [super initWithFrame:frame];
    
    if (self) {
        self.frame = frame;
        
        // Set our main image view.
        self.masterImageView = imageView;
        self.masterImageView.index = 0;
        
        _masterImageView.votedView.hidden = NO;
        
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
           self.backgroundColor = [UIColor colorWithHue:300.0 saturation:0.1 brightness:0.5 alpha:.95];
         } completion:^(BOOL finished) {
         // Empty.
         }];
        
        _imageViews = [[NSMutableArray alloc] init];
        _likeView = [[LikeGestureView alloc] initWithFrame:CGRectMake(0, 0, kImageSize, kImageSize)];
        [_likeView setUserInteractionEnabled:YES];

        //_likeView.currectImgView=imageView;
        _likeView.target = self;
        _likeView.selector = @selector(voted);
        
        // Add the scroll view.
        int scrollTop = (((frame.size.height - kImageSize) / 2) + kImageSize) - (kScrollHeight / 2);
        _imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollTop, kImageSize, kScrollHeight)];
        _imageScroll.delegate = self;
        _imageScroll.contentSize = CGSizeMake(0, kScrollHeight);
        [_imageScroll setShowsHorizontalScrollIndicator:NO];
        [_imageScroll setShowsVerticalScrollIndicator:NO];
        
        // Add the download button.
        UIButton *download = [UIButton buttonWithType:UIButtonTypeCustom];
        download.frame = CGRectMake(15, 275, 30, 30);
        //test.center = CGPointMake(_listButton.center.x, _bottomContainer.frame.size.height / 2);
        [download setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        [download addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
        
        // Add the heart button.
        _voteHeart = [UIButton buttonWithType:UIButtonTypeCustom];
        _voteHeart.frame= CGRectMake(270, 270, 30, 30);
        [_voteHeart addTarget:self action:@selector(voted) forControlEvents:UIControlEventTouchUpInside];
        [self updateVoteViewForImage:self.masterImageView];
        
        // Add the swipe gesture recognizers.
        UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(swipeRight:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(swipeLeft:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_likeView addGestureRecognizer:swipeRight];
        [_likeView addGestureRecognizer:swipeLeft];
        
        // Add the views in order.
        [self addSubview:_likeView];
        //[self addSubview:_swipeGestureView];
        [self addSubview:_imageScroll];
        [self addSubview:download];
        [self addSubview:_voteHeart];
        
        // Fetch the nearest photos.
        [self getClosestPhotos];
        
        if (_masterImageView.voted) {
            
            [_masterImageView.votedView setImage:[UIImage imageNamed:@"fullHeart"] forState:UIControlStateNormal];
        }
    }
    
    return self;
}

- (IndexUIImageView *)createAndAddThumbWithURL:(NSString *)thumbURL atIndex:(NSInteger)index {
    int thumbTop = (kScrollHeight / 2 - kThumbSize / 2);

    IndexUIImageView* thumb = [[IndexUIImageView alloc] initWithFrame:
                               CGRectMake(kScrollMargin + index*kThumbSize + index*kScrollMargin,
                                          thumbTop,
                                          kThumbSize,
                                          kThumbSize)];
    
    thumb.index = index;
    thumb.userInteractionEnabled = YES;
    [thumb addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(swapImages:)]];
    thumb.contentMode = UIViewContentModeScaleAspectFill;
    
    [thumb setImageWithURL:[NSURL URLWithString:thumbURL]
          placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    // Add the image to the scroll view and our image views array.
    [_imageScroll addSubview:thumb];
    _imageScroll.contentSize = CGSizeMake(_imageScroll.contentSize.width + kScrollMargin + kThumbSize,
                                          kScrollHeight);
    [_imageViews addObject:thumb];

    return thumb;
}

- (void)getClosestPhotos {
    // Add a thumb of the main picture right away.
    IndexUIImageView* mainThumb = [self createAndAddThumbWithURL:self.masterImageView.URL atIndex:0];
    mainThumb.voted = self.masterImageView.voted;
    mainThumb.lat = self.masterImageView.lat;
    mainThumb.lng = self.masterImageView.lng;
    mainThumb._id = self.masterImageView._id;
    mainThumb.label = self.masterImageView.label;
    mainThumb.URL = self.masterImageView.URL;
    
    // Fetch the closest photos to this one.
    [[PhocalCore sharedClient] getClosestPhotosForLat:self.masterImageView.lat andLng:self.masterImageView.lng completion:^(NSArray * photos) {
        if (!photos) {
            return;
        }
        
        NSLog(@"Got %lu closest photos", (unsigned long)photos.count);
        int index = 1;
        for (NSDictionary* photoDict in photos) {
            // If this photo is the one we're currently looking at, don't add it again.
            NSString* newPhotoURL = [[PhocalCore sharedClient] photoURLForId:photoDict[@"_id"]];
            if ([newPhotoURL isEqualToString:self.masterImageView.URL]) {
                continue;
            }
            
            IndexUIImageView* thumb = [self createAndAddThumbWithURL:newPhotoURL atIndex:index];
            // Set the image properties.
            thumb.lat = photoDict[@"lat"];
            thumb.lng = photoDict[@"lng"];
            thumb.voted = [photoDict[@"didVote"] boolValue];
            thumb._id = photoDict[@"_id"];
            thumb.URL = newPhotoURL;
            thumb.label = photoDict[@"label"];
            
            index++;
        }
        
        // Add a margin to the right side of the scroll.
        _imageScroll.contentSize = CGSizeMake(_imageScroll.contentSize.width + kScrollMargin, kScrollHeight);
    }];
}

- (void)updateVoteViewForImage:(IndexUIImageView *)view {
    if (view.voted) {
        [self.voteHeart setImage:[UIImage imageNamed:@"fullHeart"] forState:UIControlStateNormal];
    } else {
        [self.voteHeart setImage:[UIImage imageNamed:@"emptyHeart"] forState:UIControlStateNormal];
    }
}

- (void)voted
{
    [self.voteHeart setImage:[UIImage imageNamed:@"fullHeart"]forState:UIControlStateNormal];

    [[PhocalCore sharedClient] likePhotoForID:_masterImageView._id];
    NSLog(@"Voted");
    
    // Update the main image view and the thumb.
    _masterImageView.voted = YES;
    
    for (IndexUIImageView* thumb in self.imageViews) {
        if ([thumb.URL isEqualToString:_masterImageView.URL]) {
            thumb.voted = YES;
        }
    }
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

- (void)animateFromCellinRect:(CGRect)rect withCompletion:(void (^)())completion {

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
        self.momentLabel.frame = CGRectMake(kLabelHorizontalOffset, -37, kLabelWidth, kLabelHeight);
        self.momentLabel.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.0];
        self.masterImageView.frame = CGRectMake(0, 0, kImageSize, kImageSize);
        
    } completion:^(BOOL finished) {
        // Empty.
        completion();
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
        self.masterImageView.frame = CGRectMake(0, 0, kImageSize, kImageSize);

    } completion:^(BOOL finished) {
        // Empty.
        
    }];
}

- (void)swipeRight:(UISwipeGestureRecognizer *)gesture {
    NSLog(@"swipe right");
    if (self.masterImageView.index == 0) {
        return;
    }
    
    IndexUIImageView* nextImage = [self.imageViews objectAtIndex:self.masterImageView.index - 1];
    IndexUIImageView* bigNextImage = [nextImage copy];
    bigNextImage.frame = CGRectMake(-320, 0, kImageSize, kImageSize);
    [bigNextImage setImageWithURL:[NSURL URLWithString:nextImage.URL]
                 placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    [self insertSubview:bigNextImage belowSubview:self.likeView];
    [self.likeView setUserInteractionEnabled:NO];
    [self updateVoteViewForImage:bigNextImage];
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
        self.masterImageView.frame = CGRectMake(640, 0, kImageSize, kImageSize);
        bigNextImage.frame = CGRectMake(0, 0, kImageSize, kImageSize);
    } completion:^(BOOL finished) {
        [self.masterImageView removeFromSuperview];
        self.masterImageView = bigNextImage;
        [self.likeView setUserInteractionEnabled:YES];
    }];
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)gesture {
    NSLog(@"swipe left");
    if (self.masterImageView.index == (self.imageViews.count - 1)) {
        return;
    }
    
    IndexUIImageView* nextImage = [self.imageViews objectAtIndex:self.masterImageView.index + 1];
    IndexUIImageView* bigNextImage = [nextImage copy];
    bigNextImage.frame = CGRectMake(320, 0, kImageSize, kImageSize);
    [bigNextImage setImageWithURL:[NSURL URLWithString:nextImage.URL]
                 placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    [self insertSubview:bigNextImage belowSubview:self.likeView];
    [self.likeView setUserInteractionEnabled:NO];
    [self updateVoteViewForImage:bigNextImage];
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
        self.masterImageView.frame = CGRectMake(-320, 0, kImageSize, kImageSize);
        bigNextImage.frame = CGRectMake(0, 0, kImageSize, kImageSize);
    } completion:^(BOOL finished) {
        [self.masterImageView removeFromSuperview];
        self.masterImageView = bigNextImage;
        [self.likeView setUserInteractionEnabled:YES];
    }];
}

- (void)swapImages:(UITapGestureRecognizer *)gesture {

    if (gesture.view == _masterImageView) {
        NSLog(@"master view click");
        return;
    }
    
    if (![gesture.view isKindOfClass:[IndexUIImageView class]]) {
        NSLog(@"click didn't come from thumb!");
        return;
    }
    
    IndexUIImageView* imageView = (IndexUIImageView *)gesture.view;
    
    self.masterImageView.votedView.hidden=YES;
    
    IndexUIImageView* newMaster = [imageView copy];
    newMaster.frame = self.masterImageView.frame;
    [newMaster setImageWithURL:[NSURL URLWithString:newMaster.URL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    newMaster.alpha = 0.0;
    [self insertSubview:newMaster belowSubview:self.likeView];
    
    [self.likeView setUserInteractionEnabled:NO];
    [self updateVoteViewForImage:newMaster];
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
        self.masterImageView.alpha = 0.0;
        newMaster.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.masterImageView removeFromSuperview];
        self.masterImageView = newMaster;
        [self.likeView setUserInteractionEnabled:YES];
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
