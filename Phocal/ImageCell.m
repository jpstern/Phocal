//
//  ImageCell.m
//  TableView
//
//  Created by Abbey Ciolek on 4/1/14.
//  Copyright (c) 2014 Abbey Ciolek. All rights reserved.
//

#import "LikeGestureView.h"
#import "ImageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
        _photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)addPhotosWithFrame:(CGRect)rect AndPaths:(NSArray *)paths {
    
    //[_container removeFromSuperview];
    //_container = [[PhotosContainerView alloc] initWithFrame:rect andImagePaths:paths];
    //[self.contentView addSubview:_container];
}

- (void)setPhotoURL:(NSString *)url {
    
    [self.photoView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    //[self addSubview:self.photoView];
    [self.contentView addSubview:_photoView];
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
