//
//  ImageCell.h
//  TableView
//
//  Created by Abbey Ciolek on 4/1/14.
//  Copyright (c) 2014 Abbey Ciolek. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotosContainer.h"

@interface ImageCell : UITableViewCell

@property (nonatomic, strong) PhotosContainer *container;
//@property (nonatomic,strong) UIImageView *imageView;

- (void)addPhotosWithFrame:(CGRect)rect AndPaths:(NSArray*)paths;

@end
