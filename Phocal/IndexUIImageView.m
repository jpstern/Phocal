//
//  IndexUIImageView.m
//  Phocal
//
//  Created by Josh Stern on 4/6/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "IndexUIImageView.h"

#import <QuartzCore/QuartzCore.h>

@implementation IndexUIImageView

- (id)init {
    self = [super init];
    if (self) {
        [self addBorderAndShadow];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addBorderAndShadow];
    }
    return self;
}

- (void)addBorderAndShadow {
    [self.layer setBorderColor:[[UIColor colorWithWhite:1.0 alpha:.95] CGColor]];
    [self.layer setBorderWidth:5.0];
    [self.layer setShadowRadius:3.0];
    [self.layer setShadowOffset:CGSizeMake(0.0, 3.0)];
    [self.layer setShadowOpacity:1.0];
    
    self.clipsToBounds = NO;
}

@end
