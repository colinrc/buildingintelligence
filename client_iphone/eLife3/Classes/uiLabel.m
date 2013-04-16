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
	NSArray* states = [[attributes_ objectForKey:@"states"] componentsSeparatedByString:@","];
	if (state == nil) {
		state = [attributes_ objectForKey: @"defaultState"];
	}
	
	NSString* value = [control_ stateFor:@"on"];
	if (value == nil) {
		value = [attributes_ objectForKey:@"defaultValue"];
	}
	NSString* src = [control_ stateFor:@"src"];
	
	NSArray* fomats = [[attributes_ objectForKey:@"formats"] componentsSeparatedByString:@","];
	NSString* format = [attributes_ objectForKey:@"format"];
	NSString* labelString;
	if ([states count] > 1) {
		if ((state != nil) && ([state caseInsensitiveCompare:[states objectAtIndex:0]] == NSOrderedSame)) {
			labelString = [fomats objectAtIndex:0];
		}
		else if ((state != nil) && ([state caseInsensitiveCompare:[states objectAtIndex:1]] == NSOrderedSame)) {
			labelString = [fomats objectAtIndex:1];
		}
		else {
			labelString = @"%name% ";
		}		
		
	} else if (format != nil) {
		labelString = format;
		NSArray * allStates = [control_.state_info_ allValues];
		for (int i = 0 ; i < [allStates count] ; i++) {
			NSString * currentState = [allStates objectAtIndex:i];
			NSString *fmtStr = [NSString stringWithFormat:@"%%%i%%",i];
			labelString = [labelString stringByReplacingOccurrencesOfString:fmtStr withString:(currentState != nil) ? currentState : @""];
		}
	} else {
		labelString = @"%name% ";
		if (state != nil) labelString = [labelString stringByAppendingString:@"(%state%)"];
	}


	if (labelString == nil) {
		labelString = @"%name% ";
		if (state != nil) labelString = [labelString stringByAppendingString:@"(%state%)"];
	}
	
	// the format string label thing
	labelString = [labelString stringByReplacingOccurrencesOfString:@"%name%" withString:(control_.name_ != nil) ? control_.name_ : @""];
	labelString = [labelString stringByReplacingOccurrencesOfString:@"%state%" withString:(state != nil) ? state : @""];
	labelString = [labelString stringByReplacingOccurrencesOfString:@"%value%" withString:(value != nil) ? value : @""];
	labelString = [labelString stringByReplacingOccurrencesOfString:@"%src%" withString:(src != nil) ? src : @""];

	self.text = labelString;
	self.textAlignment = UITextAlignmentCenter;
	self.backgroundColor = UIColorFromRGB(0x7C90B0);
}

@end
