//
//  uiBrowser.m
//  eLife3
//
//  Created by Richard Lemon on 8/03/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "uiBrowser.h"


@implementation uiBrowser
extern UIColor* UIColorFromRGB(uint rgbValue);

@synthesize control_;
@synthesize attributes_;
@synthesize timer_;

/**
 Cleanup
 */
-(void) dealloc {
	[control_ release];
	[attributes_ release];
	[super dealloc];
}

/**
 Updates the control as per the eLife way
 */
-(void) updateControl {
	[self.timer_  invalidate];
	self.timer_ = nil;
	bool urlValid = false;
	
	// get url
	NSString *strUrl = [attributes_ objectForKey:@"src"];
	if (strUrl != nil) {
		NSURL *url = [NSURL URLWithString:strUrl];
		if (url != nil) {
			[self loadRequest: [NSURLRequest requestWithURL:url]];
			urlValid = true;
		}
	}

	if (!urlValid)
		[self loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
	// getrefresh rate
	NSString *strRefreshRate = [attributes_ objectForKey:@"refreshRate"];
	if (strRefreshRate != nil) {
		NSTimeInterval refRate = [strRefreshRate intValue] / 1000.0;
		if (refRate > 0) {
			// start a timer to reload the page
			// set a timer to request every request interval
			self.timer_ = [NSTimer scheduledTimerWithTimeInterval:refRate 
														   target:self
														 selector:@selector(refreshPage)
														 userInfo:nil
														  repeats:YES];
		}
	}
}

-(void) refreshPage {
	[self reload];
}

@end
