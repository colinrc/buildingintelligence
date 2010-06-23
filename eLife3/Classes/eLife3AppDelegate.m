//
//  eLife3AppDelegate.m
//  eLife3
//
//  Created by Cameron Humphries on 10/01/10.
//  Copyright Humphries Consulting Pty Ltd 2010. All rights reserved.
//

#import "eLife3AppDelegate.h"
#import "macroList.h"
#import "clientParser.h"
#import "settingsViewController.h"

@implementation eLife3AppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize elifeSvrConn;
@synthesize noServerSet_;

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	noServerSet_ = NO;

    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
	// Check user prefs
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (([[defaults objectForKey:@"elifesvr"] length] <= 0) ||
		([[defaults objectForKey:@"elifesvrport"] length] <= 0)) {
		noServerSet_ = YES;
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You must set your user preferences." delegate:self 
														cancelButtonTitle:@"Set Preferences" destructiveButtonTitle:nil otherButtonTitles:nil];
		[actionSheet showInView:tabBarController.view];
		[actionSheet release];
	}

	// Attempt to connect to eLife Server
	elifeSvrConn = [[serverConnection alloc] init];
	[elifeSvrConn connect];
	
	// retrieve the client XML and parse
	clientParser *clientxml = [[clientParser alloc] init];
	[clientxml release]; // runs a timer loop for failure and keeps self reference
}

// Allow the user to either terminate the application or change to the settings page
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	self.tabBarController.selectedIndex = 3;

}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

