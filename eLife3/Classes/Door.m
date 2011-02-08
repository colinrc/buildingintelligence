//
//  Door.m
//  eLife3
//
//  Created by Richard Lemon on 7/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "Door.h"


@implementation Door
@synthesize name_;
/**
 Construct from XML fragment
 */
-(id)initWithDictionary:(NSDictionary *)data {
	
	if ([self init])
	{
		name_ = [[data objectForKey:@"name"] copy];
		key_  = [[data objectForKey:@"key"] copy];
		pos_  = [[data objectForKey:@"pos"] copy];
	}
	return self;
}
/**
 Standard constructor thingie
 */
-(id)init {
	
	self = [super init];
	return self;
}
/**
 Standard destructor thingie
 */
-(void) release {
	[name_ release];
	[key_ release];
	[pos_ release];
}

@end
