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

const int kLabelOffset = 250;
const int kLabelHeight = 60;

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
    [self.label setFrame:CGRectMake(0, kLabelOffset, 320, kLabelHeight)];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.image setFrame:CGRectMake( 0,0, 320, 320)];
    
    
    //[self.image setFrame:CGRectMake( 0,20, 320, 320)];
    
    
    [self.contentView addSubview:self.image];
    
    [self.image addSubview:self.label];

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

