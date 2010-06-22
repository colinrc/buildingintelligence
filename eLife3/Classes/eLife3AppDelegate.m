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

@implementation eLife3AppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize elifeSvrConn;

- (void)applicationDidFinishLaunching:(UIApplication *)application {

    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
	// Check user prefs
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (([[defaults objectForKey:@"elifesvr"] length] <= 0) ||
		([[defaults objectForKey:@"elifesvrport"] length] <= 0)) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You must set your user preferences." delegate:self 
														cancelButtonTitle:@"Set Preferences" destructiveButtonTitle:nil otherButtonTitles:nil];
		[actionSheet showInView:tabBarController.view];
		[actionSheet release];
	}
	
	// Attempt to connect to eLife Server
	elifeSvrConn = [[elifesocket alloc] init];
	[elifeSvrConn connectToELife];
	
	// TODO: decide whether to loop this or config file??
	// retrieve the client XML and parse
	clientParser *clientxml = [[clientParser alloc] init];
	[clientxml release];
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

// Allow the user to either terminate the application or change to the settings page
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	self.tabBarController.selectedIndex = 3;
	// TODO: navigate to the settings page
}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

