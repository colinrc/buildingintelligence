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
@synthesize remote_refresh_rate;

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
	elifesvrport.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	elifesvrport.delegate = self;

	config_file = [[UITextField alloc] init];
	config_file.text = [defaults objectForKey:@"config_file"];
	config_file.returnKeyType = UIReturnKeyDone;
	config_file.keyboardType = UIKeyboardTypeAlphabet;
	config_file.delegate = self;

	config_port = [[UITextField alloc] init];
	config_port.text = [defaults objectForKey:@"config_port"];
	config_port.returnKeyType = UIReturnKeyDone;
	config_port.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	config_port.delegate = self;

	remote_server_url = [[UITextField alloc] init];
	remote_server_url.text = [defaults objectForKey:@"remote_server_url"];
	remote_server_url.returnKeyType = UIReturnKeyDone;
	remote_server_url.keyboardType = UIKeyboardTypeURL;
	remote_server_url.delegate = self;
	
	remote_refresh_rate = [[UITextField alloc] init];
	remote_refresh_rate.text = [defaults objectForKey:@"remote_refresh_rate"];
	remote_refresh_rate.returnKeyType = UIReturnKeyDone;
	remote_refresh_rate.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	remote_refresh_rate.delegate = self;
	
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
	[[NSNotificationCenter defaultCenter] postNotificationName:@"elife_settings_start" object:self];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
//											name:UIKeyboardWillHideNotification object:nil];
}
// Get any changes to user settings and save them.
- (void)viewWillDisappear:(BOOL)animated {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:elifesvr.text forKey:@"elifesvr"];
	[defaults setObject:elifesvrport.text forKey:@"elifesvrport"];
	[defaults setObject:config_file.text forKey:@"config_file"];
	[defaults setObject:config_port.text forKey:@"config_port"];
	[defaults setObject:remote_server_url.text forKey:@"remote_server_url"];
	[defaults setObject:remote_refresh_rate.text forKey:@"remote_refresh_rate"];
	[defaults synchronize];

	// TODO: set some dirty bit so we know if there has been any changes
	// notify everyone the config editing is done
	[[NSNotificationCenter defaultCenter] postNotificationName:@"elife_settings_end" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
	[remote_refresh_rate release];
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
			case 1:
				return @"Update rate";
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
			default:
				return self.remote_server_url; // next in line
		}
	}
	else if (indexPath.section == 1)
	{
		// server remote settings
		switch (indexPath.row) {
			case 0:
				return self.remote_server_url;
				break;
			case 1:
			default:
				return self.remote_refresh_rate;
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
			return 2;
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
	detailLabel.textAlignment = UITextAlignmentLeft;
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
	UILabel *textLabel = [cell textLabel];
	
//	CGRect cellFrame = [cell frame];
	CGRect textFrame = [textLabel frame]; // the existing frame 
//	CGRect detailFrame = [detailLabel frame];
	CGRect tmpFrame = textFrame;
	tmpFrame.origin.x = textFrame.size.width + textFrame.origin.x + 10;
	tmpFrame.size.width = 290 - tmpFrame.origin.x; // space for the cursor
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
	
	if (tmpView != nil) {
		detailLabel.text = tmpView.text; 
		cell.accessoryView = nil;
	}

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

// Get the next logical indexPath, if last return self
-(NSIndexPath *)indexPathForNextRow {
	NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
	NSIndexPath * tmp = nil;
	if (indexPath != nil) {
		if (indexPath.section == 0){
			switch (indexPath.row) {
				case 0:
				case 1:
				case 2:
					tmp  =  [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
					[tmp retain];
					break;
				default:
					tmp  =  [NSIndexPath indexPathForRow:0 inSection:indexPath.section + 1];
					[tmp retain];
					break;
			}

		} else if (indexPath.section == 1){
			switch (indexPath.row) {
				case 0:
				case 1:
				default:
					tmp  =  [NSIndexPath indexPathForRow:1 inSection:indexPath.section];
					[tmp retain];
					break;
			}
		}
		return [tmp autorelease];
	}
	return nil;
}
// Handle the enter key. Dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];

	// want to handle the hiding of the edit cells
	NSIndexPath * indexPath = [self indexPathForNextRow];
	if (indexPath != nil) {
		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
		[self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
	}

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
