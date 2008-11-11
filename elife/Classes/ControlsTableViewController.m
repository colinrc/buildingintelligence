//
//  ControlsTableViewController.m
//  elife
//
//  Created by Cameron Humphries on 8/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "ControlsTableViewController.h"
#import "elifeAppDelegate.h"
#import "elifezone.h"
#import "eliferoom.h"
#import "eliferoomtab.h"
#import "eliferoomcontrol.h"
#import "elifecontroltypes.h"
#import "elifecontroltypeitem.h"
#import "ControlOnOffCellView.h"
#import "ControlLabelCellView.h"
#import "ControlBtnSliderBtnCellView.h"
#import "ControlBtnBtnCellView.h"
#import "ControlWebCellView.h"
#import "ControlBtnBtnBtnCellView.h"
#import "ControlBtnBtnBtnBtnCellView.h"
#import "ControlTglBtnBtnCellView.h"
#import "ControlBtnBtnBtnBtnBtnCellView.h"

@implementation ControlsTableViewController
@synthesize zoneidx;
@synthesize roomidx;
@synthesize tabidx;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	
    return [thetab.controllist count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:section];
	elifecontroltypes *thecontroltype;
	NSString *controltypeid = [thecontrol.roomctrlattr objectForKey:@"type"];
	NSLog(@"in section %d, type=%@",section,controltypeid);
	
	NSInteger i=0;
	BOOL found=NO;
	NSLog(@"controltype count %d",[elifeappdelegate.elifectrltypes count]);
	while ((i < [elifeappdelegate.elifectrltypes count]) && !found) {
		NSLog(@"top of loop i=%d",i);
		thecontroltype = [elifeappdelegate.elifectrltypes objectAtIndex:i];
		if ([controltypeid isEqualToString:[thecontroltype controltype]]) {
			found=YES;
			NSLog(@"found a match");
		} else {
			i++;
			NSLog(@"Tested %@, setting i=%d",[thecontroltype controltype],i);
		}
	}

	if (found) {
		NSLog(@"return %d rows",[thecontroltype.displayrows count]);
		return [thecontroltype.displayrows count];
	} else {
		return 1;
	}
	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:indexPath.section];
	elifecontroltypes *thecontroltype;
	NSString *controltypeid = [thecontrol.roomctrlattr objectForKey:@"type"];
	NSLog(@"in cellForRowAtIndexPath section %d, type=%@",indexPath.section,controltypeid);
	
	NSInteger i=0;
	BOOL found=NO;
	NSLog(@"controltype count %d",[elifeappdelegate.elifectrltypes count]);
	while ((i < [elifeappdelegate.elifectrltypes count]) && !found) {
		NSLog(@"top of loop i=%d",i);
		thecontroltype = [elifeappdelegate.elifectrltypes objectAtIndex:i];
		if ([controltypeid isEqualToString:[thecontroltype controltype]]) {
			found=YES;
			NSLog(@"found a match");
		} else {
			i++;
			NSLog(@"Tested %@, setting i=%d",[thecontroltype controltype],i);
		}
	}
    
	if ([controltypeid isEqualToString:@"onOff"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			ControlLabelCellView *cell = (ControlLabelCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlLabelCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlLabelCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			cell.label.text = thecontrol.name;
			return cell;
		} else {
			ControlOnOffCellView *cell = (ControlOnOffCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlOnOffCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlOnOffCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlOnOffCellView"] autorelease];
			}
			// Configure the cell label
			cell.ctrllabel.text = thecontrol.name;
			// Configure the cell icon
			//cell.ctrlicon.image = [UIImage imageNamed:[[activetab.tabattr objectForKey:@"icon"] stringByAppendingString:@".png"]];
			cell.ctrlicon.image = [UIImage imageNamed:@"light-bulb.png"];
			return cell;
			
		}
	} else if ([controltypeid isEqualToString:@"slider"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			ControlLabelCellView *cell = (ControlLabelCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlLabelCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlLabelCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			cell.label.text = thecontrol.name;
			return cell;
		} else {
			ControlBtnSliderBtnCellView *cell = (ControlBtnSliderBtnCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlBtnSliderBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlBtnSliderBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlBtnSliderBtnCellView"] autorelease];
			}
			// Configure the cell
			[cell.btn1 setTitle:@"Off" forState:UIControlStateNormal];
			[cell.btn2 setTitle:@"On" forState:UIControlStateNormal];
			return cell;
			
		}
			
	} else if ([controltypeid isEqualToString:@"upDown"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			ControlLabelCellView *cell = (ControlLabelCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlLabelCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlLabelCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			cell.label.text = thecontrol.name;
			return cell;
		} else {
			ControlBtnBtnCellView *cell = (ControlBtnBtnCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlBtnBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlBtnBtnCellView"] autorelease];
			}
			// Configure the cell
			//cell.btn1.text=@"Off";
			//cell.btn2.text=@"On";
			return cell;
			
		}
	} else if ([controltypeid isEqualToString:@"miniBrowser"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			ControlBtnBtnBtnCellView *cell = (ControlBtnBtnBtnCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlBtnBtnBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlBtnBtnBtnCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			//cell.label.text = thecontrol.name;
			return cell;
		} else {
			ControlWebCellView *cell = (ControlWebCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlWebCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlWebCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlWebCellView"] autorelease];
			}
			// Configure the cell
			//cell.btn1.text=@"Off";
			//cell.btn2.text=@"On";
			return cell;
			
		}
	} else if ([controltypeid isEqualToString:@"audioPanel"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			ControlLabelCellView *cell = (ControlLabelCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlLabelCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlLabelCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			cell.label.text = thecontrol.name;
			return cell;
		} else if (indexPath.row == 1) {
			ControlTglBtnBtnCellView *cell = (ControlTglBtnBtnCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlTglBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlTglBtnBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlTglBtnBtnCellView"] autorelease];
			}
			// Configure the cell
			[cell.toggle setImage:[UIImage imageNamed:@"power-red.png"] forState:UIControlStateNormal];
			[cell.btn1 setImage:[UIImage imageNamed:@"volume-up.png"] forState:UIControlStateNormal];
			[cell.btn2 setImage:[UIImage imageNamed:@"volume-down.png"] forState:UIControlStateNormal];

			return cell;
		} else if (indexPath.row == 2) {
			ControlBtnBtnBtnBtnBtnCellView *cell = (ControlBtnBtnBtnBtnBtnCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlBtnBtnBtnBtnBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlBtnBtnBtnBtnBtnCellView"] autorelease];
			}
			// Configure the cell
			[cell.btn1 setImage:[UIImage imageNamed:@"cd-music.png"] forState:UIControlStateNormal];
			[cell.btn2 setImage:[UIImage imageNamed:@"cd-music.png"] forState:UIControlStateNormal];
			[cell.btn3 setImage:[UIImage imageNamed:@"radio.png"] forState:UIControlStateNormal];
			[cell.btn4 setImage:[UIImage imageNamed:@"atom.png"] forState:UIControlStateNormal];
			[cell.btn5 setImage:[UIImage imageNamed:@"tv.png"] forState:UIControlStateNormal];

			return cell;			
		} else if (indexPath.row == 3) {
			ControlBtnBtnBtnBtnBtnCellView *cell = (ControlBtnBtnBtnBtnBtnCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlBtnBtnBtnBtnBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlBtnBtnBtnBtnBtnCellView"] autorelease];
			}
			// Configure the cell
			[cell.btn1 setImage:[UIImage imageNamed:@"media-play.png"] forState:UIControlStateNormal];
			[cell.btn2 setImage:[UIImage imageNamed:@"media-stop.png"] forState:UIControlStateNormal];
			[cell.btn3 setImage:[UIImage imageNamed:@"media-pause.png"] forState:UIControlStateNormal];
			[cell.btn4 setImage:[UIImage imageNamed:@"media-rwd.png"] forState:UIControlStateNormal];
			[cell.btn5 setImage:[UIImage imageNamed:@"media-fwd.png"] forState:UIControlStateNormal];

			return cell;			
		} else if (indexPath.row == 4) {
			ControlBtnBtnBtnBtnCellView *cell = (ControlBtnBtnBtnBtnCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlBtnBtnBtnBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlBtnBtnBtnBtnCellView"] autorelease];
			}
			// Configure the cell
			[cell.btn1 setImage:[UIImage imageNamed:@"left-arrow.png"] forState:UIControlStateNormal];
			[cell.btn2 setImage:[UIImage imageNamed:@"right-arrow.png"] forState:UIControlStateNormal];
			[cell.btn3 setImage:[UIImage imageNamed:@"up-arrow.png"] forState:UIControlStateNormal];
			[cell.btn4 setImage:[UIImage imageNamed:@"down-arrow.png"] forState:UIControlStateNormal];

			return cell;			
		} else if (indexPath.row == 5) {
			ControlBtnBtnCellView *cell = (ControlBtnBtnCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlBtnBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlBtnBtnCellView"] autorelease];
			}
			// Configure the cell
			[cell.btn1 setImage:[UIImage imageNamed:@"media-play.png"] forState:UIControlStateNormal];
			[cell.btn2 setImage:[UIImage imageNamed:@"media-stop.png"] forState:UIControlStateNormal];

			return cell;
		}
	} else if ([controltypeid isEqualToString:@"tvControl"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			ControlLabelCellView *cell = (ControlLabelCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlLabelCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlLabelCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			cell.label.text = thecontrol.name;
			return cell;
		} else if (indexPath.row == 1) {
			ControlTglBtnBtnCellView *cell = (ControlTglBtnBtnCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlTglBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlTglBtnBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlTglBtnBtnCellView"] autorelease];
			}
			// Configure the cell
			[cell.toggle setImage:[UIImage imageNamed:@"power-red.png"] forState:UIControlStateNormal];
			[cell.btn1 setImage:[UIImage imageNamed:@"volume-up.png"] forState:UIControlStateNormal];
			[cell.btn2 setImage:[UIImage imageNamed:@"volume-down.png"] forState:UIControlStateNormal];

			return cell;			
		} else if (indexPath.row == 2) {
			ControlBtnBtnBtnBtnBtnCellView *cell = (ControlBtnBtnBtnBtnBtnCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlBtnBtnBtnBtnBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlBtnBtnBtnBtnBtnCellView"] autorelease];
			}
			// Configure the cell
			[cell.btn1 setImage:[UIImage imageNamed:@"chan-abc.png"] forState:UIControlStateNormal];
			[cell.btn2 setImage:[UIImage imageNamed:@"chan-sbs.png"] forState:UIControlStateNormal];
			[cell.btn3 setImage:[UIImage imageNamed:@"chan-win.png"] forState:UIControlStateNormal];
			[cell.btn4 setImage:[UIImage imageNamed:@"chan-prime.png"] forState:UIControlStateNormal];
			[cell.btn5 setImage:[UIImage imageNamed:@"chan-10.png"] forState:UIControlStateNormal];

			//cell.btn1.text=@"Off";
			//cell.btn2.text=@"On";
			return cell;
			
		}
	} else if ([controltypeid isEqualToString:@"rawKeyPad"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			ControlLabelCellView *cell = (ControlLabelCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlLabelCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlLabelCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			cell.label.text = thecontrol.name;
			return cell;
		} else {
			ControlBtnSliderBtnCellView *cell = (ControlBtnSliderBtnCellView *)[tableView dequeueReusableCellWithIdentifier:@"ControlBtnSliderBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				cell = [[[ControlBtnSliderBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlBtnSliderBtnCellView"] autorelease];
			}
			// Configure the cell
			//cell.btn1.text=@"Off";
			//cell.btn2.text=@"On";
			return cell;
			
		}
	} else {
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"Cell"] autorelease];
		}
		// Configure the cell
		cell.text = thecontrol.name;
		
		return cell;
	}
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];

	//NSLog(@"Pressed control %@", [[thetab.controllist objectAtIndex:indexPath.row] name]);
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

- (void)dealloc {
    [super dealloc];
}


@end

