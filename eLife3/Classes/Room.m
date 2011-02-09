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
		name_ = [[data objectForKey:@"name"] copy];
		canOpen_ = [[data objectForKey:@"canOpen"] boolValue];
		switchZone_ = [[data objectForKey:@"switchZone"] copy];
		poly_ = [[data objectForKey:@"poly"] copy];
	}
	return self;
}
/**
 Standard constructor thingie
 */
-(id)init {
	
	self = [super init];
	tabs_ = [[NSMutableDictionary alloc] init];	
	alerts_ = [[NSMutableArray alloc] init];
	doors_ = [[NSMutableArray alloc] init];
	return self;
}
/**
 Standard destructor thingie
 */
-(void)dealloc {
	[name_ release];
	[switchZone_ release];
	[poly_ release];
	[tabs_ release];   // releases all objects as well
	[alerts_ release]; // releases all objects as well
	[doors_ release];  // releases all objects as well
	[super dealloc];
}
/**
 Add alert
 */
-(Boolean)addAlert:(Alert*)alert {
	[alerts_ addObject:alert];
	return YES;
}
/**
 Add door
 */
-(Boolean)addDoor:(Door*)door {
	[doors_ addObject:door];
	return YES;
}
/**
 Add Tab to room
 */
-(Boolean)addTab:(NSString*) tabName {
	// get the item from the map
	NSMutableArray *tmpArray = [tabs_ objectForKey:tabName];
	
	if (tmpArray == nil)
	{
		[tabNames_ addObject:tabName];
		NSMutableArray *newArray = [[NSMutableArray alloc] init];
		[tabs_  setObject:newArray forKey:tabName];
		[newArray release]; // collection holds reference
	}

	return YES;
}
/**
 Add control to room
 */
-(Boolean)addControl: (Control*)control {
	// get the item from the map
	if ([tabNames_ count] < 1)
		return NO;
	
	NSString* tabName = [tabNames_ objectAtIndex:[tabNames_ count] -1];
	NSMutableArray *tmpArray =  [tabs_ objectForKey:tabName];
	
	if (tmpArray == nil) {
		return NO;
	}

	// add the control to the array
	[tmpArray addObject:control];
	return YES;
}

@end
