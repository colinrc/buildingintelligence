//
//  roomViewController.m
//  eLife3
//
//  Created by Richard Lemon on 9/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "roomViewController.h"
#import "eLife3AppDelegate.h"
#import "zoneList.h"
#import "Room.h"
#import "eLife3AppDelegate.h"
#import "controlViewController.h"


@implementation roomViewController

@synthesize room_;
@synthesize sliderCell_;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	// network change notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkUpdate:) name:@"networkChange:" object:nil];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	// subscribe to the control notifications...
	
	for (int index = 0 ; index  < [room_ tabCount] ; index++  )
	{
		NSMutableArray* currentTab = [room_ tabForIndex:index];
		for (Control* currentControl in currentTab)
		{
				[self registerWithNotification:[currentControl.key_ stringByAppendingString:@"_status"]];
		}
	}
	
	// set the network state icon
	eLife3AppDelegate *elifeappdelegate = (eLife3AppDelegate *)[[UIApplication sharedApplication] delegate];
	[elifeappdelegate networkUpdate:self];
}
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
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
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [room_ tabCount];
}
/**
 get the group heading
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return [room_ tabNameForIndex:section];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [room_ itemCountForTabIndex:section];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *PlainCellIdentifier  = @"Cell";
    static NSString *OnOffCellIdentifier  = @"OnOffCell";
    static NSString *SliderCellIdentifier = @"sliderCell";
    NSString *CellIdentifier = PlainCellIdentifier;
	
	Boolean isSlider = NO;
	Boolean isOnOff = NO;
	
    // Configure the cell...
	Control* tmpControl = [room_ itemForIndex:indexPath.section :indexPath.row];
    if (tmpControl != nil)
	{
		if ([tmpControl.type_ isEqualToString:@"onOff"]) {
			isOnOff = YES;
			CellIdentifier = OnOffCellIdentifier;
		} 
		else if ([tmpControl.type_ isEqualToString:@"slider"]) {
			isSlider = YES;
			CellIdentifier = SliderCellIdentifier;
		}
	}
	// if we aren't claimed were a plain control
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if (isOnOff) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			// if we are on off add a sliding switch?
			UISwitch* onOff = [[UISwitch alloc] initWithFrame:CGRectMake(0,0,32,32)];
			onOff.tag = (indexPath.section << 8) + indexPath.row;
			cell.accessoryView = onOff;
		}
/*		else if (isSlider) 
		{
			[[NSBundle mainBundle] loadNibNamed:@"sliderCell" owner:self options:nil];
			cell = sliderCell_;
			self.sliderCell_ = nil;
		}
*/		else { // isPlain
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}

    }
    
	if (isOnOff)
	{
		UISwitch* onOff = (UISwitch*) cell.accessoryView;
		onOff.on = [tmpControl.command_ isEqualToString:@"on"];
		UILabel *label = (UILabel*) [cell textLabel];
		label.text = tmpControl.name_;
		[onOff addTarget:self action:@selector(onOffChanged:) forControlEvents:UIControlEventValueChanged];
/*	} else if (isSlider) {
		// now we can add some stuff to our custom cell
		UILabel *label =  (UILabel *)[cell viewWithTag:1];
		label.text = tmpControl.name_;
		UISlider* slider = (UISlider*)[cell viewWithTag:2];
		slider.tag = (indexPath.section << 8) + indexPath.row;
		slider.value = [tmpControl.extra_ intValue];
		[slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
		
*/	} else {
		UILabel *label = (UILabel*) [cell textLabel];
		label.text = tmpControl.name_;
		// we are going to want to make a special window
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	
	// if we are audio add a |< [] |> >|
	
    return cell;
}

-(void)onOffChanged:(id)sender {
	NSUInteger tag = [sender tag];
	NSUInteger section = tag >> 8;
	NSUInteger row = tag & 0xFF;
	NSLog(@"section= %i row = %i",section, row);
	Control* tmpControl = [room_ itemForIndex:section :row];
    if (tmpControl != nil)
	{
		UISwitch *onOff = (UISwitch*) sender;
		NSLog(@"switch is %i",onOff.on);
		Command *myCommand = [[Command alloc] init];
		myCommand.key_ = tmpControl.key_;
		myCommand.command_ = (onOff.on)? @"on" : @"off";
		eLife3AppDelegate *elifeappdelegate = (eLife3AppDelegate *)[[UIApplication sharedApplication] delegate];
		[elifeappdelegate.elifeSvrConn sendCommand:myCommand];
		[myCommand release];
		
	}
}

-(void)sliderChanged:(id)sender {
	NSUInteger tag = [sender tag];
	NSUInteger section = tag >> 8;
	NSUInteger row = tag & 0xFF;
	NSLog(@"section= %i row = %i",section, row);
	Control* tmpControl = [room_ itemForIndex:section :row];
    if (tmpControl != nil)
	{
		UISlider *slider = (UISlider*)sender;
		NSLog(@"slider is %2.0f",slider.value);
		Command *myCommand = [[Command alloc] init];
		myCommand.key_ = tmpControl.key_;
		myCommand.command_ = (slider.value > 1.0)? @"on" : @"off";
		if (slider.value > 1.0)
			myCommand.extra_ = [NSString stringWithFormat:@"%2.0f", slider.value];
		eLife3AppDelegate *elifeappdelegate = (eLife3AppDelegate *)[[UIApplication sharedApplication] delegate];
		[elifeappdelegate.elifeSvrConn sendCommand:myCommand];
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
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Navigation logic may go here. Create and push another view controller.
    /*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	Control* tmpControl = [room_ itemForIndex:indexPath.section :indexPath.row];
    if (tmpControl == nil)
		return; // cant get a control bail
	if ([tmpControl.type_ isEqualToString:@"onOff"])
			return; // already handle this
//	if ([tmpControl.type_ isEqualToString:@"slider"])
//			return; // already handle this
	
	// if we are here we need to look at going to a new page
	// and building some sort of crazy control as per the XML
	controlViewController *viewController = [controlViewController alloc];
	viewController.control_ = tmpControl;
	// TODO: add control info to view
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 Register for notification for this control key
 */
- (void)registerWithNotification:(NSString *)thekey {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusUpdate:) name:thekey object:nil];
}
/**
 Got update for control, reshow the table
 */
- (void)statusUpdate:(NSNotification *)notification {
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
 Std destructor type thingie that is used to release stuff as we get clobbered
 */
- (void)dealloc {
    [super dealloc];
}


@end

