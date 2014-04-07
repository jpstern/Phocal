//
//  likeView.m
//  test
//
//  Created by Patrick Wilson on 4/6/14.
//  Copyright (c) 2014 Patrick Wilson. All rights reserved.
//

#import "likeView.h"

@implementation likeView

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
    [self.imgview setImage:[UIImage imageNamed:@"heart.png"]];
    [self addSubview:self.imgview];
    self.imgview.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    self.imgview.alpha = 0.0;
    
    return self;
}

- (void)handleLongPress:(UIView *)bang{
    if (self.gestreg.state==UIGestureRecognizerStateBegan){
        [self aMethod];
    }
    if (self.gestreg.state==UIGestureRecognizerStateEnded && ![self.status isEqual:@"moving"]) {
        self.imgview.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        self.imgview.alpha = 0.0;
    }
    
   
    
}

- (void)aMethod{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDidStopSelector:@selector(afterAnimationStops)];
    
    [self.imgview setAlpha:1.0];
    self.imgview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    
    [UIView commitAnimations];
    
}

-(void)afterAnimationStops{
    if (self.gestreg.state==UIGestureRecognizerStateBegan | self.gestreg.state==UIGestureRecognizerStateChanged) {
        NSLog(@"you got it");
        [self completeani];
        [self.target performSelector:self.selector];
        //Success
    }else{
        NSLog(@"not long enough");
        
        
        //Fail
    }
}

-(void)completeani{
    self.status=@"moving";
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finalstop)];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [self.imgview setAlpha:0.0];
    self.imgview.transform = CGAffineTransformMakeScale(10.0f, 10.0f);
    
    [UIView commitAnimations];
}
-(void)finalstop{
    self.imgview.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    self.imgview.alpha = 0.0;
    self.status=@"done";
}






@end
