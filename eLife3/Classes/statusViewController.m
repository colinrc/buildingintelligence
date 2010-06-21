//
//  statusViewController.m
//  eLife3
//
//  Created by Cameron Humphries on 14/01/10.
//  Copyright 2010 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "statusViewController.h"
#import "Control.h"
#import "controlMap.h"
#import "statusGroup.h"
#import "statusGroupMap.h"
#import "eLife3AppDelegate.h"

@implementation statusViewController


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
	
	
    return self;
}

// called at load into memory, good place to alloc stuff
- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	 // register with all of the controls for update notifications
	 NSString *currentKey;
	 for (currentKey in [statusGroupMap sharedInstance].group_data_ )
	 {
		 NSString* currentControl;
		 for (currentControl in [[statusGroupMap sharedInstance].group_data_ objectForKey:currentKey])
		 {
			 if (currentControl != nil)
				 [self registerWithNotification:[currentControl stringByAppendingString:@"_status"]];
		 }
	 }
 }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
}


#pragma mark Table view methods

// get the number of groups
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	int i = [[statusGroupMap sharedInstance].group_names_ count];
//	NSLog(@"help me I cant take it %i", i);
	return i;
}
// get the group heading
// TODO: think about the memory managment here
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	@try {
		statusGroup *tmpGroup = [[statusGroupMap sharedInstance].group_names_ objectAtIndex:section];
		return tmpGroup.name_;
	}
	@catch (NSException * e) {
		NSLog(@"tried to index out of the array");
	}
	return @"";
}

// Get the number of showing items for this group
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[statusGroupMap sharedInstance]activeItems:section];
}

/*
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return 1;
}
*/
/*
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
 return nil;
 }
*/
/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}
*/
/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return nil;
}
*/

// Put the individual items into the groups
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Set up the cell...
	
	// get the status group
	statusGroup *status_group = [[statusGroupMap sharedInstance] getGroup:indexPath.section];
	if (status_group != nil)
	{
		// get the control
		Control *control = [[statusGroupMap sharedInstance] activeControl:indexPath.section:indexPath.row];
		// if we can't find the control make the row blank
		if (control != nil)
		{	
			// set the text
			UILabel *myLabel = (UILabel *)[cell textLabel];
			myLabel.text = control.name_;
			
			// set the icon
			UIImageView *myIcon = [cell imageView];
			myIcon.image = [UIImage imageNamed:[status_group.icon_ stringByAppendingString:@".png"]];
		}
	}	
	return cell;
}

// handle a row selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	// get the status group
	statusGroup *status_group = [[statusGroupMap sharedInstance] getGroup:indexPath.section];
	if (status_group != nil)
	{
		// get the control
		Control *control = [[statusGroupMap sharedInstance] activeControl:indexPath.section:indexPath.row];
		if (control != nil)
		{
			// send off message
			NSString *msg = @"<CONTROL KEY=\"";
			msg = [msg stringByAppendingString:control.key_];
			msg = [msg stringByAppendingString:@"\" COMMAND=\"off\" EXTRA=\"\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
			eLife3AppDelegate *elifeappdelegate = (eLife3AppDelegate *)[[UIApplication sharedApplication] delegate];

			[elifeappdelegate.elifeSvrConn sendmessage:msg];
		}
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

- (void)registerWithNotification:(NSString *)thekey {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusUpdate:) name:thekey object:nil];
}

- (void)statusUpdate:(NSNotification *)notification {
	[self.tableView setNeedsDisplay];
	[self.tableView reloadData];
}


- (void)dealloc {
    [super dealloc];
}

@end

