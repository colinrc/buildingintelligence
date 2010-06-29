//
//  macrosViewController.m
//  eLife3
//
//  Created by Cameron Humphries on 14/01/10.
//  Copyright 2010 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "serverConnection.h"
#import "eLife3AppDelegate.h"
#import "macrosViewController.h"
#import "macroList.h"
#import "macro.h"

@implementation macrosViewController

@synthesize tmpCell;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	// request notification of macros added
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(macroUpdate:) name:@"addMacro" object:nil];
	// network change notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkUpdate:) name:@"networkChange:" object:nil];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	// lets set the nav bar network state
	eLife3AppDelegate *elifeappdelegate = (eLife3AppDelegate *)[[UIApplication sharedApplication] delegate];
	[elifeappdelegate networkUpdate:self];	
	[self.tableView reloadData];
}
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	NSLog(@"macro rows: %d", [[macroList sharedInstance] countMacros]);
    return [[macroList sharedInstance].macrolist_ count];
}


/**
 OnUpdate type function, framewok calls this function to populate the view
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	macroList *macrolist = [macroList sharedInstance];
	macro *tmpMacro = [macrolist.macrolist_ objectAtIndex:indexPath.row];
	
    // Configure the cell
	UILabel *myLabel = (UILabel *)[cell textLabel];
	NSString *tmpStr = [tmpMacro.macroattr objectForKey:@"EXTRA"];
	myLabel.text = tmpStr;
	
	UIActivityIndicatorView *myActInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	cell.accessoryView = myActInd;
	if ([[macrolist.macrolist_ objectAtIndex:indexPath.row] isRunning]) {
//		NSLog(@"macro - start animating");
		[myActInd startAnimating];
	} else {
		[myActInd stopAnimating];
//		NSLog(@"macro - stop animating");
	}
	
	[myActInd release];	
	
	// request notification of changes
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(macroUpdate:) name:tmpStr object:nil];
	
//	NSLog(@"macro name:%@",tmpStr);
	
    return cell;
}

/**
 User selected the table row, start the macro if not running
 Stop the macro if it is already running
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	eLife3AppDelegate *elifeappdelegate = (eLife3AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *macrolist = [[macroList sharedInstance] macrolist_];
	serverConnection *myServer = elifeappdelegate.elifeSvrConn;
//	NSMutableArray *sendmsgs = elifeappdelegate.msgs_for_svr;
	UITableViewCell *cell = nil;
	
//	NSLog(@"Macro %@ selected", [[[macrolist objectAtIndex:indexPath.row] macroattr] objectForKey:@"EXTRA"]);
	
//	NSLog(@"changing macro state %@: current %@", [[[macrolist objectAtIndex:indexPath.row] macroattr] objectForKey:@"EXTRA"], 
//		  [[[macrolist objectAtIndex:indexPath.row] macroattr] objectForKey:@"RUNNING"]);
	
    // Configure the view for the selected state
	cell = [tableView cellForRowAtIndexPath:indexPath];
	UILabel *myLabel = (UILabel *)[cell textLabel];
	UIActivityIndicatorView *myActInd = (UIActivityIndicatorView *)[cell  accessoryView];

	if ([[macrolist objectAtIndex:indexPath.row] isRunning] == NO) 
	{
//		NSLog(@"macro - start animating");
		[myActInd startAnimating];
//		NSLog(@"Send macro start");
		Command *myCommand = [[Command alloc] init];
		myCommand.key_ = @"MACRO";
		myCommand.command_ =@"run";
		myCommand.extra_=[myLabel text];
		[myServer sendCommand:myCommand];
		[myCommand release];
	} else {
//		NSLog(@"macro - stop animating");
		[myActInd stopAnimating];
//		NSLog(@"Send macro stop");
		Command *myCommand = [[Command alloc] init];
		myCommand.key_ = @"MACRO";
		myCommand.command_ =@"complete";
		myCommand.extra_=[myLabel text];
		[myServer sendCommand:myCommand];
		[myCommand release];
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
/**
 Callback for the addMacro: notification
 */
- (void)macroUpdate:(NSNotification *)notification {
	//	NSString *thekey = [notification name];
	//	NSLog(@"Observed macroUpdate message:%@", thekey);
	[self.tableView setNeedsDisplay];
	[self.tableView reloadData];
}
/**
 Callback for the network state icon
 */
- (void)networkUpdate:(NSNotification *)notification {
	
	eLife3AppDelegate *elifeappdelegate = (eLife3AppDelegate *)[[UIApplication sharedApplication] delegate];
	[elifeappdelegate networkUpdate:self];
}
/**
 clean up
 */
- (void)dealloc {
    [super dealloc];
}


@end

