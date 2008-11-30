//
//  RoomItem.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "RoomItem.h"


@implementation RoomItem
@synthesize name;
@synthesize controltabs;
@synthesize roomTC;
@synthesize parentVC;

- (id)initWithName:(NSString *)thename {
	self.name = thename;
	self.controltabs = [[NSMutableArray alloc] init];
	self.roomTC = [[RoomControlsTabBarController alloc] init];
	[self.roomTC setViewControllers:controltabs animated:TRUE];
	self.roomTC.hidesBottomBarWhenPushed = TRUE;
	
	return self;
}

@end
