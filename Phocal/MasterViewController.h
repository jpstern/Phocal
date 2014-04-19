//
//  MasterViewController.h
//  Phocal
//
//  Created by Josh Stern on 3/29/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageCell;
@class PhotosContainerView;

@interface MasterViewController : UIViewController <UIScrollViewDelegate>


@property (nonatomic, strong) IBOutlet UIScrollView *masterScroll;
@property (nonatomic, strong) PhotosContainerView* photoDisplayView;
@property (nonatomic, strong) ImageCell* selectedCell;
@property (nonatomic, assign) CGRect selectedRect;
@property (nonatomic, strong) UINavigationController* navController;

- (void)displayPhotoInCell:(ImageCell *)imageCell inRect:(CGRect)rect;

@end
