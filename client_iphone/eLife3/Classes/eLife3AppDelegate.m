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
@synthesize server_not_setup_;

-(id) init {
	self = [super init];
	
	img_red_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red.png"]];
	img_wwan_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WWAN5.png"]];
	img_airport_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Airport.png"]];
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	server_not_setup_ = NO;

    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
	// see if we can get some uPNP
	elifeSvrConn = [[serverConnection alloc] init];

	// Check user prefs
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (([[defaults objectForKey:@"elifesvr"] length] <= 0) ||
		([[defaults objectForKey:@"elifesvrport"] length] <= 0)) {
		self.server_not_setup_ = YES;
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You must set your user preferences." delegate:self 
														cancelButtonTitle:@"Set Preferences" destructiveButtonTitle:nil otherButtonTitles:nil];
		[actionSheet showInView:tabBarController.view];
		[actionSheet release];
	}

	// Attempt to connect to eLife Server
	[elifeSvrConn connect];
	
	// retrieve the client XML and parse
	clientParser *clientxml = [[clientParser alloc] init];
	[clientxml release]; // runs a timer loop for failure and keeps self reference
}
/**
 Allow the user to either terminate the application or change to the settings page
 */
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	self.tabBarController.selectedIndex = 3;

}
/**
 Set network status icon
 */
-(void)networkUpdate:(UITableViewController *)table {
	NSLog(@"************** networkUpdate:(UITableViewController *)table");
	UIBarButtonItem * rightBarButtonItem;
	// get the state
	switch (elifeSvrConn.status_) {
		case NotReachable:
			rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:img_red_];
			table.navigationItem.rightBarButtonItem = rightBarButtonItem;
			[rightBarButtonItem release];
			NSLog(@"not reachable");
			break;
		case ReachableDirect:
			if (elifeSvrConn.serverUp_) {
				NSLog(@"reachable direct");
				rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:img_airport_];
				table.navigationItem.rightBarButtonItem = rightBarButtonItem;
				[rightBarButtonItem release];
			} else {
				rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:img_red_];
				table.navigationItem.rightBarButtonItem = rightBarButtonItem;
				[rightBarButtonItem release];
				NSLog(@"server down");
			}
			break;
		case ReachableViaRouting:
			if (elifeSvrConn.serverUp_) {
				rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:img_wwan_];
				table.navigationItem.rightBarButtonItem = rightBarButtonItem;
				[rightBarButtonItem release];
				NSLog(@"reachable routing");
			} else {
				rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:img_red_];
				table.navigationItem.rightBarButtonItem = rightBarButtonItem;
				[rightBarButtonItem release];
				NSLog(@"server down");
			}
			break;
		default:
			NSLog(@"bad reachable");
			break;
	}
}
/**
 Cleanup code 
 */
- (void)dealloc {
    [tabBarController release];
    [window release];
	[img_red_ release];
	[img_wwan_ release];
	[img_airport_ release];
    [super dealloc];
}

@end

