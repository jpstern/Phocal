//
//  MasterViewController.h
//  Phocal
//
//  Created by Josh Stern on 3/29/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UIViewController <UIScrollViewDelegate>


@property (nonatomic, strong) IBOutlet UIScrollView *masterScroll;
@property (nonatomic, strong) UIView* photoDisplayView;
@property (nonatomic, strong) UINavigationController* navController;

- (void)displayPhoto:(UIImageView *)imageView;

@end
