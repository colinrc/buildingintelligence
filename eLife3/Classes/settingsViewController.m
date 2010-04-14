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

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	elifesvr.text = [defaults objectForKey:@"elifesvr"];
	elifesvrport.text = [defaults objectForKey:@"elifesvrport"];
	
	[super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

// Get any changes to user settings and save them.
- (void)viewWillDisappear:(BOOL)animated {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:elifesvr.text forKey:@"elifesvr"];
	[defaults setObject:elifesvrport.text forKey:@"elifesvrport"];
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.elifesvr = nil;
	self.elifesvrport = nil;
}


- (void)dealloc {
	[elifesvr release];
	[elifesvrport release];
    [super dealloc];
}

// Pop down virtual keyboard
- (IBAction)textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
}

// Pop down virtual keyboard
- (IBAction)backgroundTap:(id)sender {
	[elifesvr resignFirstResponder];
	[elifesvrport resignFirstResponder];
}

@end
