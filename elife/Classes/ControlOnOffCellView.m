//
//  ControlOnOffCellView.m
//  elife
//
//  Created by Cameron Humphries on 9/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "ControlOnOffCellView.h"


@implementation ControlOnOffCellView
@synthesize ctrlicon;
@synthesize ctrllabel;
@synthesize ctrlswitch;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	NSArray *nibObjs = nil;
	
	nibObjs = [[NSBundle mainBundle] loadNibNamed:@"ControlOnOffCellView" owner:self options:nil];
	
	self = (ControlOnOffCellView *)[nibObjs objectAtIndex:1];
	
	NSLog(@"creating cell view %@", reuseIdentifier);
	[self retain];
	
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)OnOffAction:(id)sender{
	NSLog(@"OnOffAction activated");
	
	return;
}




- (void)dealloc {
    [super dealloc];
}


@end
