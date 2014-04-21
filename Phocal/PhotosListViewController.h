//
//  ViewController.h
//  TableView
//
//  Created by Abbey Ciolek on 4/1/14.
//  Copyright (c) 2014 Abbey Ciolek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndexUIImageView;
@class MomentCell;
@class PhotosContainerView;

extern const int kImageOffsetFromTop;
extern const int kPhotoSize;

@interface PhotosListViewController : UITableViewController

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) MomentCell* selectedCell;
@property (nonatomic, assign) CGRect selectedRect;
@property (nonatomic, weak) id master;

@property (nonatomic, strong) PhotosContainerView* photoDisplayView;

- (void)replaceSelectedPhotoWithPhoto:(IndexUIImageView *)photo;
- (void)addPhotoFromUpload:(NSDictionary *)photo;

@end
