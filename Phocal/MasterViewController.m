//
//  MasterViewController.m
//  Phocal
//
//  Created by Josh Stern on 3/29/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "MomentCell.h"
#import "MasterViewController.h"
#import "PhotosContainerView.h"
#import "PhotosListViewController.h"
#import "CameraViewController.h"
#import "DummyViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _masterScroll.contentSize = CGSizeMake(640, self.view.frame.size.height);
    _masterScroll.pagingEnabled = YES;
    _masterScroll.bounces = NO;
    _masterScroll.delegate = self;
    [_masterScroll setShowsHorizontalScrollIndicator:NO];
    
    
    UIView *viewControllerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    
    self.navController = [self.storyboard instantiateViewControllerWithIdentifier:@"navController"];
    self.navController.navigationBar.barTintColor = [UIColor colorWithRed:22/255.0 green:135/255.0 blue:182/255.0 alpha:1];
  
    [viewControllerView addSubview:self.navController.view];
    

    [_masterScroll addSubview:viewControllerView];
    
    [self addChildViewController:self.navController];
    
    UIView *cameraViewControllerView = [[UIView alloc] initWithFrame:CGRectMake(320, 0, 320, self.view.frame.size.height)];
    CameraViewController *camera = [[CameraViewController alloc] init];
    camera.master=self;
    [cameraViewControllerView addSubview:camera.view];
    [_masterScroll addSubview:cameraViewControllerView];
   
    [self addChildViewController:camera];
    
}

- (void)displayCamera {
    [_masterScroll setContentOffset:CGPointMake(320,0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    
//    if (page == 0 && pageRounded == 0) {
//        
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
//    }
//    else {
//        
//        [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    }
    
    if (page == 0) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    else {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

- (void)displayPhotoInCell:(MomentCell *)imageCell inRect:(CGRect)rect {
    NSLog(@"Display photo.");
    
    // Throw up a transparent sheet in between.
    /*[UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
        self.view.backgroundColor = [UIColor colorWithHue:300.0 saturation:0.1 brightness:0.5 alpha:.95];
    } completion:^(BOOL finished) {
        // Empty.
    }];*/
    
    self.selectedCell = imageCell;
    self.selectedRect = rect;
    self.photoDisplayView = [[PhotosContainerView alloc] initWithWindow:self.view.window
                                                           andImageView:imageCell.image
                                                                 inRect:rect];
    [self.view addSubview:self.photoDisplayView];
    
    UISwipeGestureRecognizer* swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(takeDownViewer:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self.photoDisplayView addGestureRecognizer:swipeUp];
    
    
    [_masterScroll setScrollEnabled:NO];
    [_masterScroll setUserInteractionEnabled:NO];
}

- (void)takeDownViewer:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        [self.photoDisplayView removeFromSuperview];
        for (UIGestureRecognizer* recognizer in self.photoDisplayView.gestureRecognizers) {
            [self.photoDisplayView removeGestureRecognizer:recognizer];
        }
        
        // Replace the photo and the label.
        IndexUIImageView* returnImage = self.photoDisplayView.masterImageView;
        UILabel* returnLabel = self.photoDisplayView.momentLabel;
        [_masterScroll addSubview:returnImage];
        [_masterScroll addSubview:returnLabel];
        
        // Tell the table view the data source has changed.
        [(PhotosListViewController *)self.navController.viewControllers[0] replaceSelectedPhotoWithPhoto:returnImage];
        
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.75 options:0 animations:^{
            returnImage.frame = CGRectMake(0, -50, self.selectedRect.size.width, self.selectedRect.size.height);
            returnLabel.frame = CGRectMake(0, -50 + kLabelOffset, returnLabel.frame.size.width, returnLabel.frame.size.height);
        } completion:^(BOOL finished) {
            // Attach the label back to the actual image view.
            [returnLabel removeFromSuperview];
            returnLabel.frame = CGRectMake(0, kLabelOffset, kPhotoSize, kLabelHeight);
            [returnImage addSubview:returnLabel];
            self.selectedCell.label = returnLabel;
            
            // Now animate the image back to it's place.
            [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
                returnImage.frame = self.selectedRect;
            } completion:^(BOOL finished) {
                [returnImage removeFromSuperview];
                [self.selectedCell.contentView addSubview:returnImage];
                self.selectedCell.image = returnImage;
                returnImage.frame = CGRectMake(0, kImageOffsetFromTop, kPhotoSize, kPhotoSize);
                
                //
                [[(PhotosListViewController *)self.navController.viewControllers[0] tableView] setScrollEnabled:YES];
                [_masterScroll setScrollEnabled:YES];
                [_masterScroll setUserInteractionEnabled:YES];
            }];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
