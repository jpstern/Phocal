//
//  ViewController.m
//  TableView
//
//  Created by Abbey Ciolek on 4/1/14.
//  Copyright (c) 2014 Abbey Ciolek. All rights reserved.
//

#import "DatabaseDelegate.h"
#import "PhotosListViewController.h"
#import "ImageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

NSString* kImageBaseUrl = @"http://s3.amazonaws.com/Phocal/";

@interface PhotosListViewController ()

@property (nonatomic, strong) NSMutableArray* photoURLs;

@end

@implementation PhotosListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        _photoURLs = [[NSMutableArray alloc] init];
        self.refreshControl = [[UIRefreshControl alloc] init];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _idx=-1;
   // [self.tableView registerClass:[ImageCell class] forCellReuseIdentifier:@"CellID"];
    [self refreshPhotos];
}

- (void)refreshPhotos {
    [self.refreshControl beginRefreshing];
    
    [[DatabaseDelegate sharedManager] getPhotos:^(NSArray * photos) {
        if (!photos) {
            NSLog(@"no photos");
            return;
        }
        
        for (NSDictionary* photoDict in photos) {
            [self.photoURLs addObject:photoDict[@"id"]];
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
  /*  static NSString *cellID = @"CellID";
    
    ImageCell *cell = (ImageCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    return (UITableViewCell *)cell;*/
    ImageCell *cell = (ImageCell *) [tableView dequeueReusableCellWithIdentifier:@"MainCell"];
    if(cell==nil)
    {
        cell=[[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MainCell"];
    }
    
    cell.imageView.frame= CGRectMake(3, 5, 314, 200);
    cell.frame = CGRectMake(3, 5, 314, 200);
        
    // Set placeholder image.
    NSURL* url = [NSURL URLWithString:[kImageBaseUrl stringByAppendingString:self.photoURLs[indexPath.row]]];
    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Portofino-wallpapers.jpg"]];
    
    return (UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
    //Newly Selected Cell
    if(_idx!=indexPath.row)
    {
        _idx=indexPath.row;
    }
    //Cell Already Selected Once
    else
    {
        _idx=-1;
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   if(_idx!=-1&&indexPath.row==_idx)
   {
       
       return 305.0;
       
   }
    return 205.0;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_idx!=-1&&indexPath.row==_idx)
    {
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


@end
