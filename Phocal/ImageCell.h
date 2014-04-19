//
//  ImageCell.h
//  TableView
//
//  Created by Abbey Ciolek on 4/1/14.
//  Copyright (c) 2014 Abbey Ciolek. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotosContainerView.h"

@interface ImageCell : UITableViewCell

@property (nonatomic, strong) PhotosContainerView *container;

- (void)addPhotosWithFrame:(CGRect)rect AndPaths:(NSArray*)paths;

@end
