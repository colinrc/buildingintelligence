//
//  elifeAppDelegate.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright Humphries Consulting Pty Ltd 2008. All rights reserved.
//

#import "elifeAppDelegate.h"
#import "MacrosViewController.h"
#import "ZonesViewController.h"
#import "StatusViewController.h"
#import "CalendarViewController.h"
#import "SettingsViewController.h"
#import "elifemacro.h"
#import "RoomItem.h"
#import "elifeXMLParser.h"
#import "elifesocket.h"

@implementation elifeAppDelegate

@synthesize window;
@synthesize rootTC;
@synthesize zonesNC;
@synthesize mainVClist;
@synthesize elifezonelist;
@synthesize elifectrltypes;

- (void)CreateMacrosView {
	// Create Macros VC
	MacrosViewController *macrosVC = [[MacrosViewController alloc] init];
	macrosVC.title = @"Macros";
	
	//Create table for macros display
	MacrosTableViewController *macrosTable = [[MacrosTableViewController alloc] init];
	macrosTable.title = @"Macros";
	
	// Create some dummy macros for testing
	ElifeMacro *newmacro = [[ElifeMacro alloc] initWithName:@"Bedtime" andKey:@"Bedtime" currentStatus:1];
	[macrosTable addMacro:newmacro];
	[newmacro release];
	newmacro = [[ElifeMacro alloc] initWithName:@"Party Mode" andKey:@"Party_Mode" currentStatus:0];
	[macrosTable addMacro:newmacro];
	[newmacro release];
	newmacro = [[ElifeMacro alloc] initWithName:@"Feed the Dogs" andKey:@"Feed_Dogs" currentStatus:0];
	[macrosTable addMacro:newmacro];
	[newmacro release];
	
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
	statusVC.title = @"Status";
	[mainVClist addObject:statusVC];
	[statusVC release];
}

- (void)CreateCalendarView {
	CalendarViewController *calVC = [[CalendarViewController alloc] init];
	calVC.title = @"Calendar";
	[mainVClist addObject:calVC];
	[calVC release];
}

- (void)CreateSettingsView {
	SettingsViewController *setVC = [[SettingsViewController alloc] init];
	setVC.title = @"Settings";
	[mainVClist addObject:setVC];
	[setVC release];
}	

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	// Init elifezonelist, elifectrltypes before XML parsing starts
	elifezonelist = [[NSMutableArray alloc] init];
	elifectrltypes = [[NSMutableArray alloc] init];
	
	// Parse XML Data to establish initial setup - just faking the url at this stage
	NSURL *url = [NSURL URLWithString: @"http://localhost/contacts.xml"];
	elifeXMLParser *myParser = [[elifeXMLParser alloc] parseXMLAtURL:url toObject:@"Contact" parseError:nil];

	// Trying Sockets
	elifesocket *myConnectSocket = [[elifesocket alloc] init];
	[myConnectSocket connecttoelife];
	
	// Create UITabBarController and array of tabs
	rootTC = [[UITabBarController alloc] init];
	mainVClist = [[NSMutableArray alloc] init];
	
	// Create Tabs
	[self CreateMacrosView];	
	[self CreateZonesView];
	[self CreateStatusView];
	[self CreateCalendarView];
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
