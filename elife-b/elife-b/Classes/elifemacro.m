//
//  elifemacro.m
//  elife
//
//  Created by Cameron Humphries on 28/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifemacro.h"


@implementation ElifeMacro
@synthesize macroattr;

- (id)initWithDict:(NSDictionary *)thedict {
	self.macroattr = thedict;
	
	return self;
}


@end
