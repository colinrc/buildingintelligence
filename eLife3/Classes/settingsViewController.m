//
//  settingsViewController.m
//  eLife3
//
//  Created by Cameron Humphries on 14/01/10.
//  Copyright 2010 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "settingsViewController.h"

@implementation settingsViewController

@synthesize elifesvr;
@synthesize elifesvrport;
@synthesize config_file;
@synthesize config_port;
@synthesize remote_server_url;

#pragma mark View methods
/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	elifesvr = [[UITextField alloc] init];
	elifesvr.text = [defaults objectForKey:@"elifesvr"];
	elifesvr.returnKeyType = UIReturnKeyDone;
	elifesvr.keyboardType = UIKeyboardTypeAlphabet;
	elifesvr.delegate = self;

	elifesvrport = [[UITextField alloc] init];
	elifesvrport.text = [defaults objectForKey:@"elifesvrport"];
	elifesvrport.returnKeyType = UIReturnKeyDone;
	elifesvrport.keyboardType = UIKeyboardTypeNumberPad;
	elifesvrport.delegate = self;

	config_file = [[UITextField alloc] init];
	config_file.text = [defaults objectForKey:@"config_file"];
	config_file.returnKeyType = UIReturnKeyDone;
	config_file.keyboardType = UIKeyboardTypeAlphabet;
	config_file.delegate = self;

	config_port = [[UITextField alloc] init];
	config_port.text = [defaults objectForKey:@"config_port"];
	config_port.returnKeyType = UIReturnKeyDone;
	config_port.keyboardType = UIKeyboardTypeNumberPad;
	config_port.delegate = self;

	remote_server_url = [[UITextField alloc] init];
	remote_server_url.text = [defaults objectForKey:@"remote_server_url"];
	remote_server_url.returnKeyType = UIReturnKeyDone;
	remote_server_url.keyboardType = UIKeyboardTypeURL;
	remote_server_url.delegate = self;

	[super viewDidLoad];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
// Called when the view is about to appear
- (void)viewWillAppear:(BOOL)animated {
	// notify everyone the config is being edited
	[[NSNotificationCenter defaultCenter] postNotificationName:@"elife_settings_start" object:nil];
	
}
// Get any changes to user settings and save them.
- (void)viewWillDisappear:(BOOL)animated {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:elifesvr.text forKey:@"elifesvr"];
	[defaults setObject:elifesvrport.text forKey:@"elifesvrport"];
	[defaults setObject:config_file.text forKey:@"config_file"];
	[defaults setObject:config_port.text forKey:@"config_port"];
	[defaults setObject:remote_server_url.text forKey:@"remote_server_url"];

	// notify everyone the config editing is done
	[[NSNotificationCenter defaultCenter] postNotificationName:@"elife_settings_end" object:nil];
	// animate off
	[super viewWillDisappear:animated];
}
// called when the little phone is struggling
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
// called when the controllers view is released from memory
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[elifesvr release];
	[elifesvrport release];
	[config_file release];
	[remote_server_url release];
}

#pragma mark Data source methods

// return the label for the section/row
-(NSString *) rowLabel:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0)
	{
		// server settings
		switch (indexPath.row) {
			case 0:
				return @"eLife Server Name/IP";
				break;
			case 1:
				return @"eLife Server Port";
				break;
			case 2:
				return @"Configuration Filename";
				break;
			case 3:
				return @"eLife Config Port";
				break;
		}
	}
	else if (indexPath.section == 1)
	{
		// server remote settings
		switch (indexPath.row) {
			case 0:
				return @"eLife Server URL";
				break;
		}				
	}
	
	return @"Error we don't have one of these!";
}
// returns the text edit control for this object
-(UITextField *) detailLabel:(NSIndexPath *)indexPath {

	if (indexPath.section == 0)
	{
		// server settings
		switch (indexPath.row) {
			case 0:
				return self.elifesvr;
				break;
			case 1:
				return self.elifesvrport;
				break;
			case 2:
				return self.config_file;
				break;
			case 3:
				return self.config_port;
				break;
		}
	}
	else if (indexPath.section == 1)
	{
		// server remote settings
		switch (indexPath.row) {
			case 0:
				return self.remote_server_url;
				break;
		}				
	}
	
	return nil;
}

#pragma mark Table view methods

// get the number of groups
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 22;
}
// get the group heading
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"eLife Server Settings";
			break;
		case 1:
			return @"eLife Remote Settings";
			break;
	}
	
	return @"";
}
// Get the number of showing items for this group
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 4;
			break;
		case 1:
			return 1;
			break;
	}
	return 0;
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	// cell text
	UILabel *label = [cell textLabel];
	label.text = [self rowLabel:indexPath];

	// cell edit field
	UILabel * detailLabel = [cell detailTextLabel];
	UITextField *tmpView = [self detailLabel:indexPath];
	detailLabel.text = tmpView.text;

	return cell;
}

// TODO: figure out when the keyboard is visible and the view has resized to do this...
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	return indexPath;
}
// handle a row selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITextField *tmpView = [self detailLabel:indexPath];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	UILabel *detailLabel = [cell detailTextLabel];
	
	CGRect tmpFrame = [detailLabel frame]; // the existing frame 
	tmpFrame.size.width += 3; // space for the cursor
	tmpView.frame = tmpFrame;
	tmpView.textColor = detailLabel.textColor;
	cell.accessoryView = tmpView;
	detailLabel.text = nil;
	
	[tableView addSubview:tmpView];
	[tmpView becomeFirstResponder];

	[tableView setNeedsDisplay];
}
// handle a row de-selection
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	UITextField *tmpView = (UITextField *) cell.accessoryView;
	UILabel *detailLabel = [cell detailTextLabel];
	
	detailLabel.text = tmpView.text; 
	cell.accessoryView = nil;

	[tableView setNeedsDisplay];
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

#pragma mark keyboard handling methods

// TODO: code keyboard handling

// Handle the enter key. Dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

/*
// show/hide scrolling
// start that scrolling...
-(void) keyboardWillShow:(NSNotification *)notification {
	NSLog(@"keyboard is on it's way");
	// need to check if we have to increase the scroll length
}
// and back to where we were
-(void) keyboardWillHide:(NSNotification *)notification {
	NSLog(@"keyboard is heading off");	
}
*/

#pragma mark Cleanup

- (void)dealloc {
	[elifesvr release];
	[elifesvrport release];
	[config_file release];
	[config_port release];
	[remote_server_url release];
    [super dealloc];
}


@end
