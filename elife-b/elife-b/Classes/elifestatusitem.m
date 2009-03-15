//
//  elifestatusitem.m
//  elife-b
//
//  Created by Cameron Humphries on 11/01/09.
//  Copyright 2009 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifestatusitem.h"


@implementation elifestatusitem
@synthesize key;

- (id)initWithKey:(NSString *)thekey {
	self.key = thekey;
	
	return self;
}

@end
