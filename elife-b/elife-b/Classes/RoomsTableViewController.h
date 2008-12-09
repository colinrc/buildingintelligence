//
//  RoomsTableViewController.h
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomItem.h"
//#import "RoomControlsTabBarController.h"
#import "ControlsTableViewController.h"

@interface RoomsTableViewController : UITableViewController {
	//NSMutableArray *roomlist;
	NSInteger zoneidx;
	NSInteger roomidx;
	//RoomControlsTabBarController *roomTabBar;
	ControlsTableViewController *roomTableView;
}

//@property (nonatomic, retain) NSMutableArray *roomlist;
@property (nonatomic) NSInteger zoneidx;
@property (nonatomic) NSInteger roomidx;
//@property (nonatomic, retain) RoomControlsTabBarController *roomTabBar;
@property (nonatomic, retain) ControlsTableViewController *roomTableView;

//- (void)addRoom:(RoomItem *)newroomitem;

@end
