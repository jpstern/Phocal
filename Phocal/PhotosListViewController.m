//
//  ViewController.m
//  TableView
//
//  Created by Abbey Ciolek on 4/1/14.
//  Copyright (c) 2014 Abbey Ciolek. All rights reserved.
//

#import "PhotosListViewController.h"

#import "MasterViewController.h"
#import "PhotosContainerView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIViewController+Master.h"
#import "MomentCell.h"
#import <CoreLocation/CoreLocation.h>

NSString* kImageBaseUrl = @"http://s3.amazonaws.com/Phocal/";

const int kImageOffsetFromTop = 0;
const int kImageOffsetFromBottom = 10;
const int kPhotoSize = 320;
const int kNavBarHeight = 64;

@interface PhotosListViewController () {
    
    BOOL justShowedTutorial;
}

@property (nonatomic, strong) NSMutableArray* photoURLs;
@property (nonatomic, assign) BOOL isShowingEmptyView;



@end

@implementation PhotosListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _photoURLs = [[NSMutableArray alloc] init];
    _isShowingEmptyView = NO;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshPhotos) forControlEvents:UIControlEventValueChanged];
    
    // Do our nav bar set up.
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    [self enableScroll];
    [self showListNavBar];
    self.title = @"My Moments";
    
    // Set up our table view style.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor lightGrayColor];

    [self refreshPhotos];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
}

- (void)enableScroll {
    [self.tableView setScrollEnabled:YES];
    [self.masterViewController enableScroll];
}

- (void)lockScroll {
    [self.masterViewController disableScroll];
    [self.tableView setScrollEnabled:NO];
}

- (void)showListNavBar {
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                  target:self
                                                  action:@selector(goToCamera)];
    
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)showMomentNavBarWithSelector:(SEL)sel {
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:sel];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
}

- (void)hideViewer {
    NSLog(@"HIDE THE VIEWER");
    //[self takeDownViewer:nil];
}

- (void)goToCamera
{
    [self.masterViewController displayCamera];
    
}

-(NSString *) URLEncodeString:(NSString *) str
{
    
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
    
    
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)refreshPhotos {
    NSLog(@"refresh");
    [self.refreshControl beginRefreshing];
    [_photoURLs removeAllObjects];
    
    [[PhocalCore sharedClient] getPhotos:^(NSArray * photos) {
        if (!photos) {
            NSLog(@"no photos");
            return;
        }
        for (NSDictionary* photoDict in photos) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:photoDict];
            [dict setObject:[[PhocalCore sharedClient] photoURLForId:photoDict[@"_id"]] forKey:@"URL"];
            [_photoURLs addObject:dict];
        }

        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [self updateViewForNewMoments];
    }];
}

- (void)updateViewForNewMoments {
    if (self.photoURLs.count == 0 && !self.isShowingEmptyView) {
        [self showNoPhotosView];
    } else if (self.photoURLs.count > 0 && self.isShowingEmptyView) {
        [self hideNoPhotosView];
    }
}

- (void)showNoPhotosView {
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    UILabel* noPhotosLabel = [[UILabel alloc] init];
    noPhotosLabel.numberOfLines = 0;
    noPhotosLabel.frame = CGRectMake(0, 100, self.tableView.frame.size.width, 100);
    noPhotosLabel.textAlignment = NSTextAlignmentCenter;
    noPhotosLabel.text = @"You don't have any Moments!\n\nSwipe left to take or upload a photo.";
    
    UIImageView* swipeButton = [[UIImageView alloc] initWithFrame:CGRectMake(200, 250, 75, 75)];
    [swipeButton setImage:[UIImage imageNamed:@"cameraButton"]];
    
    // Animate the button to swipe left.
    [UIView animateWithDuration:1.5 delay:0.0 usingSpringWithDamping:.75 initialSpringVelocity:.75 options:UIViewAnimationOptionRepeat animations:^{
        swipeButton.frame = CGRectMake(50, 250, 75, 75);
    } completion:^(BOOL finished) {
        // Empty.
    }];
    
    [self.tableView.backgroundView addSubview:swipeButton];
    [self.tableView.backgroundView addSubview:noPhotosLabel];
    
    self.isShowingEmptyView = YES;
}

- (void)hideNoPhotosView {
    for (UIView* subview in self.tableView.backgroundView.subviews) {
        [subview removeFromSuperview];
    }
    self.isShowingEmptyView = NO;
}

- (void)replaceSelectedPhotoWithPhoto:(IndexUIImageView *)photo {
    NSMutableDictionary* replacedPhotoDict = _photoURLs[self.selectedIndex];
    replacedPhotoDict[@"URL"] = photo.URL;
    replacedPhotoDict[@"lat"] = photo.lat;
    replacedPhotoDict[@"lng"] = photo.lng;
    replacedPhotoDict[@"didVote"] = (photo.voted) ? @(1) : @(0);
    replacedPhotoDict[@"_id"] = photo._id;
    replacedPhotoDict[@"label"] = photo.label;
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    BOOL showedTutorial = [def boolForKey:@"showedTutorial"];
    
    if (!showedTutorial) {
        
        [def setBool:YES forKey:@"showedTutorial"];
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"tutorialViewController"];
        
        [self.navigationController presentViewController:controller animated:YES completion:nil];
        justShowedTutorial = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (justShowedTutorial) {
        
        [self.masterViewController displayCamera];
        justShowedTutorial = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    MomentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell"];
    if (!cell) {
        cell = [[MomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MainCell"];
    }
    
    
    NSMutableDictionary* photoDict = _photoURLs[indexPath.row];
    cell.image.frame = CGRectMake(0, kImageOffsetFromTop, kPhotoSize, kPhotoSize);
    [cell.image setImageWithURL:[NSURL URLWithString:photoDict[@"URL"]]
               placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.image.URL = photoDict[@"URL"];
    cell.image.lat = photoDict[@"lat"];
    cell.image.lng = photoDict[@"lng"];
    cell.image.voted = [photoDict[@"didVote"] boolValue];
    cell.image._id = photoDict[@"_id"];
    cell.image.label = photoDict[@"label"];
    cell.label.text = photoDict[@"label"];

    
    // Fake 'em if we don't got 'em.
    if ([cell.image.lat isEqualToNumber:[NSNumber numberWithInt:0]]) {
        cell.image.lat = [NSNumber numberWithFloat:44.741802];
        cell.image.lng = [NSNumber numberWithFloat:-85.662872];
        photoDict[@"lat"] = [NSNumber numberWithFloat:44.741802];
        photoDict[@"lng"] = [NSNumber numberWithFloat:-85.662872];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    
    MomentCell *cell = (MomentCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.selectedCell = cell;

    CGRect oldRect = [tableView rectForRowAtIndexPath:indexPath];
    oldRect.origin.y += (kImageOffsetFromTop);
    oldRect.size.height -= (kImageOffsetFromTop + kImageOffsetFromBottom);
    CGRect newRect = [tableView convertRect:oldRect toView:self.masterViewController.view];
    newRect.origin.y -= kNavBarHeight; // take off the nav controller height
    self.selectedRect = newRect;
    
    [self displayPhotoFromCell:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kPhotoSize + kImageOffsetFromTop + kImageOffsetFromBottom;
}

- (void)displayPhotoFromCell:(MomentCell *)imageCell {
 
    CGRect frame = self.view.frame;
    self.photoDisplayView = [[PhotosContainerView alloc] initWithFrame:frame andImageView:imageCell.image];
    
    // Add the tap gesture for taking down the view.
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(takeDownViewerAndReplaceCell:)];
    [self.photoDisplayView addGestureRecognizer:tap];
    
    // Add the nav bar button.
    [self showMomentNavBarWithSelector:@selector(takeDownViewerAndReplaceCell:)];
    
    // Disable scrolling.
    [self lockScroll];
    
    [self.masterViewController addViewToTop:self.photoDisplayView];
    self.title = @"";
    [self.photoDisplayView animateFromCellinRect:self.selectedRect withCompletion:^{
        self.title = self.selectedCell.label.text;
    }];
}

- (void)addPhotoFromUpload:(NSDictionary *)photoMetadata {
    IndexUIImageView * newPhoto = [[IndexUIImageView alloc] init];
    newPhoto._id = photoMetadata[@"_id"];
    newPhoto.URL = [[PhocalCore sharedClient] photoURLForId:newPhoto._id];
    newPhoto.voted = [photoMetadata[@"didVote"] boolValue];
    newPhoto.lat = photoMetadata[@"lat"];
    newPhoto.lng = photoMetadata[@"lng"];
    newPhoto.label = photoMetadata[@"label"];
    [newPhoto setImageWithURL:[NSURL URLWithString:newPhoto.URL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    self.selectedCell = nil;
    
    CGRect frame = self.view.frame;
    self.photoDisplayView = [[PhotosContainerView alloc] initWithFrame:frame andImageView:newPhoto];
    
    // Add the tap gesture for taking down the view.
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(takeDownViewerAndAddCell:)];
    [self.photoDisplayView addGestureRecognizer:tap];
    
    // Add the nav bar button for taking down the view.
    [self showMomentNavBarWithSelector:@selector(takeDownViewerAndAddCell:)];
    
    // Disable scrolling.
    [self lockScroll];
    
    [self.masterViewController addViewToTop:self.photoDisplayView];
    [self.photoDisplayView animateFromScratchToCompletion:^{
        self.title = newPhoto.label;
        NSMutableDictionary* newPhotoDict = [NSMutableDictionary dictionaryWithDictionary:photoMetadata];
        newPhotoDict[@"URL"] = [[PhocalCore sharedClient] photoURLForId:newPhoto._id];
        [_photoURLs addObject:newPhotoDict];
        [self.tableView reloadData];
        [self updateViewForNewMoments];
    }];
}
- (void)removeGestureRecognizersFromView:(UIView *)view {
    for (UIGestureRecognizer* recognizer in view.gestureRecognizers) {
        [view removeGestureRecognizer:recognizer];
    }
}

- (void)takeDownViewerAndReplaceCell:(UITapGestureRecognizer *)gesture {
    [self removeGestureRecognizersFromView:self.photoDisplayView];
    [self.photoDisplayView.imageScroll removeFromSuperview];
    
    // Replace the photo and the label.
    IndexUIImageView* returnImage = self.photoDisplayView.imageViews[0];
    if (![self.photoDisplayView.masterImageView.URL isEqualToString:returnImage.URL]) {
        returnImage.alpha = 0.0;
    }
    [self removeGestureRecognizersFromView:returnImage];
    
    UILabel* returnLabel = self.photoDisplayView.momentLabel;
    [returnLabel setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.2]];
    [returnImage removeFromSuperview];
    returnImage.frame = CGRectMake(0, 64, kPhotoSize, kPhotoSize);
    
    [self.masterViewController.view addSubview:returnImage];
    [self.masterViewController.view addSubview:returnLabel];
    
    // Tell the table view the data source has changed.
    [self replaceSelectedPhotoWithPhoto:returnImage];
    
    self.title = @"";
    [self showListNavBar];
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.75 options:0 animations:^{
        returnLabel.frame =
            CGRectMake(kLabelHorizontalOffset, kLabelVerticalOffset + kNavBarHeight, kLabelWidth, kLabelHeight);
        self.photoDisplayView.masterImageView.alpha = 0.0;
        
        // If we aren't already looking at the image, animate its opacity.
        if (![self.photoDisplayView.masterImageView.URL isEqualToString:returnImage.URL]) {
            returnImage.alpha = 1.0;
        }
    } completion:^(BOOL finished) {
        self.title = @"My Moments";

        // Actually tear down the photo display view.
        [self.photoDisplayView removeFromSuperview];

        // Attach the label back to the actual image view.
        [returnLabel removeFromSuperview];
        returnLabel.frame = CGRectMake(kLabelHorizontalOffset, kLabelVerticalOffset, kLabelWidth, kLabelHeight);
        [returnImage addSubview:returnLabel];
        self.selectedCell.label = returnLabel;
        
        // Now animate the image back to its place.
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
            CGRect returnRect = self.selectedRect;
            returnRect.origin.y += kNavBarHeight;
            returnImage.frame = returnRect;
        } completion:^(BOOL finished) {
            [returnImage removeFromSuperview];
            [self.selectedCell.contentView addSubview:returnImage];
            self.selectedCell.image = returnImage;
            returnImage.frame = CGRectMake(0, kImageOffsetFromTop, kPhotoSize, kPhotoSize);
            
            // Re-enable scrolling.
            [self enableScroll];
        }];
    }];
}

- (void)takeDownViewerAndAddCell:(UITapGestureRecognizer *)gesture {
    [self removeGestureRecognizersFromView:self.photoDisplayView];
    [self.photoDisplayView.imageScroll removeFromSuperview];
    
    // Replace the photo and the label.
    IndexUIImageView* returnImage = self.photoDisplayView.imageViews[0];
    if (![self.photoDisplayView.masterImageView.URL isEqualToString:returnImage.URL]) {
        returnImage.alpha = 0.0;
    }
    [self removeGestureRecognizersFromView:returnImage];
    
    UILabel* returnLabel = self.photoDisplayView.momentLabel;
    [returnLabel setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.2]];
    [returnImage removeFromSuperview];
    returnImage.frame = CGRectMake(0, 64, kPhotoSize, kPhotoSize);
    
    [self.masterViewController.view addSubview:returnImage];
    [self.masterViewController.view addSubview:returnLabel];
    
    self.title = @"";
    [self showListNavBar];
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.75 options:0 animations:^{
        returnLabel.frame =
        CGRectMake(kLabelHorizontalOffset, kLabelVerticalOffset + kNavBarHeight, kLabelWidth, kLabelHeight);
        self.photoDisplayView.masterImageView.alpha = 0.0;
        
        // If we aren't already looking at the image, animate its opacity.
        if (![self.photoDisplayView.masterImageView.URL isEqualToString:returnImage.URL]) {
            returnImage.alpha = 1.0;
        }
    } completion:^(BOOL finished) {
        self.title = @"My Moments";
        
        // Actually tear down the view.
        [self.photoDisplayView removeFromSuperview];

        // Attach the label back to the actual image view.
        [returnLabel removeFromSuperview];
        returnLabel.frame = CGRectMake(kLabelHorizontalOffset, kLabelVerticalOffset, kLabelWidth, kLabelHeight);
        [returnImage addSubview:returnLabel];
        
        // Now animate the image and the label out.
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
            returnImage.frame = CGRectMake(0, 700, kPhotoSize, kPhotoSize);
        } completion:^(BOOL finished) {
            [returnImage removeFromSuperview];
            
            // Re-enable scrolling.
            [self enableScroll];
        }];
    }];

}


@end
