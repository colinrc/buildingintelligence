//
//  uiButton.m
//  eLife3
//
//  Created by Richard Lemon on 4/03/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "uiButton.h"
#import "Command.h"
#import "eLife3AppDelegate.h"

@implementation uiButton

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
 TODO: don't need this as this control does not update
 */
-(void) updateControl {
	// look for an icon
	NSString* iconStr = [attributes_ objectForKey:@"icon"];
	// now set the icon if we have one
	if (iconStr != nil) {
		UIImage* icon = [UIImage imageNamed:[iconStr stringByAppendingString:@".png"]];
		if (icon != nil){
			[self setImage:icon forState:UIControlStateNormal];
		}
	}
	// look for a label
	NSString* labelStr = [attributes_ objectForKey:@"label"];
	// now set the label if we have one
	if (labelStr != nil) {
		[self setTitle:labelStr forState:UIControlStateNormal];
	}
	// look for a sound to play
	NSString* soundStr = [attributes_ objectForKey:@"sound"];
	// now set the label if we have one
	if (soundStr != nil) {
		[self setTitle:labelStr forState:UIControlStateNormal];
	}
	self.backgroundColor = UIColorFromRGB(0x7C90B0);
	[self setNeedsDisplay];
}
/**
 Action to perform on a button press
 */
-(void)buttonAction:(id)sender {
	
	NSLog(@"pushed a button");
//	uiButton *button = (uiButton*) sender;
	
	Command *myCommand = [[Command alloc] init];
	myCommand.key_ = control_.key_;
	myCommand.command_ = [attributes_ objectForKey:@"command"];
	eLife3AppDelegate *elifeappdelegate = (eLife3AppDelegate *)[[UIApplication sharedApplication] delegate];
	[elifeappdelegate.elifeSvrConn sendCommand:myCommand];
	[myCommand release];
}
/**
 Called by control when there is data from server
 */
- (void)statusUpdate:(NSNotification *)notification {
	
}

@end
