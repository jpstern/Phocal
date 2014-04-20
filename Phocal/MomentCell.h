//
//  MomentCell.h
//  Phocal
//
//  Created by Patrick Wilson on 4/19/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const int kLabelOffset;
extern const int kLabelHeight;


@class IndexUIImageView;

@interface MomentCell : UITableViewCell
@property (nonatomic,strong) IndexUIImageView *image;
@property (nonatomic,strong) UILabel *label;


@end
