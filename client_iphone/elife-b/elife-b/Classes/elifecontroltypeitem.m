//
//  elifecontroltypeitem.m
//  elife
//
//  Created by Cameron Humphries on 20/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifecontroltypeitem.h"


@implementation elifecontroltypeitem
@synthesize ctrlitemtype;
@synthesize itemattrs;

-(id)initWithType:(NSString *)thetype andAttrs:(NSDictionary *)theattrs {
	self.ctrlitemtype = thetype;
	self.itemattrs = theattrs;
	
	return self;
}

@end
