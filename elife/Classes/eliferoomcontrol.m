//
//  eliferoomcontrol.m
//  elife
//
//  Created by Cameron Humphries on 5/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "eliferoomcontrol.h"


@implementation eliferoomcontrol
@synthesize name;
@synthesize key;
@synthesize roomctrlattr;

- (id) initWithName:(NSString *)thename andKey:(NSString *)thekey andAttributes:(NSDictionary *)theattr {
	self.name = thename;
	self.key = thekey;
	self.roomctrlattr = theattr;
	
	return self;
}

@end
