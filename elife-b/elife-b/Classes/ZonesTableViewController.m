//
//  ZonesTableViewController.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "ZonesTableViewController.h"
#import "elife_bAppDelegate.h"
#import "elifezone.h"
#import "eliferoom.h"

@implementation ZonesTableViewController
//@synthesize zonelist;
@synthesize roomsTabView;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
	//self.zonelist = [[NSMutableArray alloc] init];
	
    return self;
}


/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSLog(@"number of zones %d",[elifeappdelegate.elifezonelist count]);
    return [elifeappdelegate.elifezonelist count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:section];
	NSLog(@"zones %d: room count %d",section, [thezone.roomlist count]);
    return [thezone.roomlist count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [[elifeappdelegate.elifezonelist objectAtIndex:section] name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:indexPath.section];
	cell.text = [[thezone.roomlist objectAtIndex:indexPath.row] name];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// push zone element view onto stack
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *activezone = [elifeappdelegate.elifezonelist objectAtIndex:indexPath.section];
	eliferoom *activeroom = [activezone.roomlist objectAtIndex:indexPath.row];
	
	if (self.roomsTabView == nil) {
		self.roomsTabView = [[RoomsTableViewController alloc] init];
	}

	self.roomsTabView.zoneidx = indexPath.section;
	self.roomsTabView.roomidx = indexPath.row;
	self.roomsTabView.title = activeroom.name;
	[self.roomsTabView.tableView reloadData];

	[elifeappdelegate.zonesNC pushViewController:self.roomsTabView animated:TRUE];
	
	//[[[zonelist objectAtIndex:indexPath.row] parentNC] pushViewController:[[zonelist objectAtIndex:indexPath.row] zoneelemVC] animated:TRUE];
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

//- (void)addZone:(ZoneItem *)newzone {
//	[zonelist addObject:newzone];
//}

- (void)dealloc {
    [super dealloc];
}


@end

