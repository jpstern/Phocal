//
//  likeView.m
//  test
//
//  Created by Patrick Wilson on 4/6/14.
//  Copyright (c) 2014 Patrick Wilson. All rights reserved.
//

#import "LikeGestureView.h"

@implementation LikeGestureView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.gestreg= [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    [self.gestreg setAllowableMovement:50.0];
    
    self.gestreg.numberOfTouchesRequired = 1;
    self.gestreg.minimumPressDuration = 0.2;
    [self addGestureRecognizer:self.gestreg];
    self.status = @"init";
    self.imgview = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-50, self.frame.size.height/2-50, 100, 100)];
    [self.imgview setImage:[UIImage imageNamed:@"fullHeart"]];
    [self addSubview:self.imgview];
    [self hideHeart];
    
    return self;
}

- (void)handleLongPress:(UIView *)bang {
    if (self.gestreg.state==UIGestureRecognizerStateBegan) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.4];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDidStopSelector:@selector(afterAnimationStops)];
        
        [self.imgview setAlpha:1.0];
        self.imgview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
        [UIView commitAnimations];
        
        NSLog(@"BEGIN");
    }

    CGPoint coords = [self.gestreg locationInView:self];
    [self.imgview setFrame:CGRectMake(coords.x-50, coords.y-50, 100, 100)];
    
    if (self.gestreg.state==UIGestureRecognizerStateEnded && ![self.status isEqual:@"moving"]) {
        [self hideHeart];
    }
}

- (void)afterAnimationStops {
    NSLog(@"STATE: %ld", self.gestreg.state);
    
    if (self.gestreg.state==UIGestureRecognizerStateCancelled ) {
        [self hideHeart];
        return;
    }
    
    self.status=@"moving";
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideHeart)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self.imgview setAlpha:0.0];
    self.imgview.transform = CGAffineTransformMakeScale(4.0f, 4.0f);
    
    [UIView commitAnimations];
    
    [self.target performSelector:self.selector];
    
}

- (void)hideHeart {
    self.imgview.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
    self.imgview.alpha = 0.0;
    self.status=@"done";
}



@end
