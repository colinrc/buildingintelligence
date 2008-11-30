//
//  ZonesTableViewController.h
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoneItem.h"
#import "RoomsTableViewController.h"

@interface ZonesTableViewController : UITableViewController {
	//NSMutableArray *zonelist;
	RoomsTableViewController *roomsTabView;
}

//@property (nonatomic, retain) NSMutableArray *zonelist;
@property (nonatomic, retain) RoomsTableViewController *roomsTabView;

//- (void)addZone:(ZoneItem *)newzone;

@end
