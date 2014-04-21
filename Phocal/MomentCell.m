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

const int kLabelHorizontalOffset = 10;
const int kLabelVerticalOffset = 280;
const int kLabelHeight = 30;
const int kLabelWidth = 300;

@implementation MomentCell

+ (UILabel *)labelWithText:(NSString *)text {
    UILabel* newLabel = [[UILabel alloc] init];
    [newLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
    [newLabel setFrame:CGRectMake(kLabelHorizontalOffset, kLabelVerticalOffset, kLabelWidth, kLabelHeight)];
    [newLabel setTextAlignment:NSTextAlignmentCenter];
    [newLabel setTextColor:[UIColor whiteColor]];
    [newLabel setAdjustsFontSizeToFitWidth:YES];
    newLabel.text = text;
    [newLabel setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.2]];

    
    return newLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier

{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        // Initialization code
        
    }
    
    self.image = [[IndexUIImageView alloc] init];
    self.label = [MomentCell labelWithText:@""];
    
    // Add the views.
    [self.image addSubview:self.label];
    [self.contentView addSubview:self.image];
    
    
    // Configure the cell.
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];

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

