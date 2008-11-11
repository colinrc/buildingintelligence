//
//  ControlBtnSliderBtnCellView.m
//  elife
//
//  Created by Cameron Humphries on 21/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "ControlBtnSliderBtnCellView.h"


@implementation ControlBtnSliderBtnCellView
@synthesize btn1;
@synthesize slider;
@synthesize btn2;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	NSArray *nibObjs = nil;
	
	nibObjs = [[NSBundle mainBundle] loadNibNamed:@"ControlBtnSliderBtnCell" owner:self options:nil];
	
	self = (ControlBtnSliderBtnCellView *)[nibObjs objectAtIndex:1];
	
	NSLog(@"creating cell view %@", reuseIdentifier);
	[self retain];
	
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)Btn1Action:(id)sender {
	NSLog(@"Btn1 Action");
}

-(IBAction)SliderAction:(id)sender {
	NSLog(@"Slider Action");
}

-(IBAction)Btn2Action:(id)sender {
	NSLog(@"Btn2 Action");
}

- (void)dealloc {
    [super dealloc];
}


@end
