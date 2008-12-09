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
@synthesize running;

- (id)initWithDict:(NSDictionary *)thedict {
	self.macroattr = thedict;
	if ([[thedict objectForKey:@"RUNNING"] isEqualToString:@"1"]) {
		self.running = YES;
	} else {
		self.running = NO;
	}

	return self;
}

- (BOOL)isRunning {
	return self.running;
}

@end
