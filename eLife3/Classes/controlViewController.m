//
//  controlViewController.m
//  eLife3
//
//  Created by Richard Lemon on 17/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

// LABEL
// is a text label, with dynamic content and format
// can have 3 state variables attached as string replacements,
// on, state, src
// and has the name variable

// PICKER
// is a list choice control
// can have actions attached to each list item
// has scroll up/down buttons 

// SLIDER
// a slider control with range 1..100
// has icons for on off buttons
// can alpha on button icon by % for drag item

// BUTTON / TOGGLE
// on off button with 2 modes toggle or button
// toggle mode allows for 2 commands depending on
// current state
// also seems to have a startStop mode, similar to 
// toggle but with a step amount e.g.
// <item commands="tilt,tilt" width="34" extras="up,20|stop," icon="up-arrow" type="button" mode="startStop"/> 

// TOGGLED
// cant figure this one out yet..?

// VIDEO
// shows a video from what I can tell
// does the live jpg cameras
// height width, src, format and refresh rate

// BROWSER
// lets guess, this is a browser

// MEDIA PLAYER
// this is a media player
// runs windows media player in a window

// TRACK DETAILS
// seems to have 3 labels
// track album and artist
// seems to have image for cover art

#import "controlViewController.h"


@implementation controlViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
