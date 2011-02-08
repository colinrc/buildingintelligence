//
//  LogRecord.m
//  eLife3
//
//  Created by Richard Lemon on 8/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "LogRecord.h"


@implementation LogRecord

@synthesize name_;
/**
 Construct from XML fragment
 */
-(id)initWithDictionary:(NSDictionary *)data {
	
	if ([self init])
	{
		name_ = [[data objectForKey:@"name"] copy];
		icon_ = [[data objectForKey:@"icon"] copy];
		tally_ = [[data objectForKey:@"type"] isEqualToString:@"tally"];
		timeFormat_ = [[data objectForKey:@"timeformat"] copy];
	}
	return self;
}

/**
 Standard constructor thingie
 */
-(id)init {
	
	self = [super init];
	messages_ = [[NSMutableArray alloc] init];
	format_ = [[NSMutableArray alloc] init];
	return self;
}
/**
 Standard destructor thingie
 */
-(void)release {
	[name_ release];
	[icon_ release];
	[timeFormat_ release];
	[messages_ release]; // releases all objects as well
	[format_ release]; // releases all objects as well
}
@end
