//
//  ViewController.m
//  TableView
//
//  Created by Abbey Ciolek on 4/1/14.
//  Copyright (c) 2014 Abbey Ciolek. All rights reserved.
//

#import "PhotosListViewController.h"

#import "ImageCell.h"
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
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                  target:self
                                                  action:@selector(goToCamera)];
    
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
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
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[[PhocalCore sharedClient] photoURLForId:photoDict[@"_id"]] forKey:@"URL"];
            [dict setObject:[NSNumber numberWithDouble:[photoDict[@"lat"] doubleValue]] forKey:@"lat"];
            [dict setObject:[NSNumber numberWithDouble:[photoDict[@"lng"] doubleValue]] forKey:@"lng"];
            dict[@"_id"] = photoDict[@"_id"];
            dict[@"didVote"] = photoDict[@"didVote"];
            [_photoURLs addObject:dict];
        }

        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        
        if (photos.count == 0 && !self.isShowingEmptyView) {
            [self showNoPhotosView];
        } else if (photos.count > 0 && self.isShowingEmptyView) {
            [self hideNoPhotosView];
        }
    }];
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
    
    // Configure the cell.
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    [cell.label setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.6]];
    
    NSMutableDictionary* photoDict = _photoURLs[indexPath.row];
    cell.image.frame = CGRectMake(0, kImageOffsetFromTop, kPhotoSize, kPhotoSize);
    [cell.image setImageWithURL:[NSURL URLWithString:photoDict[@"URL"]]
               placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.image.URL = photoDict[@"URL"];
    cell.image.lat = photoDict[@"lat"];
    cell.image.lng = photoDict[@"lng"];
    cell.image.voted = [photoDict[@"didVote"] boolValue];
    cell.image._id = photoDict[@"_id"];
    
    // Fake 'em if we don't got 'em.
    if ([cell.image.lat isEqualToNumber:[NSNumber numberWithInt:0]]) {
        cell.image.lat = [NSNumber numberWithFloat:44.741802];
        cell.image.lng = [NSNumber numberWithFloat:-85.662872];
        photoDict[@"lat"] = [NSNumber numberWithFloat:44.741802];
        photoDict[@"lng"] = [NSNumber numberWithFloat:-85.662872];
    }

    // If we've already fetched the label for this geopoint, don't fetch it again.
    if ([_photoURLs[indexPath.row] objectForKey:@"label"]!=nil){
        cell.label.text = [_photoURLs[indexPath.row] objectForKey:@"label"];
        
    } else {
        // Set the placeholder while we asynchronously fetch the label.
        cell.label.text = @"Getting location...";
        [[PhocalCore sharedClient] getLocationLabelForLat:cell.image.lat
                                                   andLng:cell.image.lng
                                               completion:^(NSDictionary *dict) {
            if (!dict) {
                return;
            }
               
            NSString* bestGuessLabel = dict[@"results"][0][@"name"];
            [_photoURLs[indexPath.row] setObject:bestGuessLabel forKey:@"label"];
            cell.label.text = bestGuessLabel;
        }];
        
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
    CGRect newRect = [tableView convertRect:oldRect toView:self.view];
    self.selectedRect = newRect;
    
    [self displayPhotoFromCell:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*if(_idx!=-1 && indexPath.row==_idx)
    {
        
        CGRect screenRect = [[UIScreen mainScreen]bounds];
        CGFloat screenHeight = screenRect.size.height;
        return 300.0;
    }*/
    
    return kPhotoSize + kImageOffsetFromTop + kImageOffsetFromBottom;
}

- (void)displayPhotoFromCell:(MomentCell *)imageCell {
 
    CGRect frame = self.view.frame;
    self.photoDisplayView = [[PhotosContainerView alloc] initWithFrame:frame andImageView:imageCell.image];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(takeDownViewer:)];
    [self.photoDisplayView addGestureRecognizer:tap];
    
    [self.masterViewController disableScroll];
    [self.tableView setScrollEnabled:NO];
    
    [self.masterViewController addViewToTop:self.photoDisplayView];
    self.title = @"";
    [self.photoDisplayView animateFromCellinRect:self.selectedRect withCompletion:^{
        self.title = self.selectedCell.label.text;
    }];
}

- (void)displayPhotoFromUpload:(IndexUIImageView *)photo {
    self.selectedCell = nil;
    
    CGRect frame = self.view.frame;
    //frame.origin.y = 0;
    self.photoDisplayView = [[PhotosContainerView alloc] initWithFrame:frame andImageView:photo];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(takeDownViewer:)];
    [self.photoDisplayView addGestureRecognizer:tap];
    
    // This is a test label.
    UILabel* label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Fake Label";
    
    [self.masterViewController addViewToTop:self.photoDisplayView];
    [self.photoDisplayView animateFromScratchWithLabel:label];
}

- (void)takeDownViewer:(UITapGestureRecognizer *)gesture {
    [self.photoDisplayView removeFromSuperview];
    for (UIGestureRecognizer* recognizer in self.photoDisplayView.gestureRecognizers) {
        [self.photoDisplayView removeGestureRecognizer:recognizer];
    }
    
    // Replace the photo and the label.
    IndexUIImageView* returnImage = self.photoDisplayView.masterImageView;
    returnImage.votedView.hidden=YES;
    UILabel* returnLabel = self.photoDisplayView.momentLabel;
    [returnLabel setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.6]];

    [self.view addSubview:returnImage];
    [self.view addSubview:returnLabel];
    
    // Tell the table view the data source has changed.
    [self replaceSelectedPhotoWithPhoto:returnImage];
    
    self.title = @"";
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.75 options:0 animations:^{
        returnImage.frame = CGRectMake(0, 0, self.selectedRect.size.width, self.selectedRect.size.height);
        returnLabel.frame = CGRectMake(kLabelHorizontalOffset, kLabelVerticalOffset, returnLabel.frame.size.width, returnLabel.frame.size.height);
    } completion:^(BOOL finished) {
        // Attach the label back to the actual image view.
        [returnLabel removeFromSuperview];
        returnLabel.frame = CGRectMake(returnLabel.frame.origin.x, kLabelVerticalOffset, kLabelWidth, kLabelHeight);
        [returnImage addSubview:returnLabel];
        self.selectedCell.label = returnLabel;
        
        // Now animate the image back to its place.
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.75 options:0 animations:^{
            returnImage.frame = self.selectedRect;
        } completion:^(BOOL finished) {
            [returnImage removeFromSuperview];
            [self.selectedCell.contentView addSubview:returnImage];
            self.selectedCell.image = returnImage;
            returnImage.frame = CGRectMake(0, kImageOffsetFromTop, kPhotoSize, kPhotoSize);
            
            // Re-enable scrolling.
            [self.tableView setScrollEnabled:YES];
            [self.masterViewController enableScroll];
            
            self.title = @"My Moments";
        }];
    }];
}


@end
