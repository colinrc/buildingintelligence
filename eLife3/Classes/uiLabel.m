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

@end
