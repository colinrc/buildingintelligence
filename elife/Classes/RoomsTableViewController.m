//
//  RoomsTableViewController.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "RoomsTableViewController.h"
#import "ControlsTableViewController.h"
#import "elifeAppDelegate.h"
#import "elifezone.h"
#import "eliferoom.h"
#import "eliferoomtab.h"

@implementation RoomsTableViewController
//@synthesize roomlist;
@synthesize zoneidx;
@synthesize roomTabBar;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
	//roomlist = [[NSMutableArray alloc] init];
	
    return self;
}


/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	NSLog(@"CurrentZone %@ => RoomCount %d",thezone.name,[thezone.roomlist count]);
    return [thezone.roomlist count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	cell.text = [[thezone.roomlist objectAtIndex:indexPath.row] name];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *activezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *activeroom = [activezone.roomlist objectAtIndex:indexPath.row];
	eliferoomtab *activetab;
	NSInteger i;
	NSMutableArray *thetabs = [[NSMutableArray alloc] init];
	//NSString *iconname;
	
	if (self.roomTabBar == nil) {
		self.roomTabBar = [[RoomControlsTabBarController alloc] init];
	}
	self.roomTabBar.title = activeroom.name;
	self.roomTabBar.zoneidx = self.zoneidx;
	self.roomTabBar.roomidx = indexPath.row;
	self.roomTabBar.hidesBottomBarWhenPushed = YES;
	
	// Loop through tab list in active room making ControlsTableViewController items
	for (i=0; i < [activeroom.tablist count]; i++) {
		ControlsTableViewController *activecontrolview = [[ControlsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
		activetab = [activeroom.tablist objectAtIndex:i];
		if (activetab.name != nil) {
			activecontrolview.zoneidx = self.zoneidx;
			activecontrolview.roomidx = indexPath.row;
			activecontrolview.tabidx = i;
		
			activecontrolview.title = activetab.name;
			activecontrolview.tabBarItem.image = [UIImage imageNamed:[[activetab.tabattr objectForKey:@"icon"] stringByAppendingString:@".png"]];
			[thetabs addObject:activecontrolview];
		}
		
		[activecontrolview release];
	}

	// Push Room TabBar onto Nav Controller
	[self.roomTabBar setViewControllers:thetabs];
	if ([thetabs count] != 0) {
		self.roomTabBar.selectedViewController = [thetabs objectAtIndex:0];
	}
	[elifeappdelegate.zonesNC pushViewController:self.roomTabBar animated:TRUE];

}


/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

//- (void)addRoom:(RoomItem *)newroomitem {
//	[roomlist addObject:newroomitem];
//}

- (void)dealloc {
    [super dealloc];
}


@end

