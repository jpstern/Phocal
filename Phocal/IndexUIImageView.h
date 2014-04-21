//
//  IndexUIImageView.h
//  Phocal
//
//  Created by Josh Stern on 4/6/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexUIImageView : UIImageView

@property (nonatomic, assign) NSInteger sortIndex;
@property (nonatomic, retain) NSNumber* lat;
@property (nonatomic, retain) NSNumber* lng;
@property (nonatomic, retain) NSString* URL;
@property (nonatomic, assign) BOOL voted;
@property (nonatomic, strong) UIButton *votedView;

@end
