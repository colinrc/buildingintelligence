//
//  MacrosTableViewController.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "MacrosTableViewController.h"
#import "MacroCellView.h"

@implementation MacrosTableViewController
@synthesize macrolist;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
	self.macrolist = [[NSMutableArray alloc] init];
	
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
    return [macrolist count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString *thename = [[macrolist objectAtIndex:indexPath.row] name];
	NSString *thekey = [[macrolist objectAtIndex:indexPath.row] key];
	NSInteger thestatus = [[macrolist objectAtIndex:indexPath.row] status];
    
    MacroCellView *cell = (MacroCellView *)[tableView dequeueReusableCellWithIdentifier:@"MacroCellView"];
    if (cell == nil) {
		NSLog(@"no reuseable cell available");
		cell = [[[MacroCellView alloc] initWithFrame:CGRectZero reuseIdentifier:thekey] autorelease];
    }
    // Configure the cell
	cell.macroLabel.text = thename;
	if (thestatus == 1) {
		[cell.macroprogress startAnimating];
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Send message to elife server to start running macro
	// for now just use NSLog to show selection worked
	ElifeMacro *mymacro = [macrolist objectAtIndex:indexPath.row];
	NSLog(@"Macro %s selected", [[mymacro key] UTF8String]);
	
	NSLog(@"changing macro state %@: current %d", mymacro.key, mymacro.status);
	
    // Configure the view for the selected state
	MacroCellView *selectedcell = (MacroCellView *)[tableView cellForRowAtIndexPath:indexPath];
	if (mymacro.status == 1) {
		[[selectedcell macroprogress] stopAnimating];
		mymacro.status = 0;
	} else {
		[[selectedcell macroprogress] startAnimating];
		mymacro.status = 1;
	}
	NSLog(@"new status %d",mymacro.status);
	
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

//Append macro to the list of defined macros
- (void)addMacro:(ElifeMacro *)newmacro {
	[macrolist addObject:newmacro];
}

- (void)dealloc {
    [super dealloc];
}


@end

