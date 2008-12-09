//
//  ControlsTableViewController.m
//  elife
//
//  Created by Cameron Humphries on 8/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "ControlsTableViewController.h"
#import "elife_bAppDelegate.h"
#import "elifezone.h"
#import "eliferoom.h"
#import "eliferoomtab.h"
#import "eliferoomcontrol.h"
#import "elifecontroltypes.h"
#import "elifecontroltypeitem.h"

@implementation ControlsTableViewController
@synthesize myCell;
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
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	
    return [thetab.controllist count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:indexPath.section];
	elifecontroltypes *thecontroltype;
	UITableViewCell *cell = nil;
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
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlLabelCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				//cell = [[[ControlLabelCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlLabelCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong with label");
				}
			}
			// Configure the cell label
			UILabel *myLabel = (UILabel *)[cell viewWithTag:11];
			myLabel.text = thecontrol.name;
			
			cell.tag = indexPath.section;
			return cell;
		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlOnOffCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlOnOffCellView" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				//cell = [[[ControlOnOffCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlOnOffCellView"] autorelease];
			}
			// Configure the cell label
			UILabel *myLabel = (UILabel *)[cell viewWithTag:11];
			myLabel.text = thecontrol.name;
			// Configure the cell icon
			UIImageView *myImage = (UIImageView *)[cell viewWithTag:10];
			NSArray *iconlist = [[thecontrol.roomctrlattr objectForKey:@"icons"] componentsSeparatedByString:@","];
			if ([thecontrol.command isEqualToString:@"off"]) {
				// use first icon
				myImage.image = [UIImage imageNamed:[[iconlist objectAtIndex:0] stringByAppendingString:@".png"]];
			} else {
				// use second icon
				myImage.image = [UIImage imageNamed:[[iconlist objectAtIndex:1] stringByAppendingString:@".png"]];
			}
						
			cell.tag = indexPath.section;
			NSLog(@"working section %d, row %d",indexPath.section,indexPath.row);

			return cell;
			
		}
	} else if ([controltypeid isEqualToString:@"slider"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlLabelCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				//cell = [[[ControlLabelCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlLabelCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			UILabel *myLabel = (UILabel *)[cell viewWithTag:11];
			myLabel.text = thecontrol.name;
			
			cell.tag = indexPath.section;

			return cell;			
		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnSliderBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				//cell = [[[ControlBtnSliderBtnCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlBtnSliderBtnCellView"] autorelease];
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnSliderBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
			}
			// Configure the cell
			// check for icons definition
			if ([thecontrol.roomctrlattr objectForKey:@"icons"] != nil) {
				// put icons on the buttons
				NSArray *iconlist = [[thecontrol.roomctrlattr objectForKey:@"icons"] componentsSeparatedByString:@","];
				UIButton *myBtn = (UIButton *)[cell viewWithTag:10];
				[myBtn setImage:[UIImage imageNamed:[[iconlist objectAtIndex:0] stringByAppendingString:@".png"]] forState:UIControlStateNormal];
				myBtn = (UIButton *)[cell viewWithTag:12];
				[myBtn setImage:[UIImage imageNamed:[[iconlist objectAtIndex:1] stringByAppendingString:@".png"]] forState:UIControlStateNormal];			
			} else {
				// use text labels on the buttons
				UIButton *myBtn = (UIButton *)[cell viewWithTag:10];
				[myBtn setTitle:@"Off" forState:UIControlStateNormal];
			
				myBtn = (UIButton *)[cell viewWithTag:12];
				[myBtn setTitle:@"On" forState:UIControlStateNormal];
			}
			// Make the slider only report values when movement has stopped
			UISlider *mySlider = (UISlider *)[cell viewWithTag:11];
			mySlider.continuous = NO;
			[mySlider setValue:0.75 animated:YES];
			
			cell.tag = indexPath.section;
			NSLog(@"working section %d, row %d",indexPath.section,indexPath.row);

			return cell;
			
		}
			
	} else if ([controltypeid isEqualToString:@"upDown"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlLabelCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				//cell = [[[ControlLabelCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlLabelCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			UILabel *myLabel = (UILabel *)[cell viewWithTag:11];
			myLabel.text = thecontrol.name;
			
			cell.tag = indexPath.section;

			return cell;
		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell
			//cell.btn1.text=@"Off";
			//cell.btn2.text=@"On";
			
			cell.tag = indexPath.section;

			return cell;
			
		}
	} else if ([controltypeid isEqualToString:@"miniBrowser"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			//cell.label.text = thecontrol.name;
			
			cell.tag = indexPath.section;

			return cell;
		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlWebCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlWebCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell
			//cell.btn1.text=@"Off";
			//cell.btn2.text=@"On";
			
			cell.tag = indexPath.section;

			return cell;
			
		}
	} else if ([controltypeid isEqualToString:@"audioPanel"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlLabelCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			UILabel *myLabel = (UILabel *)[cell viewWithTag:11];
			myLabel.text = thecontrol.name;
			
			cell.tag = indexPath.section;

			return cell;
		} else if (indexPath.row == 1) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlTglBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlTglBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell
			UIButton *myBtn = (UIButton *)[cell viewWithTag:10];
			[myBtn setImage:[UIImage imageNamed:@"power-red.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:11];
			[myBtn setImage:[UIImage imageNamed:@"volume-up.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:12];
			[myBtn setImage:[UIImage imageNamed:@"volume-down.png"] forState:UIControlStateNormal];

			cell.tag = indexPath.section;

			return cell;
		} else if (indexPath.row == 2) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnBtnBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell
			UIButton *myBtn = (UIButton *)[cell viewWithTag:10];
			[myBtn setImage:[UIImage imageNamed:@"cd-music.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:11];
			[myBtn setImage:[UIImage imageNamed:@"cd-music.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:12];
			[myBtn setImage:[UIImage imageNamed:@"radio.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:13];
			[myBtn setImage:[UIImage imageNamed:@"atom.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:14];
			[myBtn setImage:[UIImage imageNamed:@"tv.png"] forState:UIControlStateNormal];

			cell.tag = indexPath.section;

			return cell;			
		} else if (indexPath.row == 3) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnBtnBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell
			UIButton *myBtn = (UIButton *)[cell viewWithTag:10];
			[myBtn setImage:[UIImage imageNamed:@"media-play.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:11];
			[myBtn setImage:[UIImage imageNamed:@"media-stop.png"] forState:UIControlStateNormal];

			myBtn = (UIButton *)[cell viewWithTag:12];
			[myBtn setImage:[UIImage imageNamed:@"media-pause.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:13];
			[myBtn setImage:[UIImage imageNamed:@"media-rwd.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:14];
			[myBtn setImage:[UIImage imageNamed:@"media-fwd.png"] forState:UIControlStateNormal];

			cell.tag = indexPath.section;

			return cell;			
		} else if (indexPath.row == 4) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell
			UIButton *myBtn = (UIButton *)[cell viewWithTag:10];
			[myBtn setImage:[UIImage imageNamed:@"left-arrow.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:11];
			[myBtn setImage:[UIImage imageNamed:@"right-arrow.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:12];
			[myBtn setImage:[UIImage imageNamed:@"up-arrow.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:13];
			[myBtn setImage:[UIImage imageNamed:@"down-arrow.png"] forState:UIControlStateNormal];

			cell.tag = indexPath.section;

			return cell;			
		} else if (indexPath.row == 5) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell
			UIButton *myBtn = (UIButton *)[cell viewWithTag:10];
			[myBtn setImage:[UIImage imageNamed:@"media-play.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:11];
			[myBtn setImage:[UIImage imageNamed:@"media-stop.png"] forState:UIControlStateNormal];

			cell.tag = indexPath.section;

			return cell;
		}
	} else if ([controltypeid isEqualToString:@"tvControl"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlLabelCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				//cell = [[[ControlLabelCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlLabelCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			UILabel *myLabel = (UILabel *)[cell viewWithTag:11];
			myLabel.text = thecontrol.name;
			
			cell.tag = indexPath.section;

			return cell;
		} else if (indexPath.row == 1) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlTglBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlTglBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell
			UIButton *myBtn = (UIButton *)[cell viewWithTag:10];
			[myBtn setImage:[UIImage imageNamed:@"power-red.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:11];
			[myBtn setImage:[UIImage imageNamed:@"volume-up.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:12];
			[myBtn setImage:[UIImage imageNamed:@"volume-down.png"] forState:UIControlStateNormal];

			cell.tag = indexPath.section;

			return cell;			
		} else if (indexPath.row == 2) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnBtnBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnBtnBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell
			UIButton *myBtn = (UIButton *)[cell viewWithTag:10];
			[myBtn setImage:[UIImage imageNamed:@"chan-abc.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:11];
			[myBtn setImage:[UIImage imageNamed:@"chan-sbs.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:12];
			[myBtn setImage:[UIImage imageNamed:@"chan-win.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:13];
			[myBtn setImage:[UIImage imageNamed:@"chan-prime.png"] forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:14];
			[myBtn setImage:[UIImage imageNamed:@"chan-10.png"] forState:UIControlStateNormal];

			//cell.btn1.text=@"Off";
			//cell.btn2.text=@"On";
			
			cell.tag = indexPath.section;

			return cell;
			
		}
	} else if ([controltypeid isEqualToString:@"rawKeyPad"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlLabelCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				//cell = [[[ControlLabelCellView alloc] initWithFrame:CGRectZero reuseIdentifier:@"ControlLabelCellView"] autorelease];
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell label
			UILabel *myLabel = (UILabel *)[cell viewWithTag:11];
			myLabel.text = thecontrol.name;
			
			cell.tag = indexPath.section;

			return cell;
		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnSliderBtnCellView"];
			if (cell == nil) {
				NSLog(@"no reuseable cell available");
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnSliderBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
				if (cell == nil) {
					NSLog(@"something went wrong");
				}
			}
			// Configure the cell
			//cell.btn1.text=@"Off";
			//cell.btn2.text=@"On";
			
			cell.tag = indexPath.section;

			return cell;
			
		}
	} else {
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"Cell"] autorelease];
		}
		// Configure the cell
		cell.text = thecontrol.name;
		
		cell.tag = indexPath.section;

		return cell;
	}
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
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
//	[self.myCell dealloc];
//	[self.zoneidx dealloc];
//	[self.roomidx dealloc];
//	[self.tabidx dealloc];
    [super dealloc];
}

- (IBAction)btnPress:(id)sender {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	
	NSLog(@"Button pressed");
	UIButton *myBtn = (UIButton *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[myBtn superview] superview];
	NSIndexPath *myindexPath = [(UITableView *)[cell superview] indexPathForCell:cell];
	NSLog(@"indexPath.section:%d, indexPath.row:%d",myindexPath.section,myindexPath.row);

	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:cell.tag];

	NSLog(@"Section=%d, Key=%@", cell.tag, thecontrol.key);
}

- (IBAction)sliderDrag:(id)sender {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	
	NSLog(@"Slider drag");
	UISlider *mySlider = (UISlider *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[mySlider superview] superview];
	NSIndexPath *myindexPath = [(UITableView *)[cell superview] indexPathForCell:cell];
	NSLog(@"indexPath.section:%d, indexPath.row:%d",myindexPath.section,myindexPath.row);

	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:cell.tag];
	
	NSLog(@"Section=%d, Key=%@", cell.tag, thecontrol.key);
	
}

- (IBAction)switchState:(id)sender {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	elifesocket *myServer = elifeappdelegate.elifesvr;
	NSMutableArray *sendmsgs = elifeappdelegate.msgs_for_svr;

	NSLog(@"Switch state");
	UISwitch *mySwitch = (UISwitch *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[mySwitch superview] superview];
	NSIndexPath *myindexPath = [(UITableView *)[cell superview] indexPathForCell:cell];
	NSLog(@"indexPath.section:%d, indexPath.row:%d",myindexPath.section,myindexPath.row);
	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:cell.tag];
	
	NSLog(@"Section=%d, Key=%@", cell.tag, thecontrol.key);
	
	if (mySwitch.on) {
		// send command "on" to elife
		NSString *msg = @"<CONTROL KEY=\"";
		msg = [msg stringByAppendingString:thecontrol.key];
		msg = [msg stringByAppendingString:@"\" COMMAND=\"on\" EXTRA=\"\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
		[sendmsgs addObject:msg];
		[myServer sendmessage];
		// change cell icon to "on" version
		UIImageView *myImage = (UIImageView *)[cell viewWithTag:10];
		NSArray *iconlist = [[thecontrol.roomctrlattr objectForKey:@"icons"] componentsSeparatedByString:@","];
		myImage.image = [UIImage imageNamed:[[iconlist objectAtIndex:1] stringByAppendingString:@".png"]];
	} else {
		// send command "off" to elife
		NSString *msg = @"<CONTROL KEY=\"";
		msg = [msg stringByAppendingString:thecontrol.key];
		msg = [msg stringByAppendingString:@"\" COMMAND=\"off\" EXTRA=\"\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
		[sendmsgs addObject:msg];
		[myServer sendmessage];
		// change cell icon to "off" version
		UIImageView *myImage = (UIImageView *)[cell viewWithTag:10];
		NSArray *iconlist = [[thecontrol.roomctrlattr objectForKey:@"icons"] componentsSeparatedByString:@","];
		myImage.image = [UIImage imageNamed:[[iconlist objectAtIndex:0] stringByAppendingString:@".png"]];		
	}
	
}


@end

