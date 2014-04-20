//
//  ViewController.h
//  TableView
//
//  Created by Abbey Ciolek on 4/1/14.
//  Copyright (c) 2014 Abbey Ciolek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndexUIImageView;

@interface PhotosListViewController : UITableViewController

@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,weak) id master;

- (void)replaceSelectedPhotoWithPhoto:(IndexUIImageView *)photo;

@end
