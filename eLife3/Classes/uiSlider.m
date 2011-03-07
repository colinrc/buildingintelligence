//
//  uiSlider.m
//  eLife3
//
//  Created by Richard Lemon on 4/03/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "uiSlider.h"
#import "Command.h"
#import "eLife3AppDelegate.h"

@implementation uiSlider
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
 TODO: change to init the only thing that is updated is the value
 */
-(void) updateControl {
	NSArray* icons = [[control_ valueFor:@"icons"] componentsSeparatedByString:@","];
	if ([icons count] == 2) {
		// we have an on and off icon [0] & [1]
		// TODO: make a custom slider that uses the icon values
		// for the grab area
		
	}

	self.maximumValue = 100;
	self.minimumValue = 0;
	self.value = [[control_ stateFor:@"value"] intValue];
	self.backgroundColor = UIColorFromRGB(0x7C90B0);	
}
/**
 Action to perform on a slider drag
 */
-(void)sliderAction:(id)sender {
	
	uiSlider *slider = (uiSlider*)sender;
	NSLog(@"slider is %2.0f",slider.value);
	Command *myCommand = [[Command alloc] init];
	myCommand.key_ = control_.key_;
	myCommand.command_ = (slider.value > 1.0)? @"on" : @"off";
	if (slider.value > 1.0)
		myCommand.extra_ = [NSString stringWithFormat:@"%2.0f", slider.value];
	eLife3AppDelegate *elifeappdelegate = (eLife3AppDelegate *)[[UIApplication sharedApplication] delegate];
	[elifeappdelegate.elifeSvrConn sendCommand:myCommand];
	[myCommand release];
}
/**
 Called by control when there is data from server
 */
- (void)statusUpdate:(NSNotification *)notification {
	NSLog(@"slider update for control %@", control_.key_);
	self.value = [control_.extra_ intValue];
}

@end
