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
    
    float latitude = 44.741802;
    float longitude = -85.662872;
    
    
    
    
    
 

    
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
        NSMutableArray *urls = [[NSMutableArray alloc] init];
        for (NSDictionary* photoDict in photos) {
            NSMutableDictionary *dummy = [[NSMutableDictionary alloc] init];
            [dummy setObject:[NSString stringWithFormat:@"http://s3.amazonaws.com/Phocal/%@", photoDict[@"_id"]]
                      forKey:@"URL"];
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
    
    
    if ([_photoURLs[indexPath.row] objectForKey:@"first"]!=nil){
        cell.label.text = [_photoURLs[indexPath.row] objectForKey:@"first"];
        
    }else{
        
        
        NSString * bang =[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&rankby=distance&types=accounting|airport|amusement_park|aquarium|art_gallery|atm|bakery|bank|bar|beauty_salon|bicycle_store|book_store|bowling_alley|bus_station|cafe|campground|car_dealer|car_rental|car_repair|car_wash|casino|cemetery|church|city_hall|clothing_store|convenience_store|courthouse|dentist|department_store|doctor|electrician|electronics_store|embassy|establishment|finance|fire_station|florist|food|funeral_home|furniture_store|gas_station|general_contractor|grocery_or_supermarket|gym|hair_care|hardware_store|health|hindu_temple|home_goods_store|hospital|insurance_agency|jewelry_store|laundry|lawyer|library|liquor_store|local_government_office|locksmith|lodging|meal_delivery|meal_takeaway|mosque|movie_rental|movie_theater|moving_company|museum|night_club|painter|park|parking|pet_store|pharmacy|physiotherapist|place_of_worship|plumber|police|post_office|real_estate_agency|restaurant|roofing_contractor|rv_park|school|shoe_store|shopping_mall|spa|stadium|storage|store|subway_station|synagogue|taxi_stand|train_station|travel_agency|university|veterinary_care|zoo&sensor=false&rankby=distance&key=AIzaSyD242pkuyIkgiaDl_6zfCNBFyUta9sUCZ0",latitude,longitude];
        
        NSString *hey = [self URLEncodeString:bang];
        NSURL *urlcustom=[NSURL URLWithString:hey];
        NSData *swagdata = [NSData dataWithContentsOfURL:urlcustom];
        NSError *error=nil;
        id response=[NSJSONSerialization JSONObjectWithData:swagdata options:
                     NSJSONReadingMutableContainers error:&error];
        
        NSArray *results = [response objectForKey:@"results"];
        NSDictionary *number1 = results[0];
        NSString *name = [number1 objectForKey:@"name"];
        [[_photoURLs objectAtIndex:indexPath.row] setObject:name forKey:@"first"];
        cell.label.text = name;

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
