//
//  MomentCell.m
//  Phocal
//
//  Created by Patrick Wilson on 4/19/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "MomentCell.h"
#import "IndexUIImageView.h"
//

//  MomentCell.m

//  Phocal

//

//  Created by Patrick Wilson on 4/19/14.

//  Copyright (c) 2014 Josh. All rights reserved.

//




@implementation MomentCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier

{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        // Initialization code
        
    }
    
    //self.frame = CGRectMake(0, 0, 320, 50);
    self.image = [[IndexUIImageView alloc] init];
    self.label = [[UILabel alloc] init];
    [self.label setFrame:CGRectMake(0, 320-70, 320, 30)];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.image setFrame:CGRectMake( 0,0, 320, 320)];
    self.label2 = [[UILabel alloc] init];
    [self.label2 setFrame:CGRectMake(0, 320-40, 320, 30)];
    [self.label2 setTextAlignment:NSTextAlignmentCenter];
    
    //[self.image setFrame:CGRectMake( 0,20, 320, 320)];
    
    
    [self.contentView addSubview:self.image];
    
    [self.label setBackgroundColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.5]];
    [self.label2 setBackgroundColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.5]];
    [self.image addSubview:self.label];
    [self.image addSubview:self.label2];

    return self;
    
}



- (void)awakeFromNib

{
    
    // Initialization code
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated

{
    
    [super setSelected:selected animated:animated];
    
    
    
    // Configure the view for the selected state
    
}



@end

