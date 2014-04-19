//
//  MasterViewController.m
//  Phocal
//
//  Created by Josh Stern on 3/29/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "MasterViewController.h"
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
     UINavigationController *navViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"navController"];
    
    navViewController.navigationBar.barTintColor = [UIColor colorWithRed:164/255.0 green:242/255.0 blue:217/255.0 alpha:1];
  
    
    PhotosListViewController* pc = (PhotosListViewController*)[navViewController viewControllers][0];
    
    pc.master= self;
    
    
    [viewControllerView addSubview:navViewController.view];
    

    [_masterScroll addSubview:viewControllerView];
   
    
    
    [self addChildViewController:navViewController];
  
    
    
    UIView *cameraViewControllerView = [[UIView alloc] initWithFrame:CGRectMake(320, 0, 320, self.view.frame.size.height)];
    CameraViewController *camera = [[CameraViewController alloc] init];
    
    camera.master=self;
    
    [cameraViewControllerView addSubview:camera.view];
    [_masterScroll addSubview:cameraViewControllerView];
   
    [self addChildViewController:camera];

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
    CGFloat width = scrollView.frame.size.width;
    NSInteger pageRounded = (scrollView.contentOffset.x + (0.5f * width)) / width;
    
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    
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
