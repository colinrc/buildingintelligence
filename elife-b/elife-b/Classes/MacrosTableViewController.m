//
//  MacrosTableViewController.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "MacrosTableViewController.h"
#import "elife_bAppDelegate.h"

@implementation MacrosTableViewController
@synthesize myCell;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
	
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
	NSLog(@"number of macros %d",[elifeappdelegate.elifemacrolist count]);
    return [elifeappdelegate.elifemacrolist count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *macrolist = elifeappdelegate.elifemacrolist;
	UITableViewCell *cell = nil;

	NSLog(@"Looking for a cell at %d",indexPath.row);    
    cell = [tableView dequeueReusableCellWithIdentifier:@"MacroCellView"];
	if (cell == nil) {
		NSLog(@"no reuseable cell available");
		[[NSBundle mainBundle] loadNibNamed:@"MacroCellView" owner:self options:nil];
		cell = self.myCell;
		self.myCell = nil;
		if (cell == nil) {
			NSLog(@"something went wrong with label");
		}
	}
    // Configure the cell
	UILabel *myLabel = (UILabel *)[cell viewWithTag:10];
	myLabel.text = [[[macrolist objectAtIndex:indexPath.row] macroattr] objectForKey:@"EXTRA"];
	
	UIActivityIndicatorView *myActInd = (UIActivityIndicatorView *)[cell viewWithTag:11];
	//if ([[[[macrolist objectAtIndex:indexPath.row] macroattr] objectForKey:@"RUNNING"] isEqualToString:@"1"]) {
	if ([[macrolist objectAtIndex:indexPath.row] isRunning]) {	
		[myActInd startAnimating];
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *macrolist = elifeappdelegate.elifemacrolist;
	elifesocket *myServer = elifeappdelegate.elifesvr;
	NSMutableArray *sendmsgs = elifeappdelegate.msgs_for_svr;
	UITableViewCell *cell = nil;

	NSLog(@"Macro %@ selected", [[[macrolist objectAtIndex:indexPath.row] macroattr] objectForKey:@"EXTRA"]);
	
	NSLog(@"changing macro state %@: current %@", [[[macrolist objectAtIndex:indexPath.row] macroattr] objectForKey:@"EXTRA"], 
		  [[[macrolist objectAtIndex:indexPath.row] macroattr] objectForKey:@"RUNNING"]);
	
    // Configure the view for the selected state
	cell = [tableView cellForRowAtIndexPath:indexPath];
	UILabel *myLabel = (UILabel *)[cell viewWithTag:10];
	UIActivityIndicatorView *myActInd = (UIActivityIndicatorView *)[cell viewWithTag:11];
//	if ([[[[macrolist objectAtIndex:indexPath.row] macroattr] objectForKey:@"RUNNING"] isEqualToString:@"0"]) {
	if ([[macrolist objectAtIndex:indexPath.row] isRunning] == NO) {
		[myActInd startAnimating];
		NSLog(@"Send macro start");
		NSString *msg = @"<CONTROL KEY=\"MACRO\" COMMAND=\"run\" EXTRA=\"";
		msg = [msg stringByAppendingString:[myLabel text]];
		msg = [msg stringByAppendingString:@"\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
		[sendmsgs addObject:msg];
		[myServer sendmessage];
		NSLog(@"Messages pending in macrotableview: %d",[sendmsgs count]);
	} else {
		[myActInd stopAnimating];
		NSLog(@"Send macro stop");
		NSString *msg = @"<CONTROL KEY=\"MACRO\" COMMAND=\"complete\" EXTRA=\"";
		msg = [msg stringByAppendingString:[myLabel text]];
		msg = [msg stringByAppendingString:@"\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
		[sendmsgs addObject:msg];
		[myServer sendmessage];
		NSLog(@"Messages pending in macrotableview: %d",[sendmsgs count]);
	}
	
	//[self.tableView reloadData];
	
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView reloadData];
}

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

- (void)dealloc {
    [super dealloc];
}


@end

