//
//  uiToggle.m
//  eLife3
//
//  Created by Richard Lemon on 4/03/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "uiToggle.h"
#import "Command.h"
#import "eLife3AppDelegate.h"

@implementation uiToggle
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
	NSString *state = [control_ stateFor:[attributes_ objectForKey:@"command"]];
	NSArray *extras = [[attributes_ objectForKey:@"extras"] componentsSeparatedByString:@","];
	if ((state == nil) && ([extras count] == 2))
		state = [extras objectAtIndex:1];
	
	NSArray* icons = [[control_ valueFor:@"icons"] componentsSeparatedByString:@","];
	if (icons == nil)
		icons = [[attributes_ objectForKey:@"icons"] componentsSeparatedByString:@","];
	
	if ([icons count] == 2) {
		NSString* iconStr = [icons objectAtIndex:0];
		if ((state != nil) && ([state caseInsensitiveCompare:[extras objectAtIndex:0]] == NSOrderedSame))
			iconStr = [icons objectAtIndex:1];
		if (iconStr != nil) {
			UIImage* icon = [UIImage imageNamed:[iconStr stringByAppendingString:@".png"]];
			if (icon != nil){
				[self setImage:icon forState:UIControlStateNormal];
			}
		}
	}
	
	NSArray* labels =  [[control_ valueFor:@"labels"] componentsSeparatedByString:@","];
	if (labels == nil)
		labels = [attributes_ objectForKey:@"labels"];
	
	if ([labels count] == 2) {
		NSString* labelStr = [labels objectAtIndex:0];
		if ((state != nil) && ([state caseInsensitiveCompare:[extras objectAtIndex:0]] == NSOrderedSame))
			labelStr = [labels objectAtIndex:1];
		if (labelStr != nil) {
			[self setTitle:labelStr forState:UIControlStateNormal];
		}
	}
	
	self.backgroundColor = UIColorFromRGB(0x7C90B0);
}
/**
 Action to perform on a toggle press
 */
-(void)toggleAction:(id)sender {
	
	NSLog(@"pushed a toggle");
	
	Command *myCommand = [[Command alloc] init];
	myCommand.key_ = control_.key_;
	NSString *state = [control_ stateFor:[attributes_ objectForKey:@"command"]];
	NSArray *extras = [[attributes_ objectForKey:@"extras"] componentsSeparatedByString:@","];
	if ((state == nil) && ([extras count] == 2))
		state = [extras objectAtIndex:1];
	if ([state caseInsensitiveCompare:[extras objectAtIndex:0]] == NSOrderedSame)
		myCommand.command_ = [extras objectAtIndex:1];
	else
		myCommand.command_ = [extras objectAtIndex:0];

	eLife3AppDelegate *elifeappdelegate = (eLife3AppDelegate *)[[UIApplication sharedApplication] delegate];
	[elifeappdelegate.elifeSvrConn sendCommand:myCommand];
	[myCommand release];
}

@end
