//
//  ControlBtnBtnBtnBtnCellView.m
//  elife
//
//  Created by Cameron Humphries on 21/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "ControlBtnBtnBtnBtnCellView.h"


@implementation ControlBtnBtnBtnBtnCellView
@synthesize btn1;
@synthesize btn2;
@synthesize btn3;
@synthesize btn4;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	NSArray *nibObjs = nil;
	
	nibObjs = [[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnBtnBtnCell" owner:self options:nil];
	
	self = (ControlBtnBtnBtnBtnCellView *)[nibObjs objectAtIndex:1];
	
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

-(IBAction)Btn2Action:(id)sender {
	NSLog(@"Btn2 Action");
}

-(IBAction)Btn3Action:(id)sender {
	NSLog(@"Btn3 Action");
}

-(IBAction)Btn4Action:(id)sender {
	NSLog(@"Btn4 Action");
}

- (void)dealloc {
    [super dealloc];
}


@end
