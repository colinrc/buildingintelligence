//
//  RoomsTableViewController.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "RoomsTableViewController.h"
#import "ControlsTableViewController.h"
#import "elife_bAppDelegate.h"
#import "elifezone.h"
#import "eliferoom.h"
#import "eliferoomtab.h"

@implementation RoomsTableViewController
//@synthesize roomlist;
@synthesize zoneidx;
@synthesize roomidx;
//@synthesize roomTabBar;
@synthesize roomTableView;

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
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	NSLog(@"CurrentZone %@ => CurrentRoom %@ => Tabs %d",thezone.name,theroom.name,[theroom.tablist count]);
    return [theroom.tablist count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:self.roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	cell.text = thetab.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *activezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *activeroom = [activezone.roomlist objectAtIndex:self.roomidx];
	eliferoomtab *activetab = [activeroom.tablist objectAtIndex:indexPath.row];
	//NSInteger i;
	//NSMutableArray *thetabs = [[NSMutableArray alloc] init];
	//NSString *iconname;
	
	if (self.roomTableView == nil) {
		NSLog(@"creating a new controls view controller");
		self.roomTableView = [[ControlsTableViewController alloc] init];
	}
	self.roomTableView.title = activetab.name;
	self.roomTableView.zoneidx = self.zoneidx;
	self.roomTableView.roomidx = self.roomidx;
	self.roomTableView.tabidx = indexPath.row;
	[self.roomTableView.tableView reloadData];
	[elifeappdelegate.zonesNC pushViewController:self.roomTableView animated:TRUE];

	/* tabbar version
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
	 */
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
	//[self.roomTableView dealloc];
    [super dealloc];
}


@end

