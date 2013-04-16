//
//  eliferoomtab.m
//  elife
//
//  Created by Cameron Humphries on 5/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "eliferoomtab.h"


@implementation eliferoomtab
@synthesize name;
@synthesize tabattr;
@synthesize controllist;

- (id) initWithName:(NSString *)thename andAttributes:(NSDictionary *)theattr {
	self.name = thename;
	self.tabattr = theattr;
	self.controllist = [[NSMutableArray alloc] init];
	
	return self;
}

@end
