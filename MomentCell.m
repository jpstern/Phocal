//
//  MomentCell.m
//  Phocal
//
//  Created by Patrick Wilson on 4/19/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "MomentCell.h"

//

//  MomentCell.m

//  Phocal

//

//  Created by Patrick Wilson on 4/19/14.

//  Copyright (c) 2014 Josh. All rights reserved.

//



#import "MomentCell.h"



@implementation MomentCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier

{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        // Initialization code
        
    }
    
    //self.frame = CGRectMake(0, 0, 320, 50);
    
    self.image = [[UIImageView alloc] init];
    
    self.label = [[UILabel alloc] init];
    
    [self.label setFrame:CGRectMake(0, 10, 320, 30)];
    
    [self.label setTextAlignment:NSTextAlignmentCenter];
    
    
    
    [self.image setFrame:CGRectMake( 0,60, 320, 320)];
    
    self.label2 = [[UILabel alloc] init];
    
    [self.label2 setFrame:CGRectMake(0, 30, 320, 30)];
    
    [self.label2 setTextAlignment:NSTextAlignmentCenter];
    
    //[self.image setFrame:CGRectMake( 0,20, 320, 320)];
    
    
    
    [self.contentView addSubview:self.image];
    
    [self.contentView addSubview:self.label];
    
    [self.contentView addSubview:self.label2];
    
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

