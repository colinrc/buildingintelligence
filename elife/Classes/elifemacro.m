//
//  elifemacro.m
//  elife
//
//  Created by Cameron Humphries on 28/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifemacro.h"


@implementation ElifeMacro
@synthesize name;
@synthesize key;
@synthesize status;

- (id)initWithName:(NSString *)thename andKey:(NSString *)thekey currentStatus:(NSInteger)thestatus {
	self.name = thename;
	self.key = thekey;
	self.status = thestatus;
	
	return self;
}


@end
