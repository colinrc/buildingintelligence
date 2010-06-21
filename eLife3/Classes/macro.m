//
//  macro.m
//  eLife3
//
//  Created by Richard Lemon on 9/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "macro.h"


@implementation macro

@synthesize macroattr;
@synthesize running;

- (id)initWithDict:(NSDictionary *)thedict {
	self = [super init];
	
	self.macroattr = [thedict copy];
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
