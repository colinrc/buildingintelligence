//
//  eliferoom.m
//  elife
//
//  Created by Cameron Humphries on 5/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "eliferoom.h"


@implementation eliferoom
@synthesize name;
@synthesize roomattr;
@synthesize tablist;

- (id) initWithName:(NSString *)thename andAttributes:(NSDictionary *)theattr {
	self.name = thename;
	self.roomattr = theattr;
	self.tablist = [[NSMutableArray alloc] init];
	
	return self;
}

@end
