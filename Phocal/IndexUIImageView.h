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
@property (nonatomic, assign) NSNumber* lat;
@property (nonatomic, assign) NSNumber* lng;
@property (nonatomic, retain) NSString* URL;

@end
