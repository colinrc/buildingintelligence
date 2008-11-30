//
//  elifecontroltypeitem.m
//  elife
//
//  Created by Cameron Humphries on 20/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifecontroltypeitem.h"


@implementation elifecontroltypeitem
@synthesize ctrlrowtype;
@synthesize rowattrs;

-(id)initWithType:(NSString *)thetype andAttrs:(NSDictionary *)theattrs {
	self.ctrlrowtype = thetype;
	self.rowattrs = theattrs;
	
	return self;
}

@end
