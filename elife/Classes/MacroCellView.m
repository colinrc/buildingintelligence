//
//  MacroCellView.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "MacroCellView.h"


@implementation MacroCellView
@synthesize macroLabel;
@synthesize macroprogress;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	NSArray *nibObjs = nil;
	
	nibObjs = [[NSBundle mainBundle] loadNibNamed:@"MacroCellView" owner:self options:nil];
	if (nibObjs == nil) {
		NSLog(@"something went wrong");
		exit(0);
	}
	if ([nibObjs count] < 2) {
		NSLog(@"array length: %d", [nibObjs count]);
		exit(0);
	}
	
	self = (MacroCellView *)[nibObjs objectAtIndex:1];
	
	NSLog(@"creating cell view %@", reuseIdentifier);
	//if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
       // macroLabel = [[UILabel alloc] initWithFrame:CGRectZero];
       // macroLabel.font = [UIFont boldSystemFontOfSize:24];
       // macroLabel.textColor = [UIColor blackColor];
       // macroLabel.textAlignment = UITextAlignmentLeft;
       // macroLabel.backgroundColor = [UIColor clearColor];
		
	//	macroprogress = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
	//	macroprogress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	//	macroprogress.hidesWhenStopped = YES;
		
      //  [self.contentView addSubview:macroprogress];
       // [self.contentView addSubview:macroLabel];
		
   // }
	
	//self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	//[self layoutSubviews];
	
	return self;
}


- (void)layoutSubviews
{	
	[super layoutSubviews];
	
	CGRect rect = CGRectInset(self.contentView.bounds, 10, 10);
    rect.origin.y -=5;
    rect.origin.x += 5;
    rect.size.height+=10;
    macroLabel.frame = rect;
	
    rect.origin.x +=270;
    rect.size.width = 20;
	macroprogress.frame = rect;
	
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
}


- (void)dealloc {
    [super dealloc];
}


@end
