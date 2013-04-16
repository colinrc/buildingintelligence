//
//  ZoneItem.m
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "ZoneItem.h"


@implementation ZoneItem
@synthesize name;
@synthesize zoneelemVC;
@synthesize parentNC;

- (id)initWithName:(NSString *)newname {
	self.name = newname;
	self.zoneelemVC = [[RoomsTableViewController alloc] init];
	self.zoneelemVC.title = newname;
	
	return self;
}

@end
