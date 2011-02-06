//
//  Room.m
//  eLife3
//
//  Created by Richard Lemon on 3/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "Room.h"


@implementation Room

@synthesize name_;
/**
 Construct from XML fragment
 */
-(id)initWithDictionary:(NSDictionary *)data {
	
	if ([self init])
	{
		name_ = [data objectForKey:@"name"];
		canOpen_ = [[data objectForKey:@"canOpen"] boolValue];
		switchZone_ = [data objectForKey:@"switchZone"];
		poly_ = [data objectForKey:@"poly"];
	}
	return self;
}
/**
 Standard constructor thingie
 */
-(id)init {
	
	self = [super init];
	tabs_ = [[NSMutableDictionary alloc] init];	
	return self;
}
/**
 Add control to room
 */
-(Boolean)addControl:(NSString*) currentTab: (Control*)control {
	// get the item from the map
	NSMutableArray *tmpArray = [tabs_ objectForKey:currentTab];
	
	if (tmpArray == nil)
	{
		NSMutableArray *newArray = [[NSMutableArray alloc] init];
		[tabs_  setObject:newArray forKey:currentTab];
		[newArray release]; // collection holds reference
		// now get it for the addition
		tmpArray = [tabs_ objectForKey:currentTab];
	}
	// add something to the array
	[tmpArray addObject:control];
	return YES;
}

@end
