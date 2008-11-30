//
//  ControlItem.m
//  elife
//
//  Created by Cameron Humphries on 21/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "ControlItem.h"


@implementation ControlItem
@synthesize tabname;
@synthesize name;
@synthesize key;

- (id)initWithName:(NSString *)newname andKey:(NSString *)newkey andTabName:(NSString *)newtabname{
	self.tabname = newtabname;
	self.name = newname;
	self.key = newkey;
	
	return self;
}

@end
