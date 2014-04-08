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
    [self.tableView registerClass:[ImageCell class] forCellReuseIdentifier:@"MainCell"];
 
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

    ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell"];// forIndexPath:indexPath];
    
    if (!cell)
        cell=[[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MainCell"];
    
    if (!cell.container) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell addPhotosWithFrame:CGRectMake(0, 0, 320, 200) AndPaths:@[@"http://tetze.com/wp-content/uploads/2014/03/dog.jpg",@"http://tetze.com/wp-content/uploads/2014/03/dog.jpg",@"http://tetze.com/wp-content/uploads/2014/03/dog.jpg",@"http://tetze.com/wp-content/uploads/2014/03/dog.jpg",@"http://tetze.com/wp-content/uploads/2014/03/dog.jpg",@"http://tetze.com/wp-content/uploads/2014/03/dog.jpg"
                                                                       ]];
        
        cell.container.imageScroll.tag = indexPath.row;
        [cell.container.imageScroll addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)]];
    }
    
    if (_idx == indexPath.row) {
     
        [cell.container cellDidGrowToHeight:300];
        
    }
//
//    UIImage *image = [UIImage imageNamed:@"Portofino-wallpapers.jpg"];
//    
//    
//    cell.imageView.frame= CGRectMake(3, 5, 320, 200);
//    cell.frame = CGRectMake(3, 5, 320, 200);
//    [cell.imageView setImage:image];
//    
    return cell;
}

- (void)cellTapped:(UITapGestureRecognizer*)tap {
    
    NSInteger row = tap.view.tag;

//    NSLog(@"%@", tap.view.superview.superview.superview);
    
    ImageCell *cell = (ImageCell *)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    
//    [self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
    
    //Newly Selected Cell
    if(_idx!=row)
    {
        _idx=row;
    }
    //Cell Already Selected Once
    else
    {
        _idx=-1;
    }
    
//    [self.tableView beginUpdates];
//    [self.tableView endUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_idx!=-1&&indexPath.row==_idx)
    {
        
        return 300.0;
        
    }
    
    return 200.0;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(ImageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_idx!=-1&&indexPath.row==_idx)
    {
//        [tableView scrollToRowAtIndexPath:indexPath
//                         atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
//        [cell.container cellDidGrowToHeight:300];
    }
}


@end
