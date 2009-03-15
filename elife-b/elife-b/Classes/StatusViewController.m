//
//  StatusViewController.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "StatusViewController.h"
#import "elife_bAppDelegate.h"
#import "elifestatustab.h";
#import "elifestatusitem.h";
#import "elifezone.h"
#import "eliferoom.h"
#import "eliferoomtab.h"
#import "eliferoomcontrol.h"

@implementation StatusViewController

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *statustablist = elifeappdelegate.elifestatustabs;
	NSString *sectiontitle;
	
	sectiontitle = [[statustablist objectAtIndex:section] tabname];
	
	return sectiontitle;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *statustablist = elifeappdelegate.elifestatustabs;
	
    return [statustablist count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *statustablist = elifeappdelegate.elifestatustabs;
	elifestatustab *currenttab = [statustablist objectAtIndex:section];
	elifestatusitem *currentitem;
	NSInteger itemcount = 0;
	int x,i,j,k,l;
	elifezone *currzone;
	eliferoom *currroom;
	eliferoomtab *currtab;
	eliferoomcontrol *currctrl;
	BOOL foundctrl;
	
	// calculate how many status entries are currently on andreturn count
	for (x=0; x<[currenttab.statusitems count]; x++) {
		currentitem = [currenttab.statusitems objectAtIndex:x];
		foundctrl=NO;
		for (i=0; (!foundctrl) && i<[elifeappdelegate.elifezonelist count]; i++) {
			currzone = [elifeappdelegate.elifezonelist objectAtIndex:i];
			for (j=0; (!foundctrl) && j<[currzone.roomlist count]; j++) {
				currroom = [currzone.roomlist objectAtIndex:j];
				for (k=0; (!foundctrl) && k<[currroom.tablist count]; k++) {
					currtab = [currroom.tablist objectAtIndex:k];
					for (l=0; (!foundctrl) && l<[currtab.controllist count]; l++) {
						currctrl = [currtab.controllist objectAtIndex:l];
						if ([currctrl.key isEqualToString:currentitem.key]) {
							foundctrl=YES;
							if ([currctrl.ctrlstatus isEqualToString:@"on"]) {
								itemcount++;
							}
						}
					}
				}
			}
		}
	}
	
    return itemcount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *statustablist = elifeappdelegate.elifestatustabs;
	elifestatustab *currenttab = [statustablist objectAtIndex:indexPath.section];
	elifestatusitem *currentitem;
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	// Locate the correct room control
	int x,i,j,k,l,itemcount;
	elifezone *currzone;
	eliferoom *currroom;
	eliferoomtab *currtab;
	eliferoomcontrol *currctrl;
	BOOL foundctrl;
	
	// find the n-th control that is "on"
	itemcount=-1;
	for (x=0; x<[currenttab.statusitems count]; x++) {
		currentitem = [currenttab.statusitems objectAtIndex:x];
		foundctrl=NO;
		for (i=0; (!foundctrl) && i<[elifeappdelegate.elifezonelist count]; i++) {
			currzone = [elifeappdelegate.elifezonelist objectAtIndex:i];
			for (j=0; (!foundctrl) && j<[currzone.roomlist count]; j++) {
				currroom = [currzone.roomlist objectAtIndex:j];
				for (k=0; (!foundctrl) && k<[currroom.tablist count]; k++) {
					currtab = [currroom.tablist objectAtIndex:k];
					for (l=0; (!foundctrl) && l<[currtab.controllist count]; l++) {
						currctrl = [currtab.controllist objectAtIndex:l];
						if ([currctrl.key isEqualToString:currentitem.key]) {
							foundctrl=YES;
							if ([currctrl.ctrlstatus isEqualToString:@"on"]) {
								itemcount++;
								if (itemcount == indexPath.row) {
									// this is the one we want
									cell.text = [[currroom.name stringByAppendingString:@": "] stringByAppendingString:currctrl.name];
									if ([currenttab.tabattr objectForKey:@"icon"]) {
										cell.image = [UIImage imageNamed:[[currenttab.tabattr objectForKey:@"icon"] stringByAppendingString:@".png"]];
									}
									return cell;
								}
							}
						}
					}
				}
			}
		}
	}
	
	// Something is wrong if we get here	
    // Return an empty cell
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *statustablist = elifeappdelegate.elifestatustabs;
	elifestatustab *currenttab = [statustablist objectAtIndex:indexPath.section];
	elifestatusitem *currentitem;
	elifesocket *myServer = elifeappdelegate.elifesvr;
	NSMutableArray *sendmsgs = elifeappdelegate.msgs_for_svr;
    
	// Locate the correct room control
	int x,i,j,k,l,itemcount;
	elifezone *currzone;
	eliferoom *currroom;
	eliferoomtab *currtab;
	eliferoomcontrol *currctrl;
	BOOL foundctrl;
	
	// find the n-th control that is "on"
	itemcount=-1;
	for (x=0; x<[currenttab.statusitems count]; x++) {
		currentitem = [currenttab.statusitems objectAtIndex:x];
		foundctrl=NO;
		for (i=0; (!foundctrl) && i<[elifeappdelegate.elifezonelist count]; i++) {
			currzone = [elifeappdelegate.elifezonelist objectAtIndex:i];
			for (j=0; (!foundctrl) && j<[currzone.roomlist count]; j++) {
				currroom = [currzone.roomlist objectAtIndex:j];
				for (k=0; (!foundctrl) && k<[currroom.tablist count]; k++) {
					currtab = [currroom.tablist objectAtIndex:k];
					for (l=0; (!foundctrl) && l<[currtab.controllist count]; l++) {
						currctrl = [currtab.controllist objectAtIndex:l];
						if ([currctrl.key isEqualToString:currentitem.key]) {
							foundctrl=YES;
							if ([currctrl.ctrlstatus isEqualToString:@"on"]) {
								itemcount++;
							}
							if (itemcount == indexPath.row) {
								currctrl.ctrlstatus=@"off";
								// send command "off" to elife
								NSString *msg = @"<CONTROL KEY=\"";
								msg = [msg stringByAppendingString:currentitem.key];
								msg = [msg stringByAppendingString:@"\" COMMAND=\"off\" EXTRA=\"\" EXTRA2=\"\" EXTRA3=\"\" EXTRA4=\"\" EXTRA5=\"\" />"];
								[sendmsgs addObject:msg];
								[myServer sendmessage];
								// Send notification message to any observers
								[[NSNotificationCenter defaultCenter] postNotificationName:currentitem.key object:nil];
								[[NSNotificationCenter defaultCenter] postNotificationName:[currentitem.key stringByAppendingString:@"_status"] object:nil];

								return;
							}
						}
					}
				}
			}
		}
	}
	
	return;
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



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];

}

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

- (void)registerWithNotification:(NSString *)thekey {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusUpdate:) name:thekey object:nil];
}

- (void)statusUpdate:(NSNotification *)notification {
	NSString *thekey = [notification name];
	[self.tableView setNeedsDisplay];
	[self.tableView reloadData];
}


@end

