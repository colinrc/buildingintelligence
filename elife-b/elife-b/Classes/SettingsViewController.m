//
//  SettingsViewController.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController
@synthesize localserverip;
@synthesize localserverport;
@synthesize localconfigname;

// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	// Grab values from system prefs
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  
	NSString *elifehost = [userDefaults stringForKey:@"local_server_ip"];  
	NSString *elifeport = [userDefaults stringForKey:@"local_server_port"];
	NSString *defconfig = [userDefaults stringForKey:@"config_file"];	
	[self.localserverip setText:elifehost];
	[self.localserverport setText:elifeport];
	[self.localconfigname setText:defconfig];
	
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

- (IBAction)finishEdit:(id)sender {
	UITextField *mytextField = (UITextField *)sender;
	// close keyboard
	[mytextField resignFirstResponder];
	
	// save userprefs
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  
	if (mytextField.tag == 2) {
		[userDefaults setObject:mytextField.text forKey:@"local_server_ip"];
	} else if (mytextField.tag == 3) {
		[userDefaults setObject:mytextField.text forKey:@"local_server_port"];
	} else if (mytextField == 4) {
		[userDefaults setObject:mytextField.text forKey:@"config_file"];
	}
	
	
}

@end
