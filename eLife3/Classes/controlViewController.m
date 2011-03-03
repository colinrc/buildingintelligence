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
// let's guess, this is a browser

// MEDIA PLAYER
// this is a media player
// runs windows media player in a window

// TRACK DETAILS
// seems to have 3 labels
// track album and artist
// seems to have image for cover art

#import "controlViewController.h"
#import "globalConfig.h"

@implementation controlViewController

@synthesize control_;
@synthesize currentControl_;
@synthesize current_row_;
@synthesize current_column_;
@synthesize remaining_items_;

UIColor* UIColorFromRGB(uint rgbValue) {
	float red = ((rgbValue & 0xFF0000) >> 16)/255.0;
	float green = ((rgbValue & 0xFF00) >> 8)/255.0;
	float blue = (rgbValue & 0xFF)/255.0;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

UIColor* UIColorFromRGBA(uint rgbaValue) {
	float red	= ((rgbaValue & 0xFF000000) >> 24) / 255.0;
	float green = ((rgbaValue & 0xFF0000) >> 16) / 255.0;
	float blue	= ((rgbaValue & 0xFF00) >> 8) / 255.0;
	float alpha	=  (rgbaValue & 0xFF) / 255.0;
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/** 
 Need to implement to create view manually...
 */
- (void)loadView {
	self.view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 1024)];
	self.view.backgroundColor = UIColorFromRGB(0x476390);
	self.current_row_ = 0;
	self.current_column_ = 0;
	self.remaining_items_ = 0;
}

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


/**
 Implement to do the controlType layout after loading the view above.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	self.currentControl_ = [[globalConfig sharedInstance].uicontrols_ getControlRows:control_.type_ ];
	// TODO: loop through the control rows adding them to the view 
	// if the case statements for the rows mean they are visible
	for (controlRow* row in currentControl_) {
		if (![self evaluateCases:row.cases_]) 
			continue;
		remaining_items_ = [row.items_ count];
		for (NSDictionary* item in row.items_) {
			switch ([row getItemType:[item objectForKey:@"type"]]) {
				case label:
				{
					[self addLabel:item];
				}
					break;
				case picker:
					break;
				case slider:
				{
					[self addSlider:item];
				}
					break;
				case button:
				{
					[self addButton:item];
				}
					break;
				case toggle:
					break;
				case toggled:
					break;
				case video:
					break;
				case browser:
					break;
				case mediaPlayer:
					break;
				case trackDetails:
					break;
				case space:
					break;
				default:
					break;
			}
			remaining_items_--;
		}
		[self nextRow];
	}
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}


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

/**
 The control version of CR/LF, we increment the row
 and reset the column
 */
-(void) nextRow {
	current_row_++;
	current_column_ = 0;
}
/**
 Test the case string against the current control
 and see if we need to show the row
 */
-(Boolean)evaluateCases:(NSString *)cases {
	
	// TODO: need to do the string mangling
	return YES;
}
/**
 Gets the items bounding rectangle based on the width 
 attribute in the XML as a percent of the screen width
 TODO: fix for screen rotation
 */
- (CGRect) getItemRect: (NSString*) widthStr {
	int screen_width = 320;
	
	int percentage = [widthStr intValue];
	if (percentage == 0) {
		percentage = (100 - current_column_) / remaining_items_;
	}
	int top = current_row_ * 50 + 1;
	int left = 1 + current_column_* screen_width / 100;
	int height = 48;
	int width = ((screen_width * percentage) / 100) - 2;
	current_column_ += percentage;
	return CGRectMake(left, top, width, height);
}

/**
 Add a label item
 */
- (void) addLabel: (NSDictionary*)labelDict {
	
	NSString* state = [control_ stateFor:@"state"];
	if (state == nil) {
		state = [labelDict objectForKey: @"defaultState"];
	}
	
	NSString* value = [control_ stateFor:@"on"];
	if (value == nil) {
		value = [labelDict objectForKey:@"defaultValue"];
	}
	NSString* src = [control_ stateFor:@"src"];
	
	NSString* labelString = [labelDict objectForKey:@"formats"];
	if (labelString == nil) {
		labelString = @"%name% ";
		if (state != nil) labelString = [labelString stringByAppendingString:@"(%state%)"];
	}
	
	// the format string label thing
	if (control_.name_ != nil)
		labelString = [labelString stringByReplacingOccurrencesOfString:@"%name%" withString:control_.name_];
	if (state != nil)
		labelString = [labelString stringByReplacingOccurrencesOfString:@"%state%" withString:state];
	if (value != nil)
		labelString = [labelString stringByReplacingOccurrencesOfString:@"%value%" withString:value];
	if (src != nil)
		labelString = [labelString stringByReplacingOccurrencesOfString:@"%src%" withString:src];
	
	UILabel *myLabel = [[UILabel alloc] initWithFrame:[self getItemRect:[labelDict objectForKey:@"width"]]];
	myLabel.text = labelString;
	myLabel.textAlignment = UITextAlignmentCenter;
	myLabel.backgroundColor = UIColorFromRGB(0x7C90B0);
	[self.view addSubview:myLabel];
}
/**
 Adds a slider to the control
 */
-(void) addSlider:(NSDictionary *)labelDict {
	NSArray* icons = [[labelDict objectForKey:@"icons"] componentsSeparatedByString:@","];
	// TODO: make a custom slider that uses the icon values
	UISlider *mySlider = [[UISlider alloc] initWithFrame:[self getItemRect:[labelDict objectForKey:@"width"]]];
	mySlider.maximumValue = 100;
	mySlider.minimumValue = 0;
	mySlider.value = [[control_ stateFor:@"value"] intValue];
	mySlider.backgroundColor = UIColorFromRGB(0x7C90B0);
	[self.view addSubview:mySlider];
}
/**
 Adds a button to the control 
 */
-(void) addButton:(NSDictionary *)labelDict {
	
	UIButton *myButton = [[UIButton alloc] initWithFrame:[self getItemRect:[labelDict objectForKey:@"width"]]];
	NSString* iconStr = [labelDict objectForKey:@"icon"];
	if (iconStr != nil) {
		UIImage* icon = [UIImage imageNamed:[iconStr stringByAppendingString:@".png"]];
		if (icon != nil){
			[myButton setImage:icon forState:UIControlStateNormal];
		}
	}
	NSString* labelStr = [labelDict objectForKey:@"label"];
	if (labelStr != nil) {
		[myButton setTitle:labelStr forState:UIControlStateNormal];
	}
	
	myButton.backgroundColor = UIColorFromRGB(0x7C90B0);
	[self.view addSubview:myButton];
}
/**
 Adds a toggle to the control 
 */
-(void) addToggle:(NSDictionary *)labelDict {
	
	UIButton *myButton = [[UIButton alloc] initWithFrame:[self getItemRect:[labelDict objectForKey:@"width"]]];
	NSArray* icons = [[labelDict objectForKey:@"icons"] componentsSeparatedByString:@","];
	if (icons != nil) {
		NSString* iconStr = [icons objectAtIndex:0];
		if (iconStr != nil) {
			UIImage* icon = [UIImage imageNamed:[iconStr stringByAppendingString:@".png"]];
			if (icon != nil){
				[myButton setImage:icon forState:UIControlStateNormal];
			}
		}
	}
	NSString* labelStr = [labelDict objectForKey:@"label"];
	if (labelStr != nil) {
		[myButton setTitle:labelStr forState:UIControlStateNormal];
	}
	
	myButton.backgroundColor = UIColorFromRGB(0x7C90B0);
	[self.view addSubview:myButton];
}

@end
