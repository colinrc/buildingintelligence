//
//  uiLabel.m
//  eLife3
//
//  Created by Richard Lemon on 4/03/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "uiLabel.h"


@implementation uiLabel
extern UIColor* UIColorFromRGB(uint rgbValue);

@synthesize control_;
@synthesize attributes_;

/**
 Override the standard setter to subscribe to updates
 */
-(void) setControl_:(Control *)control {
	
	if (control.key_ != control_.key_) {
		if (control_ != nil)
			[[NSNotificationCenter defaultCenter] removeObserver:self name:[control_.key_ stringByAppendingString:@"_status"] object:nil];
		control_ = [control retain];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusUpdate:) name:[control_.key_ stringByAppendingString:@"_status"] object:nil];
	}
}
/**
 Cleanup
 */
-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[control_ release];
	[attributes_ release];
	[super dealloc];
}
/**
 Updates the control as per the eLife way
 */
-(void) updateControl {
	NSString* state = [control_ stateFor:@"state"];
	if (state == nil) {
		state = [attributes_ objectForKey: @"defaultState"];
	}
	
	NSString* value = [control_ stateFor:@"on"];
	if (value == nil) {
		value = [attributes_ objectForKey:@"defaultValue"];
	}
	NSString* src = [control_ stateFor:@"src"];
	
	NSString* labelString = [attributes_ objectForKey:@"formats"];
	if (labelString == nil) {
		labelString = @"%name% ";
		if (state != nil) labelString = [labelString stringByAppendingString:@"(%state%)"];
	}
	
	// the format string label thing
	if (control_.name_ != nil)
		labelString = [labelString stringByReplacingOccurrencesOfString:@"%name%" withString:control_.name_];
	if (state != nil)
		labelString = [labelString stringByReplacingOccurrencesOfString:@"%state%" withString:state];
	if (value != nil)
		labelString = [labelString stringByReplacingOccurrencesOfString:@"%value%" withString:value];
	if (src != nil)
		labelString = [labelString stringByReplacingOccurrencesOfString:@"%src%" withString:src];

	self.text = labelString;
	self.textAlignment = UITextAlignmentCenter;
	self.backgroundColor = UIColorFromRGB(0x7C90B0);
	
}
/**
 Called by control when there is data from server
 */
- (void)statusUpdate:(NSNotification *)notification {
	NSLog(@"Label update for control %@", control_.key_);
	[self updateControl];
}

@end
