//
//  elifezone.m
//  elife
//
//  Created by Cameron Humphries on 4/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifezone.h"


@implementation elifezone
@synthesize name;
@synthesize zoneattr;
@synthesize roomlist;

- (id)initWithName:(NSString *)thename andAttributes:(NSDictionary *)theattr {
	self.name = thename;
	self.zoneattr = theattr;
	self.roomlist = [[NSMutableArray alloc] init];
	
	return self;
}

@end
