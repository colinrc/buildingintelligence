//
//  ControlWebCellView.m
//  elife
//
//  Created by Cameron Humphries on 21/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "ControlWebCellView.h"


@implementation ControlWebCellView
@synthesize webview;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	NSArray *nibObjs = nil;
	
	nibObjs = [[NSBundle mainBundle] loadNibNamed:@"ControlWebCell" owner:self options:nil];
	
	self = (ControlWebCellView *)[nibObjs objectAtIndex:1];
	
	NSLog(@"creating cell view %@", reuseIdentifier);
	[self retain];
	
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
