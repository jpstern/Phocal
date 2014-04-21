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
    
    NSMutableDictionary* photoDict = _photoURLs[indexPath.row];
    cell.image.frame = CGRectMake(0, kImageOffsetFromTop, kPhotoSize, kPhotoSize);
    [cell.image setImageWithURL:[NSURL URLWithString:photoDict[@"URL"]]
               placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.image.URL = photoDict[@"URL"];
    cell.image.lat = photoDict[@"lat"];
    cell.image.lng = photoDict[@"lng"];
    cell.image.voted = [photoDict[@"didVote"] boolValue];
    
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
    [cell.label setBackgroundColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.6]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    
    MomentCell *cell = (MomentCell *)[tableView cellForRowAtIndexPath:indexPath];

    CGRect oldRect = [tableView rectForRowAtIndexPath:indexPath];
    oldRect.origin.y += (kImageOffsetFromTop);
    oldRect.size.height -= (kImageOffsetFromTop + kImageOffsetFromBottom);
    CGRect newRect = [tableView convertRect:oldRect toView:self.masterViewController.view];
    
    self.tableView.scrollEnabled = NO;
    [self.masterViewController displayPhotoFromCell:cell inRect:newRect];

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

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(ImageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (_idx == indexPath.row) {
        
//        _idx = -1;
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    //}
//    else if(_idx!=-1&&indexPath.row==_idx)
//    {
//        [tableView scrollToRowAtIndexPath:indexPath
//                         atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        
////        [cell.container cellDidGrowToHeight:300];
//    }
}


@end
