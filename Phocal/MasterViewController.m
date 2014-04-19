//
//  MasterViewController.m
//  Phocal
//
//  Created by Josh Stern on 3/29/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

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
    
    
    UIView *viewControllerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    //PhotosListViewController *viewController = [[PhotosListViewController alloc] initWithStyle:UITableViewStylePlain];
//    DummyViewController *viewController = [[DummyViewController alloc] init];
   
    
    //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
     self.navController = [self.storyboard instantiateViewControllerWithIdentifier:@"navController"];
    
    self.navController.navigationBar.barTintColor = [UIColor colorWithRed:164/255.0 green:242/255.0 blue:217/255.0 alpha:1];
  
    [viewControllerView addSubview:self.navController.view];
    

    [_masterScroll addSubview:viewControllerView];
    
    [self addChildViewController:self.navController];
    
    UIView *cameraViewControllerView = [[UIView alloc] initWithFrame:CGRectMake(320, 0, 320, self.view.frame.size.height)];
    CameraViewController *camera = [[CameraViewController alloc] init];
    
    [cameraViewControllerView addSubview:camera.view];
    [_masterScroll addSubview:cameraViewControllerView];
   
    [self addChildViewController:camera];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    if (page == 0) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    else {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)displayPhoto:(UIImageView *)imageView {
    NSLog(@"Display photo.");
    
    self.photoDisplayView = [[PhotosContainerView alloc] initWithFrame:self.view.window.frame
                                                                     andImageView:imageView];
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
        [_masterScroll setScrollEnabled:YES];
        [_masterScroll setUserInteractionEnabled:YES];
        
        [[(PhotosListViewController *)self.navController.viewControllers[0] tableView] setScrollEnabled:YES];
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
