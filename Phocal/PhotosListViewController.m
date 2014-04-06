//
//  ViewController.m
//  TableView
//
//  Created by Abbey Ciolek on 4/1/14.
//  Copyright (c) 2014 Abbey Ciolek. All rights reserved.
//

#import "PhotosListViewController.h"
#import "ImageCell.h"

@interface PhotosListViewController ()



@end

@implementation PhotosListViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _idx=-1;
   // [self.tableView registerClass:[ImageCell class] forCellReuseIdentifier:@"CellID"];
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
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
    
    UIImage *image = [UIImage imageNamed:@"Portofino-wallpapers.jpg"];
    
    
    cell.imageView.frame= CGRectMake(3, 5, 320, 200);
    cell.frame = CGRectMake(3, 5, 320, 200);
    [cell.imageView setImage:image];
    
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
    
    [tableView beginUpdates];
    [tableView endUpdates];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   if(_idx!=-1&&indexPath.row==_idx)
   {
       return 305.0;
   }
    return 205.0;
}



@end
