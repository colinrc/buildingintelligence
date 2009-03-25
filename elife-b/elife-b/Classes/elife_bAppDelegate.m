//
//  elife_bAppDelegate.m
//  elife-b
//
//  Created by Cameron Humphries on 29/11/08.
//  Copyright Humphries Consulting Pty Ltd 2008. All rights reserved.
//

#import "elife_bAppDelegate.h"
#import "MacrosViewController.h"
#import "ZonesViewController.h"
#import "StatusViewController.h"
#import "CalendarViewController.h"
#import "SettingsViewController.h"
#import "elifemacro.h"
#import "RoomItem.h"
#import "elifeXMLParser.h"
#import "elifestatustab.h"
#import "elifestatusitem.h"


@implementation elife_bAppDelegate

@synthesize window;
@synthesize rootTC;
@synthesize zonesNC;
@synthesize mainVClist;
@synthesize elifezonelist;
@synthesize elifectrltypes;
@synthesize elifemacrolist;
@synthesize elifestatustabs;
@synthesize elifesvr;
@synthesize msgs_for_svr;

- (void)CreateMacrosView {
	// Create Macros VC
	MacrosViewController *macrosVC = [[MacrosViewController alloc] init];
	macrosVC.title = @"Macros";
	macrosVC.tabBarItem.image = [UIImage imageNamed:@"tabbar-macro.png"];
	
	//Create table for macros display
	MacrosTableViewController *macrosTable = [[MacrosTableViewController alloc] init];
	macrosTable.title = @"Macros";
	
	// Store TableViewController and push onto Navigation Stack
	macrosVC.macrosTabControl = macrosTable;
	[macrosVC pushViewController:macrosTable animated:TRUE];
	
	// Append Macros view controller to tab list
	[mainVClist addObject:macrosVC];
	
	// Clean up
	[macrosTable release];
	[macrosVC release];
}

- (void)CreateZonesView {
	// Create Zones Navigation Controller
	zonesNC = [[ZonesViewController alloc] init];
	zonesNC.title = @"Zones";
	zonesNC.tabBarItem.image = [UIImage imageNamed:@"tabbar-zones.png"];

	//Create table for zones display
	ZonesTableViewController *zonesTable = [[ZonesTableViewController alloc] init];
	zonesTable.title = @"Zones";
	
	// Store TableViewController and push onto Navigation Stack
	zonesNC.zonesTabControl = zonesTable;
	[zonesNC pushViewController:zonesTable animated:TRUE];	
	
	// Append Zones View Controller to tab list
	[mainVClist addObject:zonesNC];
}	

- (void)CreateStatusView {
	StatusViewController *statusVC = [[StatusViewController alloc] init];
	// register for notifications of status changes
	int i,j;
	elifestatustab *currstatustab;
	elifestatusitem *curritem;
	for (i=0; i<[elifestatustabs count];i++) {
		currstatustab = [elifestatustabs objectAtIndex:i];
		for (j=0; j<[currstatustab.statusitems count]; j++) {
			curritem = [currstatustab.statusitems objectAtIndex:j];
			[statusVC registerWithNotification:[curritem.key stringByAppendingString:@"_status"]];
		}
	}
	
	statusVC.title = @"Status";
	statusVC.tabBarItem.image = [UIImage imageNamed:@"tabbar-status.png"];

	[mainVClist addObject:statusVC];
	[statusVC release];
}

- (void)CreateSettingsView {
	SettingsViewController *setVC = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];

	setVC.title = @"Settings";
	setVC.tabBarItem.image = [UIImage imageNamed:@"tabbar-prefs.png"];

	[mainVClist addObject:setVC];
	[setVC release];
}	

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	// Init elifezonelist, elifectrltypes before XML parsing starts
	elifezonelist = [[NSMutableArray alloc] init];
	elifectrltypes = [[NSMutableArray alloc] init];
	elifemacrolist = [[NSMutableArray alloc] init];
	elifestatustabs = [[NSMutableArray alloc] init];
	
	// set up array for server messages
	msgs_for_svr = [[NSMutableArray alloc] init];
	
	// Load elife config
	elifeXMLParser *myParser = [[elifeXMLParser alloc] initParser];
	
	// Trying Sockets
	elifesvr = [[elifesocket alloc] init];
	[elifesvr connecttoelife];
	
	// Create UITabBarController and array of tabs
	rootTC = [[UITabBarController alloc] init];
	mainVClist = [[NSMutableArray alloc] init];
	
	// Create Tabs
	[self CreateMacrosView];	
	[self CreateStatusView];
	[self CreateZonesView];
	[self CreateSettingsView];
	
	// Pass array of VC to rootTC
	[rootTC setViewControllers:mainVClist animated:TRUE];
	
    // Override point for customization after application launch
	[window addSubview:rootTC.view];
    [window makeKeyAndVisible];
}

- (void)dealloc {
	[rootTC release];
    [window release];
    [super dealloc];
}


@end
