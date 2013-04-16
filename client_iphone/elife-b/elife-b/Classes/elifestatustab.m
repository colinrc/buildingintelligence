//
//  elifestatustab.m
//  elife-b
//
//  Created by Cameron Humphries on 1/01/09.
//  Copyright 2009 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifestatustab.h"


@implementation elifestatustab
@synthesize tabname;
@synthesize tabattr;
@synthesize statusitems;

- (id)initWithName:(NSString *)thename andDict:(NSDictionary *)thedict {
	self.tabname = thename;
	self.tabattr = thedict;
	self.statusitems = [[NSMutableArray alloc] init];
	
	return self;
}

@end
