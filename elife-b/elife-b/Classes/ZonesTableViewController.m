//
//  ZonesTableViewController.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "ZonesTableViewController.h"
#import "elifeAppDelegate.h"

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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSLog(@"number of zones %d",[elifeappdelegate.elifezonelist count]);
    return [elifeappdelegate.elifezonelist count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];

	cell.text = [[elifeappdelegate.elifezonelist objectAtIndex:indexPath.row] name];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// push zone element view onto stack
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (self.roomsTabView == nil) {
		self.roomsTabView = [[RoomsTableViewController alloc] init];
	}

	self.roomsTabView.zoneidx = indexPath.row;
	self.roomsTabView.title = [[elifeappdelegate.elifezonelist objectAtIndex:indexPath.row] name];
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

