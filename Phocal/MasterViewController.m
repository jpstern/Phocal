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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
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

- (void)addViewToTop:(UIView *)view {
    [self disableScroll];
    [self.view addSubview:view];
}

- (void)disableScroll {
    [_masterScroll setScrollEnabled:NO];
    [_masterScroll setUserInteractionEnabled:NO];
}
- (void)enableScroll {
    [_masterScroll setScrollEnabled:YES];
    [_masterScroll setUserInteractionEnabled:YES];
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
