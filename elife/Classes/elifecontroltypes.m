//
//  elifecontroltypes.m
//  elife
//
//  Created by Cameron Humphries on 20/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifecontroltypes.h"


@implementation elifecontroltypes
@synthesize controltype;
@synthesize displayrows;

-(id)initWithType:(NSString *)thetype {
	self.controltype = thetype;
	displayrows = [[NSMutableArray alloc] init];
	
	return self;
}

@end
