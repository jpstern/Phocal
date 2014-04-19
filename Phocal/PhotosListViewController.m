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
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
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
        NSMutableArray *urls = [[NSMutableArray alloc] init];
        for (NSDictionary* photoDict in photos) {
            NSMutableDictionary *dummy = [[NSMutableDictionary alloc] init];
            [dummy setObject:[NSString stringWithFormat:@"http://s3.amazonaws.com/Phocal/%@", photoDict[@"id"]] forKey:@"URL"];
            [urls addObject:dummy];
        }
        _photoURLs = urls;

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
    //ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell"];// forIndexPath:indexPath];
    if (!cell)
        
        //cell=[[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MainCell"];
        cell = [[MomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MainCell"];
    [cell.image setImageWithURL:[NSURL URLWithString:[_photoURLs[indexPath.row] objectForKey:@"URL"]]];
    //[cell addPhotosWithFrame:CGRectMake(0, 0, 320, 200) AndPaths:@[_photoURLs[indexPath.row]]];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    float latitude = 44.741802;
    float longitude = -85.662872;
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    CLGeocoder *test = [[CLGeocoder alloc] init];
    if ([_photoURLs[indexPath.row] objectForKey:@"first"]!=nil){
        cell.label.text = [_photoURLs[indexPath.row] objectForKey:@"first"];
        
    }else{
        [test reverseGeocodeLocation: location completionHandler: ^(NSArray *placemarks, NSError *error) {
            NSLog(@"%@",placemarks);
            CLPlacemark *placemark = placemarks[0];
            NSDictionary *dic = placemark.addressDictionary;
            NSArray *address = dic[@"FormattedAddressLines"];
            NSString *first = address[0];
            NSString *second = address[1];
            cell.label.text = first;
            [NSString stringWithFormat:@"%@ \n %@",first,second];
           
            [[_photoURLs objectAtIndex:indexPath.row] setObject:first forKey:@"first"];
            [[_photoURLs objectAtIndex:indexPath.row] setObject:second forKey:@"second"];

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
