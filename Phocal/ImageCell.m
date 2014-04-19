//
//  ImageCell.m
//  TableView
//
//  Created by Abbey Ciolek on 4/1/14.
//  Copyright (c) 2014 Abbey Ciolek. All rights reserved.
//

#import "LikeGestureView.h"
#import "ImageCell.h"

@implementation ImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)addPhotosWithFrame:(CGRect)rect AndPaths:(NSArray *)paths {
    
    [_container removeFromSuperview];
    _container = [[PhotosContainerView alloc] initWithFrame:rect andImagePaths:paths];
    [self.contentView addSubview:_container];
}

-(void) logButtonRow:(UIButton *) sender
{
}

- (void)awakeFromNib
{
    // Initialization code
}

/*- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}*/

@end
