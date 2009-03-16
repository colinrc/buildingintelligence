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
#import "elifecontrolrow.h"
#import "elifecontroltypeitem.h"
#import "ControlTableCell.h"

@implementation ControlsTableViewController
@synthesize myCell;
@synthesize zoneidx;
@synthesize roomidx;
@synthesize tabidx;
@synthesize celltimer;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.celltimer = nil;
    }
    return self;
}


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
		if ([thecontroltype.controltype isEqualToString:@"slider"]) {
			NSLog(@"Creating a slider");
			return 1;
		}
		if ([thecontroltype.controltype isEqualToString:@"onOff"]) {
			NSLog(@"Creating an OnOff");
			return 1;
		}
		if ([thecontroltype.controltype isEqualToString:@"miniBrowser"]) {
			NSLog(@"Creating a miniBrowser");
			return 1;
		}
		if ([thecontroltype.controltype isEqualToString:@"airCon"]) {
			NSLog(@"Creating an airCon");
			return 1;
		}
		if ([thecontroltype.controltype isEqualToString:@"testvideo"]) {
			NSLog(@"Creating a testvideo");
			return 1;
		}
		if ([thecontroltype.controltype isEqualToString:@"frontGateVideo"]) {
			NSLog(@"Creating a frontGateVideo");
			return 1;
		}
		if ([thecontroltype.controltype isEqualToString:@"test2"]) {
			NSLog(@"Creating a test2");
			return 1;
		}
		
		// count the number of rows including conditional rows
		NSLog(@"Currently thecontrol.ctrlstatus:||%@|| and thecontrol.ctrlsrc:||%@||",thecontrol.ctrlstatus,thecontrol.ctrlsrc);
		int i, rowcount;
		elifecontrolrow *currctrlrow;
		rowcount=0;
		NSArray *cases;
		NSMutableDictionary *conditions = [[NSMutableDictionary alloc] init];
		NSEnumerator *keyEnum;
		NSString *lvalue;
		NSArray *rvalue;
		BOOL show;
		
		//NSLog(@"Number of rows to check: %d",[thecontroltype.displayrows count]);
		for (i=0; i < [thecontroltype.displayrows count]; i++) {
			//NSLog(@"Checking row %d",i);
			currctrlrow = [thecontroltype.displayrows objectAtIndex:i];
			if ([currctrlrow.rowattrs objectForKey:@"cases"] != nil) {
				//NSLog(@"row with condition %@", [currctrlrow.rowattrs objectForKey:@"cases"]);
				cases = [[currctrlrow.rowattrs objectForKey:@"cases"] componentsSeparatedByString:@","];
				for (int j=0; j< [cases count]; j++) {
					//NSLog(@"Preparing dictionary");
					lvalue = [[[cases objectAtIndex:j] componentsSeparatedByString:@":"] objectAtIndex:0];
					rvalue = [[[[cases objectAtIndex:j] componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@"|"];
					[conditions setObject:rvalue forKey:lvalue];
				}
				//NSLog(@"Finished dictionary");
				keyEnum = [conditions keyEnumerator];
				show = NO;
				while ((lvalue = [keyEnum nextObject]) != nil) {
					rvalue = [conditions objectForKey:lvalue];
					for (int j=0; j < [rvalue count]; j++) {
						if ([[[rvalue objectAtIndex:j] substringToIndex:0] isEqualToString:@"!"]) {
							if ([lvalue isEqualToString:@"state"]) {
								//NSLog(@"testing lvalue=state negate");
								if ([[[rvalue objectAtIndex:j] substringFromIndex:1] isEqualToString:thecontrol.ctrlstatus]) {
									//NSLog(@"show = NO");
									show = NO;
								}
							} else if ([lvalue isEqualToString:@"src"]) {
								//NSLog(@"testing lvalue=src negate");
								if ([[[rvalue objectAtIndex:j] substringFromIndex:1] isEqualToString:thecontrol.ctrlsrc]) {
									//NSLog(@"show = NO");

									show = NO;
								}
							}
						} else {
							if ([lvalue isEqualToString:@"state"]) {
								//NSLog(@"testing lvalue=state");
								if ([[rvalue objectAtIndex:j] isEqualToString:thecontrol.ctrlstatus]) {
									//NSLog(@"show = YES");

									show = YES;
									break;
								} else {
									show = NO;
								}
							} else if ([lvalue isEqualToString:@"src"]) {
								//NSLog(@"testing lvalue=src");
								if ([[rvalue objectAtIndex:j] isEqualToString:thecontrol.ctrlsrc]) {
									//NSLog(@"show = YES");

									show = YES;
									break;
								} else {
									show = NO;
								}
							}
						}
					}
					if (show == NO) {
						break;
					}
				}
				if (show == YES) {
					rowcount++;
				}				
			} else {
				//NSLog(@"row with no conditions");
				rowcount++;
			}
		}
		
		
		//NSLog(@"return %d rows",rowcount);
		return rowcount;
	} else {
		return 1;
	}
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:indexPath.section];
	elifecontroltypes *thecontroltype;
	NSString *controltypeid = [thecontrol.roomctrlattr objectForKey:@"type"];
	
	NSInteger i=0;
	BOOL found=NO;
	while ((i < [elifeappdelegate.elifectrltypes count]) && !found) {
		thecontroltype = [elifeappdelegate.elifectrltypes objectAtIndex:i];
		if ([controltypeid isEqualToString:[thecontroltype controltype]]) {
			found=YES;
		} else {
			i++;
		}
	}
	
	if (found) {
		if ([thecontroltype.controltype isEqualToString:@"slider"]) {
			return 88.0;
		}
		if ([thecontroltype.controltype isEqualToString:@"testvideo"] || [thecontroltype.controltype isEqualToString:@"fronGateVideo"] ||
			[thecontroltype.controltype isEqualToString:@"test2"]) {
			return 288.0;
		}
		if ([thecontroltype.controltype isEqualToString:@"miniBrowser"]) {
			return 384.0;
		}
		if ([thecontroltype.controltype isEqualToString:@"airCon"]) {
			return 237.0;
		}
		return 44.0;
	}
	
	return 44.0;
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
	
	NSInteger i=0;
	BOOL found=NO;
	while ((i < [elifeappdelegate.elifectrltypes count]) && !found) {
		thecontroltype = [elifeappdelegate.elifectrltypes objectAtIndex:i];
		if ([controltypeid isEqualToString:[thecontroltype controltype]]) {
			found=YES;
		} else {
			i++;
		}
	}
    
	if ([controltypeid isEqualToString:@"onOff"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlOnOffCellView"];
			if (cell == nil) {
				[[NSBundle mainBundle] loadNibNamed:@"ControlOnOffCellView" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
			}
			// Configure the cell label
			UILabel *myLabel = (UILabel *)[cell viewWithTag:11];
			myLabel.text = thecontrol.name;
			// Configure the cell icon
			UIImageView *myImage = (UIImageView *)[cell viewWithTag:10];
			NSArray *iconlist = [[thecontrol.roomctrlattr objectForKey:@"icons"] componentsSeparatedByString:@","];
			UISwitch *mySwitch = (UISwitch *)[cell viewWithTag:12];
			if ([thecontrol.ctrlstatus isEqualToString:@"off"]||[thecontrol.ctrlstatus isEqualToString:@"OFF"]) {
				// use first icon
				myImage.image = [UIImage imageNamed:[[iconlist objectAtIndex:0] stringByAppendingString:@".png"]];
				[mySwitch setOn:NO animated:YES];
			} else {
				// use second icon
				myImage.image = [UIImage imageNamed:[[iconlist objectAtIndex:1] stringByAppendingString:@".png"]];
				[mySwitch setOn:YES animated:YES];
			}
						
			cell.tag = indexPath.section;
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchUpdate:) name:thecontrol.key object:nil];
			
			return cell;
			
	//	}
	} else if ([controltypeid isEqualToString:@"slider"]) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnSliderBtnCellView"];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"ControlBtnSliderBtnCell" owner:self options:nil];
			cell = self.myCell;
			self.myCell = nil;
		}
		// Configure the cell label
		UILabel *myLabel = (UILabel *)[cell viewWithTag:10];
		myLabel.text = thecontrol.name;
		// check for icons definition
		if ([thecontrol.roomctrlattr objectForKey:@"icons"] != nil) {
			// put icons on the buttons
			NSArray *iconlist = [[thecontrol.roomctrlattr objectForKey:@"icons"] componentsSeparatedByString:@","];
			UIButton *myBtn = (UIButton *)[cell viewWithTag:11];
			[myBtn setImage:[UIImage imageNamed:[[iconlist objectAtIndex:0] stringByAppendingString:@".png"]] forState:UIControlStateNormal];
			myBtn = (UIButton *)[cell viewWithTag:13];
			[myBtn setImage:[UIImage imageNamed:[[iconlist objectAtIndex:1] stringByAppendingString:@".png"]] forState:UIControlStateNormal];			
		} else {
			// use text labels on the buttons
			UIButton *myBtn = (UIButton *)[cell viewWithTag:11];
			[myBtn setTitle:@"Off" forState:UIControlStateNormal];
			
			myBtn = (UIButton *)[cell viewWithTag:13];
			[myBtn setTitle:@"On" forState:UIControlStateNormal];
		}
		// Make the slider only report values when movement has stopped
		UISlider *mySlider = (UISlider *)[cell viewWithTag:12];
		mySlider.continuous = NO;
		[mySlider setValue:(thecontrol.ctrlval)/100.0 animated:YES];
			
		cell.tag = indexPath.section;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sliderUpdate:) name:thecontrol.key object:nil];

		return cell;
	} else if ([controltypeid isEqualToString:@"upDown"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				[[NSBundle mainBundle] loadNibNamed:@"ControlLabelCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
			}
			// Configure the cell label
			UILabel *myLabel = (UILabel *)[cell viewWithTag:11];
			myLabel.text = thecontrol.name;
			
			cell.tag = indexPath.section;

			return cell;
		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnCellView"];
			if (cell == nil) {
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
			}
			// Configure the cell
			//cell.btn1.text=@"Off";
			//cell.btn2.text=@"On";
			
			cell.tag = indexPath.section;

			return cell;
			
		}
	} else if ([controltypeid isEqualToString:@"miniBrowser"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		cell = [tableView dequeueReusableCellWithIdentifier:@"ControlWebCellView"];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"ControlWebCell" owner:self options:nil];
			cell = self.myCell;
			self.myCell = nil;
		}
		// Configure the cell
		UIWebView *myWebView = (UIWebView *)[cell viewWithTag:100];
		NSURL *myurl = [NSURL URLWithString:@"http://www.google.com.au"];
		NSURLRequest *myurlreq = [NSURLRequest requestWithURL:myurl];
		[myWebView loadRequest:myurlreq];
		
		cell.tag = indexPath.section;

		return cell;
			
		//}
	} else if ([controltypeid isEqualToString:@"audioPanel"] || [controltypeid isEqualToString:@"tvControl"]) {
		int i, rowcount, displayrownum;
		BOOL foundrow=NO;
		elifecontrolrow *currctrlrow;
		rowcount=-1;
		NSArray *cases;
		NSMutableDictionary *conditions = [[NSMutableDictionary alloc] init];
		NSEnumerator *keyEnum;
		NSString *lvalue;
		NSArray *rvalue;
		BOOL show;		
		for (i=0; i < [thecontroltype.displayrows count] && !foundrow; i++) {
			currctrlrow = [thecontroltype.displayrows objectAtIndex:i];
			if ([currctrlrow.rowattrs objectForKey:@"cases"] != nil) {
				//NSLog(@"row with condition %@", [currctrlrow.rowattrs objectForKey:@"cases"]);
				cases = [[currctrlrow.rowattrs objectForKey:@"cases"] componentsSeparatedByString:@","];
				show=YES;
				for (int j=0; j< [cases count]; j++) {
					//NSLog(@"Preparing dictionary");
					lvalue = [[[cases objectAtIndex:j] componentsSeparatedByString:@":"] objectAtIndex:0];
					rvalue = [[[[cases objectAtIndex:j] componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@"|"];
					[conditions setObject:rvalue forKey:lvalue];
				}
				//NSLog(@"Finished dictionary");
				show=NO;
				keyEnum = [conditions keyEnumerator];
				while ((lvalue = [keyEnum nextObject]) != nil) {
					rvalue = [conditions objectForKey:lvalue];
					for (int j=0; j < [rvalue count]; j++) {
						if ([[[rvalue objectAtIndex:j] substringToIndex:0] isEqualToString:@"!"]) {
							if ([lvalue isEqualToString:@"state"]) {
								if ([[[rvalue objectAtIndex:j] substringFromIndex:1] isEqualToString:thecontrol.ctrlstatus]) {
									show = NO;
								}
							} else if ([lvalue isEqualToString:@"src"]) {
								if ([[[rvalue objectAtIndex:j] substringFromIndex:1] isEqualToString:thecontrol.ctrlsrc]) {
									show = NO;
								}
							}
						} else {
							if ([lvalue isEqualToString:@"state"]) {
								if ([[rvalue objectAtIndex:j] isEqualToString:thecontrol.ctrlstatus]) {
									show = YES;
									break;
								} else {
									show = NO;
								}
							} else if ([lvalue isEqualToString:@"src"]) {
								if ([[rvalue objectAtIndex:j] isEqualToString:thecontrol.ctrlsrc]) {
									show = YES;
									break;
								} else {
									show = NO;
								}
							}
						}
					}
					if (!show) {
						break;
					}
				}
				if (show == YES) {
					rowcount++;
					if (rowcount == indexPath.row) {
						foundrow=YES;
						displayrownum = i;
						break;
					}
				}					
			} else {
				// no condition on row
				rowcount++;
				if (rowcount == indexPath.row) {
					foundrow=YES;
					displayrownum = i;
					break;
				}
			}
		}
		
		if (indexPath.row == 0) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buttonUpdate:) name:thecontrol.key object:nil];
		}
		
		//NSLog(@"Need to display indexPath.row=%d which is %d row in config",indexPath.row,displayrownum);
		elifecontrolrow *rowtodisplay = [thecontroltype.displayrows objectAtIndex:displayrownum];
		if ([rowtodisplay.displayitems count] == 5) {
			// 5 button cell needed
			//cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnBtnBtnCellView"];
			//[cell release];
			if (cell == nil) {
				//NSLog(@"Creating a new cell");
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnBtnBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
			}
			// Configure the cell
			UIButton *myBtn;
			elifecontroltypeitem *currdisplayitem;
			NSDictionary *currdisplayitemattrs;
			NSString *iconname;
			for (int j=0; j<[rowtodisplay.displayitems count]; j++) {
				//NSLog(@"checking displayitem %d",j);
				currdisplayitem = [rowtodisplay.displayitems objectAtIndex:j];
				currdisplayitemattrs = currdisplayitem.itemattrs;
				myBtn = (UIButton *)[cell viewWithTag:(100+j)];
				myBtn.tag = 100*displayrownum+j;
				iconname = [currdisplayitemattrs objectForKey:@"icon"];
				if (iconname != nil) {
					//NSLog(@"iconname %@",iconname);
					[myBtn setImage:[UIImage imageNamed:[iconname stringByAppendingString:@".png"]] forState:UIControlStateNormal];
				} else {
					//NSLog(@"Using label %@",[currdisplayitemattrs objectForKey:@"label"]);
					[myBtn setTitle:[currdisplayitemattrs objectForKey:@"label"] forState:UIControlStateNormal];

				}
			}
			cell.tag = indexPath.section;
			
			return cell;			
		} else if ([rowtodisplay.displayitems count] == 4) {
			// 4 button cell needed
			//cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnBtnCellView"];
			if (cell == nil) {
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
			}
			// Configure the cell
			UIButton *myBtn;
			elifecontroltypeitem *currdisplayitem;
			NSDictionary *currdisplayitemattrs;
			NSString *iconname;
			for (int j=0; j<[rowtodisplay.displayitems count]; j++) {
				//NSLog(@"checking displayitem %d",j);
				currdisplayitem = [rowtodisplay.displayitems objectAtIndex:j];
				currdisplayitemattrs = currdisplayitem.itemattrs;
				myBtn = (UIButton *)[cell viewWithTag:(100+j)];
				myBtn.tag = 100*displayrownum+j;
				iconname = [currdisplayitemattrs objectForKey:@"icon"];
				if (iconname != nil) {
					//NSLog(@"iconname %@",iconname);
					[myBtn setImage:[UIImage imageNamed:[iconname stringByAppendingString:@".png"]] forState:UIControlStateNormal];
				} else {
					//NSLog(@"Using label %@",[currdisplayitemattrs objectForKey:@"label"]);
					[myBtn setTitle:[currdisplayitemattrs objectForKey:@"label"] forState:UIControlStateNormal];
					
				}
			}
			cell.tag = indexPath.section;
			
			return cell;			
		} else if ([rowtodisplay.displayitems count] == 3) {
			// could be three buttons or toggle/btn/btn
			elifecontroltypeitem *currdisplayitem = [rowtodisplay.displayitems objectAtIndex:0];
			if ([currdisplayitem.ctrlitemtype isEqualToString:@"toggle"]) {
				//NSLog(@"creating tgl/btn/btn");
				//cell = [tableView dequeueReusableCellWithIdentifier:@"ControlTglBtnBtnCellView"];
				if (cell == nil) {
					[[NSBundle mainBundle] loadNibNamed:@"ControlTglBtnBtnCell" owner:self options:nil];
					cell = self.myCell;
					self.myCell = nil;
				}
				// Configure the cell
				UIButton *myBtn;
				elifecontroltypeitem *currdisplayitem;
				NSDictionary *currdisplayitemattrs;
				NSString *iconname;
				NSArray *icons;
				for (int j=0; j<[rowtodisplay.displayitems count]; j++) {
					//NSLog(@"checking displayitem %d",j);
					currdisplayitem = [rowtodisplay.displayitems objectAtIndex:j];
					currdisplayitemattrs = currdisplayitem.itemattrs;
					myBtn = (UIButton *)[cell viewWithTag:(100+j)];
					myBtn.tag = 100*displayrownum+j;
					if ([currdisplayitem.ctrlitemtype isEqualToString:@"toggle"]) {
						icons = [[currdisplayitemattrs objectForKey:@"icons"] componentsSeparatedByString:@","];
						if ([thecontrol.ctrlstatus isEqualToString:@"on"] || [thecontrol.ctrlstatus isEqualToString:@"ON"]) {
							[myBtn setImage:[UIImage imageNamed:[[icons objectAtIndex:1] stringByAppendingString:@".png"]] forState:UIControlStateNormal];
						} else {
							[myBtn setImage:[UIImage imageNamed:[[icons objectAtIndex:0] stringByAppendingString:@".png"]] forState:UIControlStateNormal];
						}
					} else {
						iconname = [currdisplayitemattrs objectForKey:@"icon"];
						if (iconname != nil) {
							//NSLog(@"iconname %@",iconname);
							[myBtn setImage:[UIImage imageNamed:[iconname stringByAppendingString:@".png"]] forState:UIControlStateNormal];
						} else {
							//NSLog(@"Using label %@",[currdisplayitemattrs objectForKey:@"label"]);
							[myBtn setTitle:[currdisplayitemattrs objectForKey:@"label"] forState:UIControlStateNormal];
						
						}
					}
				}
				
				cell.tag = indexPath.section;
				
				return cell;				
			} else {
				//NSLog(@"creating btn/btn/btn");

				//cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnBtnCellView"];
				if (cell == nil) {
					[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnBtnCell" owner:self options:nil];
					cell = self.myCell;
					self.myCell = nil;
				}
				// Configure the cell
				UIButton *myBtn;
				elifecontroltypeitem *currdisplayitem;
				NSDictionary *currdisplayitemattrs;
				NSString *iconname;
				for (int j=0; j<[rowtodisplay.displayitems count]; j++) {
					//NSLog(@"checking displayitem %d",j);
					currdisplayitem = [rowtodisplay.displayitems objectAtIndex:j];
					currdisplayitemattrs = currdisplayitem.itemattrs;
					myBtn = (UIButton *)[cell viewWithTag:(100+j)];
					myBtn.tag = 100*displayrownum+j;
					iconname = [currdisplayitemattrs objectForKey:@"icon"];
					if (iconname != nil) {
						//NSLog(@"iconname %@",iconname);
						[myBtn setImage:[UIImage imageNamed:[iconname stringByAppendingString:@".png"]] forState:UIControlStateNormal];
					} else {
						//NSLog(@"Using label %@",[currdisplayitemattrs objectForKey:@"label"]);
						[myBtn setTitle:[currdisplayitemattrs objectForKey:@"label"] forState:UIControlStateNormal];
						
					}
				}
				cell.tag = indexPath.section;
				return cell;								
			}
		} else if ([rowtodisplay.displayitems count] == 2) {
			// 2 button cell needed
			//cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnBtnCellView"];
			if (cell == nil) {
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
			}
			// Configure the cell
			UIButton *myBtn;
			elifecontroltypeitem *currdisplayitem;
			NSDictionary *currdisplayitemattrs;
			NSString *iconname;
			for (int j=0; j<[rowtodisplay.displayitems count]; j++) {
				//NSLog(@"checking displayitem %d",j);
				currdisplayitem = [rowtodisplay.displayitems objectAtIndex:j];
				currdisplayitemattrs = currdisplayitem.itemattrs;
				myBtn = (UIButton *)[cell viewWithTag:(100+j)];
				myBtn.tag = 100*displayrownum+j;
				iconname = [currdisplayitemattrs objectForKey:@"icon"];
				if (iconname != nil) {
					//NSLog(@"iconname %@",iconname);
					[myBtn setImage:[UIImage imageNamed:[iconname stringByAppendingString:@".png"]] forState:UIControlStateNormal];
				} else {
					//NSLog(@"Using label %@",[currdisplayitemattrs objectForKey:@"label"]);
					[myBtn setTitle:[currdisplayitemattrs objectForKey:@"label"] forState:UIControlStateNormal];
					
				}
			}
			cell.tag = indexPath.section;
			
			return cell;
			
		} else {
			// one element only - must be label
			//cell = [tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				[[NSBundle mainBundle] loadNibNamed:@"ControlLabelCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
			}
			// Configure the cell label
			UILabel *myLabel = (UILabel *)[cell viewWithTag:11];
			myLabel.text = thecontrol.name;
			
			cell.tag = indexPath.section;
			return cell;
		}
		
	} else if ([controltypeid isEqualToString:@"rawKeyPad"]) {
		NSMutableArray *controltyperows = [thecontroltype.displayrows objectAtIndex:indexPath.row];
		if (indexPath.row == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlLabelCellView"];
			if (cell == nil) {
				[[NSBundle mainBundle] loadNibNamed:@"ControlLabelCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
			}
			// Configure the cell label
			UILabel *myLabel = (UILabel *)[cell viewWithTag:11];
			myLabel.text = thecontrol.name;
			
			cell.tag = indexPath.section;

			return cell;
		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ControlBtnSliderBtnCellView"];
			if (cell == nil) {
				[[NSBundle mainBundle] loadNibNamed:@"ControlBtnSliderBtnCell" owner:self options:nil];
				cell = self.myCell;
				self.myCell = nil;
			}
			// Configure the cell
			//cell.btn1.text=@"Off";
			//cell.btn2.text=@"On";
			
			cell.tag = indexPath.section;

			return cell;
			
		}
	} else if ([controltypeid isEqualToString:@"airCon"]) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"ControlPickerCellView"];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"ControlPickerCell" owner:self options:nil];
			cell = self.myCell;
			self.myCell = nil;
		}
		// Configure the cell label
		UILabel *myLabel = (UILabel *)[cell viewWithTag:100];
		myLabel.text = thecontrol.name;
		cell.tag = indexPath.section;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sliderUpdate:) name:thecontrol.key object:nil];
	
		return cell;
	} else if ([controltypeid isEqualToString:@"testvideo"] ||
			   [controltypeid isEqualToString:@"frontGateVideo"] ||
			   [controltypeid isEqualToString:@"test2"])  {
		cell = (ControlTableCell *)[[[ControlTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:controltypeid zoneidx:zoneidx roomidx:roomidx tabidx:tabidx controlidx:indexPath.section] autorelease];

		// Loop through control type creating objects
		elifecontrolrow *currctrlrow;
		elifecontroltypeitem *currctrlitem;
		NSDictionary *itemattrs;
		for (int j=0; j < [thecontroltype.displayrows count]; j++) {
			currctrlrow = [thecontroltype.displayrows objectAtIndex:j];
			for (int k=0; k < [currctrlrow.displayitems count]; k++) {
				currctrlitem = [currctrlrow.displayitems objectAtIndex:k];
				itemattrs = currctrlitem.itemattrs;
				if ([[itemattrs objectForKey:@"type"] isEqualToString:@"label"]) {
					//UIView *myuiobject = (UIView *)[cell viewWithTag:(j+1)*100+k];
				} else if ([[itemattrs objectForKey:@"type"] isEqualToString:@"video"]) {
					UIWebView *mywebview = (UIWebView *)[cell viewWithTag:(j+1)*100+k];
					NSString *refrate = [itemattrs objectForKey:@"refreshRate"];
					if (refrate) {
						int rate = [refrate intValue];
						if (![self.celltimer isValid]) {
							self.celltimer = [NSTimer scheduledTimerWithTimeInterval:(rate/1000.0) target:self selector:@selector(videorefresh:) userInfo:mywebview repeats:YES];
						}
					}
				} else if ([[itemattrs objectForKey:@"type"] isEqualToString:@"button"]) {
					UIButton *mybutton = (UIButton *)[cell viewWithTag:(j+1)*100+k];
					[mybutton addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
				} else if ([[itemattrs objectForKey:@"type"] isEqualToString:@"toggle"]) {
					UIButton *mytoggle = (UIButton *)[cell viewWithTag:(j+1)*100+k];
					[mytoggle addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
				}
			}
		}		

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buttonUpdate:) name:thecontrol.key object:nil];

		return cell;
	} else {
		
		// catchall cell
		cell = [tableView dequeueReusableCellWithIdentifier:controltypeid];
		if (cell == nil) {
			cell = [[[ControlTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:controltypeid zoneidx:zoneidx roomidx:roomidx tabidx:tabidx controlidx:indexPath.section] autorelease];
		}
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

- (void)viewWillDisappear:(BOOL)animated {
	[self.celltimer invalidate];
}

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
	elifesocket *myServer = elifeappdelegate.elifesvr;
	NSMutableArray *sendmsgs = elifeappdelegate.msgs_for_svr;
	int arrayoffset;

	
	UIButton *myBtn = (UIButton *)sender;
	NSLog(@"Button tag: %d",myBtn.tag);
	UITableViewCell *cell = (UITableViewCell *)[[myBtn superview] superview];
	//NSIndexPath *myindexPath = [(UITableView *)[cell superview] indexPathForCell:cell];

	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:cell.tag];
	elifecontroltypes *thecontroltype;
	NSString *controltypeid = [thecontrol.roomctrlattr objectForKey:@"type"];
	
	int i=0;
	BOOL found=NO;
	NSLog(@"controltype count %d",[elifeappdelegate.elifectrltypes count]);
	while ((i < [elifeappdelegate.elifectrltypes count]) && !found) {
		NSLog(@"top of loop i=%d",i);
		thecontroltype = [elifeappdelegate.elifectrltypes objectAtIndex:i];
		if ([controltypeid isEqualToString:[thecontroltype controltype]]) {
			found=YES;
			NSLog(@"found a match:%@",[thecontroltype controltype]);
		} else {
			i++;
			NSLog(@"Tested %@, setting i=%d",[thecontroltype controltype],i);
		}
	}
	
	if ([controltypeid isEqualToString:@"testvideo"] ||
		   [controltypeid isEqualToString:@"frontGateVideo"] ||
		   [controltypeid isEqualToString:@"test2"])  {
		arrayoffset=1;
	} else {
		arrayoffset=0;
	}
	
	
	if (myBtn.tag >= 100) {
		elifecontrolrow *currdisplayrow = [thecontroltype.displayrows objectAtIndex:(int)((myBtn.tag-(myBtn.tag % 100))/100)-arrayoffset];
		elifecontroltypeitem *currdisplayitem = [currdisplayrow.displayitems objectAtIndex:(myBtn.tag % 100)];
		NSString *thecommand;
		NSString *theextra;
		NSString *msg;
		if ([currdisplayitem.ctrlitemtype isEqualToString:@"toggle"]) {
			if ([thecontrol.ctrlstatus isEqualToString:@"on"]) {
				thecommand = @"off";
			} else {
				thecommand = @"on";
			}
			msg = @"<CONTROL KEY=\"";
			msg = [msg stringByAppendingString:thecontrol.key];
			msg = [msg stringByAppendingString:@"\" COMMAND=\""];
			msg = [msg stringByAppendingString:thecommand];
			msg = [msg stringByAppendingString:@"\" EXTRA=\"\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
			
		} else {
			thecommand = [currdisplayitem.itemattrs objectForKey:@"command"];
			theextra = [currdisplayitem.itemattrs objectForKey:@"extra"];
			NSLog(@"###### command:%@ extra:%@",thecommand,theextra);
			// send command to server
			msg = @"<CONTROL KEY=\"";
			msg = [msg stringByAppendingString:thecontrol.key];
			msg = [msg stringByAppendingString:@"\" COMMAND=\""];
			msg = [msg stringByAppendingString:thecommand];
			msg = [msg stringByAppendingString:@"\" EXTRA=\""];
			msg = [msg stringByAppendingString:theextra];
			msg = [msg stringByAppendingString:@"\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
		}
		if ([thecommand isEqualToString:@"on"] || [thecommand isEqualToString:@"off"]) {
			thecontrol.ctrlstatus=thecommand;
		} 
		if ([thecommand isEqualToString:@"state"]) {
			thecontrol.ctrlstatus=theextra;
		}
		if ([thecommand isEqualToString:@"src"]) {
			thecontrol.ctrlsrc=theextra;
		}
		
		[sendmsgs addObject:msg];
		[myServer sendmessage];
		
	} else {
		// send command to server
		thecontrol.ctrlstatus=@"on";
		NSString *msg = @"<CONTROL KEY=\"";
		msg = [msg stringByAppendingString:thecontrol.key];
		msg = [msg stringByAppendingString:@"\" COMMAND=\"on\" EXTRA=\"\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
		[sendmsgs addObject:msg];
		[myServer sendmessage];
	}
	
	// Send notification message to any observers
	[[NSNotificationCenter defaultCenter] postNotificationName:thecontrol.key object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:[thecontrol.key stringByAppendingString:@"_status"] object:nil];


}

- (IBAction)sliderDrag:(id)sender {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	elifesocket *myServer = elifeappdelegate.elifesvr;
	NSMutableArray *sendmsgs = elifeappdelegate.msgs_for_svr;
	
	UISlider *mySlider = (UISlider *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[mySlider superview] superview];
	NSIndexPath *myindexPath = [(UITableView *)[cell superview] indexPathForCell:cell];

	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:cell.tag];
	
	int sliderval = (int)(mySlider.value*100);
	if (sliderval > 5) {
		// send command "on" to elife with slider value
		thecontrol.ctrlstatus=@"on";
		thecontrol.ctrlval=sliderval;
		NSString *msg = @"<CONTROL KEY=\"";
		msg = [msg stringByAppendingString:thecontrol.key];
		msg = [msg stringByAppendingString:@"\" COMMAND=\"on\" EXTRA=\""];
		msg = [msg stringByAppendingString:[NSString stringWithFormat:@"%d",sliderval]];
		msg = [msg stringByAppendingString:@"\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
		[sendmsgs addObject:msg];
		[myServer sendmessage];
	} else {
		// send command "off" to elife
		thecontrol.ctrlstatus=@"off";
		thecontrol.ctrlval=0;
		NSString *msg = @"<CONTROL KEY=\"";
		msg = [msg stringByAppendingString:thecontrol.key];
		msg = [msg stringByAppendingString:@"\" COMMAND=\"off\" EXTRA=\"0\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
		[sendmsgs addObject:msg];
		[myServer sendmessage];
	}
	// Send notification message to any observers
	[[NSNotificationCenter defaultCenter] postNotificationName:thecontrol.key object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:[thecontrol.key stringByAppendingString:@"_status"] object:nil];
	
}

- (IBAction)switchState:(id)sender {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	elifesocket *myServer = elifeappdelegate.elifesvr;
	NSMutableArray *sendmsgs = elifeappdelegate.msgs_for_svr;

	UISwitch *mySwitch = (UISwitch *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[mySwitch superview] superview];
	NSIndexPath *myindexPath = [(UITableView *)[cell superview] indexPathForCell:cell];
	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:cell.tag];
	
	
	if (mySwitch.on) {
		// send command "on" to elife
		thecontrol.ctrlstatus=@"on";
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
		thecontrol.ctrlstatus=@"off";
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
	// Send notification message to any observers
	[[NSNotificationCenter defaultCenter] postNotificationName:thecontrol.key object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:[thecontrol.key stringByAppendingString:@"_status"] object:nil];
	
}

- (void)switchUpdate:(NSNotification *)notification {
	NSString *thekey = [notification name];
	[self.tableView setNeedsDisplay];
	[self.tableView reloadData];
}

- (void)buttonUpdate:(NSNotification *)notification {
	NSString *thekey = [notification name];
	NSLog(@"received notification %@", thekey);
	[self.tableView setNeedsDisplay];
	[self.tableView reloadData];
}

- (void)sliderUpdate:(NSNotification *)notification {
	NSString *thekey = [notification name];
	[self.tableView setNeedsDisplay];
	[self.tableView reloadData];
}


#pragma mark ---- UIPickerViewDataSource delegate methods ----

// returns the number of columns to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

// returns the number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	//return [pickerItems count];
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:0];
	elifecontroltypes *thecontroltype;
	NSString *controltypeid = [thecontrol.roomctrlattr objectForKey:@"type"];

	NSInteger i=0;
	BOOL found=NO;
	while ((i < [elifeappdelegate.elifectrltypes count]) && !found) {
		thecontroltype = [elifeappdelegate.elifectrltypes objectAtIndex:i];
		if ([controltypeid isEqualToString:[thecontroltype controltype]]) {
			found=YES;
		} else {
			i++;
		}
	}
	
	elifecontrolrow *ctrlrow;
	elifecontroltypeitem *ctrlitem;
	for (int j=0; j < [thecontroltype.displayrows count]; j++) {
		ctrlrow = [thecontroltype.displayrows objectAtIndex:j];
		for (int k=0; k < [ctrlrow.displayitems count]; k++) {
			ctrlitem = [ctrlrow.displayitems objectAtIndex:k];
			if ([ctrlitem.ctrlitemtype isEqualToString:@"picker"]) {
				NSInteger minval, maxval, step;
				minval = [[ctrlitem.itemattrs objectForKey:@"minValue"] integerValue];
				maxval = [[ctrlitem.itemattrs objectForKey:@"maxValue"] integerValue];
				step = [[ctrlitem.itemattrs objectForKey:@"step"] integerValue];
				return (int)(((maxval-minval) / step) + 1);
			}
		}
	}
	
	return 0;
}

#pragma mark ---- UIPickerViewDelegate delegate methods ----

// returns the title of each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	//NSString *currentItem = [pickerItems objectAtIndex:row];
	
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:0];
	elifecontroltypes *thecontroltype;
	NSString *controltypeid = [thecontrol.roomctrlattr objectForKey:@"type"];
	
	NSInteger i=0;
	BOOL found=NO;
	while ((i < [elifeappdelegate.elifectrltypes count]) && !found) {
		thecontroltype = [elifeappdelegate.elifectrltypes objectAtIndex:i];
		if ([controltypeid isEqualToString:[thecontroltype controltype]]) {
			found=YES;
		} else {
			i++;
		}
	}
	
	elifecontrolrow *ctrlrow;
	elifecontroltypeitem *ctrlitem;
	for (int j=0; j < [thecontroltype.displayrows count]; j++) {
		ctrlrow = [thecontroltype.displayrows objectAtIndex:j];
		for (int k=0; k < [ctrlrow.displayitems count]; k++) {
			ctrlitem = [ctrlrow.displayitems objectAtIndex:k];
			if ([ctrlitem.ctrlitemtype isEqualToString:@"picker"]) {
				NSInteger minval, maxval, step, pickerval;
				minval = [[ctrlitem.itemattrs objectForKey:@"minValue"] integerValue];
				maxval = [[ctrlitem.itemattrs objectForKey:@"maxValue"] integerValue];
				step = [[ctrlitem.itemattrs objectForKey:@"step"] integerValue];
				
				pickerval = minval+row*step;
				if (pickerval > maxval) {
					pickerval = maxval;
				}
				
				NSString *currentItem = [NSString stringWithFormat:@"%d deg C",pickerval];
				return currentItem;
			}
		}
	}
	
	return @"N/A" ;
}

// gets called when the user settles on a row
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	
	//NSString *currentItem = [pickerItems objectAtIndex:row];
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:0];
	elifesocket *myServer = elifeappdelegate.elifesvr;
	NSMutableArray *sendmsgs = elifeappdelegate.msgs_for_svr;
	elifecontroltypes *thecontroltype;
	NSString *controltypeid = [thecontrol.roomctrlattr objectForKey:@"type"];
	
	NSInteger i=0;
	BOOL found=NO;
	while ((i < [elifeappdelegate.elifectrltypes count]) && !found) {
		thecontroltype = [elifeappdelegate.elifectrltypes objectAtIndex:i];
		if ([controltypeid isEqualToString:[thecontroltype controltype]]) {
			found=YES;
		} else {
			i++;
		}
	}
	
	elifecontrolrow *ctrlrow;
	elifecontroltypeitem *ctrlitem;
	for (int j=0; j < [thecontroltype.displayrows count]; j++) {
		ctrlrow = [thecontroltype.displayrows objectAtIndex:j];
		for (int k=0; k < [ctrlrow.displayitems count]; k++) {
			ctrlitem = [ctrlrow.displayitems objectAtIndex:k];
			if ([ctrlitem.ctrlitemtype isEqualToString:@"picker"]) {
				NSInteger minval, maxval, step, pickerval;
				minval = [[ctrlitem.itemattrs objectForKey:@"minValue"] integerValue];
				maxval = [[ctrlitem.itemattrs objectForKey:@"maxValue"] integerValue];
				step = [[ctrlitem.itemattrs objectForKey:@"step"] integerValue];
				
				pickerval = minval+row*step;
				if (pickerval > maxval) {
					pickerval = maxval;
				}
				NSString *msg = @"<CONTROL KEY=\"";
				msg = [msg stringByAppendingString:thecontrol.key];
				msg = [msg stringByAppendingString:@"\" COMMAND=\"on\" EXTRA=\""];
				msg = [msg stringByAppendingString:[NSString stringWithFormat:@"%d",pickerval]];
				msg = [msg stringByAppendingString:@"\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
				[sendmsgs addObject:msg];
				[myServer sendmessage];
				
			}
		}
	}
}
	
-(void)videorefresh:(NSTimer *)theTimer {
	//UITableViewCell *cell = (UITableViewCell *)[theTimer userInfo];
	NSLog(@"entered videorefresh");
	//UIWebView *myWebView = (UIWebView *)[cell viewWithTag:100];
	UIWebView *myWebView = (UIWebView *)[theTimer userInfo];
	//NSURL *myurl = [NSURL URLWithString:@"http://192.168.1.223/Jpeg/CamImg.jpg"];
	//NSURLRequest *myurlreq = [NSURLRequest requestWithURL:myurl];
	//[myWebView loadRequest:myurlreq];
	[myWebView reload];
	
}	


@end

