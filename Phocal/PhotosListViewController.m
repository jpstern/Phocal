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

@interface PhotosListViewController ()

@property (nonatomic, strong) NSMutableArray* photoURLs;

@end

@implementation PhotosListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _photoURLs = [[NSMutableArray alloc] init];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshPhotos) forControlEvents:UIControlEventValueChanged];
    
	// Do any additional setup after loading the view, typically from a nib.
    _idx=-1;
   // [self.tableView registerClass:[ImageCell class] forCellReuseIdentifier:@"CellID"];
    
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
      self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(goToCamera)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
      self.title = @"My Moments";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self refreshPhotos];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
        
    }
}

-(NSString *) URLEncodeString:(NSString *) str
{
    
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
    
    
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)goToCamera
{
    [[self.masterViewController masterScroll] setContentOffset:CGPointMake(320,0) animated:YES];
    
}

- (void)refreshPhotos {
    NSLog(@"refresh");
    [self.refreshControl beginRefreshing];
    
    [[PhocalCore sharedClient] getPhotos:^(NSArray * photos) {
        if (!photos) {
            NSLog(@"no photos");
            return;
        }
        for (NSDictionary* photoDict in photos) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSString stringWithFormat:@"http://s3.amazonaws.com/Phocal/%@", photoDict[@"_id"]]
                      forKey:@"URL"];
            [dict setObject:[NSNumber numberWithDouble:[photoDict[@"lat"] doubleValue]] forKey:@"lat"];
            [dict setObject:[NSNumber numberWithDouble:[photoDict[@"lng"] doubleValue]] forKey:@"lng"];
            [_photoURLs addObject:dict];
        }

        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
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
    
    NSDictionary* photoDict = _photoURLs[indexPath.row];
    [cell.image setImageWithURL:[NSURL URLWithString:photoDict[@"URL"]]
               placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.image.lat = photoDict[@"lat"];
    cell.image.lng = photoDict[@"lng"];
    
    // Fake 'em if we don't got 'em.
    if ([cell.image.lat floatValue] == 0.0f) {
        cell.image.lat = [NSNumber numberWithFloat:44.741802];
        cell.image.lng = [NSNumber numberWithFloat:-85.662872];
    }

    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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


//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    NSInteger index = _idx;
//    
//    _idx = -1;
//    
//    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MomentCell *cell = (MomentCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.tableView.scrollEnabled = NO;

    CGRect oldRect = [tableView rectForRowAtIndexPath:indexPath];
    //CGFloat labelHeight = (cell.label.frame.size.height + cell.label2.frame.size.height);
    //oldRect.size.height -= labelHeight;
    //oldRect.origin.y += labelHeight;
    CGRect newRect = [tableView convertRect:oldRect toView:self.masterViewController.view];
    //newRect.size.height -= 60;
    [self.masterViewController displayPhotoInCell:cell inRect:newRect];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*if(_idx!=-1 && indexPath.row==_idx)
    {
        
        CGRect screenRect = [[UIScreen mainScreen]bounds];
        CGFloat screenHeight = screenRect.size.height;
        return 300.0;
    }*/
    
    return 320;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(ImageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_idx == indexPath.row) {
        
//        _idx = -1;
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
//    else if(_idx!=-1&&indexPath.row==_idx)
//    {
//        [tableView scrollToRowAtIndexPath:indexPath
//                         atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        
////        [cell.container cellDidGrowToHeight:300];
//    }
}


@end
