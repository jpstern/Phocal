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

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        _photoURLs = [[NSMutableArray alloc] init];
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshPhotos) forControlEvents:UIControlEventValueChanged];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _idx=-1;
   // [self.tableView registerClass:[ImageCell class] forCellReuseIdentifier:@"CellID"];
    
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
      self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(Print_Message)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
      self.title = @"Photos";
      
    [self refreshPhotos];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
        
    }
    
}

- (void)Print_Message
{
    [[self.masterViewController masterScroll] setContentOffset:CGPointMake(320,0) animated:YES];
    
}

- (void)refreshPhotos {
    [self.refreshControl beginRefreshing];
    
    [[PhocalCore sharedClient] getPhotos:^(NSArray * photos) {
        if (!photos) {
            NSLog(@"no photos");
            return;
        }
        NSMutableArray *urls = [[NSMutableArray alloc] init];
        for (NSDictionary* photoDict in photos) {
            [urls addObject:[NSString stringWithFormat:@"http://s3.amazonaws.com/Phocal/%@", photoDict[@"id"]]];
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
    
    
    
    [cell.image setImageWithURL:[NSURL URLWithString:_photoURLs[indexPath.row]]];
    
    
    
    //[cell addPhotosWithFrame:CGRectMake(0, 0, 320, 200) AndPaths:@[_photoURLs[indexPath.row]]];
    
    
    
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    
    
    
    
    float latitude = 40.714224;
    
    float longitude = -73.961452;
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    
    CLGeocoder *test = [[CLGeocoder alloc] init];
    
    [test reverseGeocodeLocation: location completionHandler: ^(NSArray *placemarks, NSError *error) {
        
        //do something
        
        NSLog(@"%@",placemarks);
        
        CLPlacemark *placemark = placemarks[0];
        
        NSDictionary *dic = placemark.addressDictionary;
        
        NSArray *address = dic[@"FormattedAddressLines"];
        
        NSString *first = address[0];
        
        NSString *second = address[1];
        
        cell.label.text = first;
        
        cell.label2.text = second;
        
        
        
        
        
    }];
    
    
    return cell;
    
}




/*- (void)cellTapped:(UITapGestureRecognizer*)tap {
    
    NSInteger row = tap.view.tag;

    NSLog(@"tapped");
    
    ImageCell *cell = (ImageCell *)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    
//    [self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
    
    //Newly Selected Cell
    if(_idx!=row)
    {
        _idx=row;
        
        CGRect screenRect = [[UIScreen mainScreen]bounds];
        CGFloat screenHeight = screenRect.size.height;
        
        [cell.container cellDidGrowToHeight:screenHeight];
    }
    //Cell Already Selected Once
    else
    {
        _idx=-1;
        
        [cell.container cellDidShrink];
    }
    
//
//
    [self.tableView beginUpdates];
    NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.tableView endUpdates];
}*/

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    NSInteger index = _idx;
//    
//    _idx = -1;
//    
//    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSInteger row = tap.view.tag;
    
      [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MomentCell *cell = (MomentCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.tableView.scrollEnabled = NO;
    [self.masterViewController displayPhoto:cell.image];

    //    [self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
    
    //Newly Selected Cell
    /*if(_idx!=indexPath.row)
    {
        _idx=indexPath.row;
        
        [cell.container cellDidGrowToHeight:300];
    }
    //Cell Already Selected Once
    else
    {
        _idx=-1;
        
        [cell.container cellDidShrink];
    }
    
    //
    //
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.tableView endUpdates];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [cell setSelected:NO];*/
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*if(_idx!=-1 && indexPath.row==_idx)
    {
        
        CGRect screenRect = [[UIScreen mainScreen]bounds];
        CGFloat screenHeight = screenRect.size.height;
        return 300.0;
    }*/
    
    return 320.0;
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
