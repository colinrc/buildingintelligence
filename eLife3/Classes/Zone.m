//
//  Zone.m
//  eLife3
//
//  Created by Richard Lemon on 3/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "Zone.h"


@implementation Zone

@synthesize name_;

-(id)initWithDictionary:(NSDictionary *)data {
	
	if ([self init])
	{
		cycle_ = [[data objectForKey:@"cycle"] boolValue];
		skipForPDA_ = [[data objectForKey:@"skipForPDA"] boolValue];
		background_ = [[data objectForKey:@"background"] copy];
		alignment_ = [[data objectForKey:@"alignment"] copy];
		canOpen_ = [[data objectForKey:@"canOpen"] boolValue];
		hideFromList_ = [[data objectForKey:@"hideFromList"] boolValue];
		map_ = [[data objectForKey:@"map"] copy];
		name_ = [[data objectForKey:@"name"] copy];
	}	
	return self;
}
/**
 Standard constructor thingie
 */
-(id)init {
	
	self = [super init];
	rooms_ = [[NSMutableDictionary alloc] init];
	roomNames_ = [[NSMutableArray alloc] init];	
	return self;
}
/**
 Standard destructor thingie
 
-(void)release {
	[background_ release];
	[alignment_ release];
	[map_ release];
	[name_ release];
	[rooms_ release]; // releases all objects as well
	[roomNames_ release]; // releases all objects as well
} */
/**
 Add a new room to the zone
 */
-(Boolean)addRoom:(Room*)room {
	NSString *tmp = room.name_;
	
	if ([rooms_ objectForKey:tmp] == nil) {
		[rooms_ setObject:room forKey:[room name_]];
		[roomNames_ addObject:room.name_];
		return YES;
	}
	
	// error room already added
	return NO;
}
/**
 Add a new alert to the zone
 */
-(Boolean)addAlert:(Alert*)alert {
	
	Room* currentRoom = [self getCurrentRoom];
	
	if (currentRoom == nil)
		return NO;
	
	return [currentRoom addAlert:alert];
}
/**
 Add a new door to the zone
 */
-(Boolean)addDoor:(Door*)door {
	
	Room* currentRoom = [self getCurrentRoom];
	
	if (currentRoom == nil)
		return NO;
	
	return [currentRoom addDoor:door];
}
/**
 get the last room
 */
-(Room*)getCurrentRoom {
	
	if ([roomNames_ count] < 1)
		return nil;
	
	NSString* roomName = [roomNames_ objectAtIndex:[roomNames_ count] - 1];
	return [rooms_ objectForKey:roomName];
}

-(Room*)getRoom:(NSUInteger)index {
	if ((index < 0) || index > [roomNames_ count]) {
		NSLog(@"tried to index out of roomNames_ bounds");
		return nil;
	}
	return [rooms_ objectForKey:[roomNames_ objectAtIndex:index]];	
}	
/**
 Adds a tab to the current room
 */
-(Boolean)addTab:(NSString *)tabName {
	Room* currentRoom = [self getCurrentRoom];
	
	if (currentRoom == nil)
		return NO;
	
	return [currentRoom addTab:tabName];	
}
/**
 adds a control to the current room
 */
-(Boolean)addControl: (Control*) control {
	Room* currentRoom = [self getCurrentRoom];
	
	if (currentRoom == nil)
		return NO;
	
	return [currentRoom addControl:control];	
}

/**
 get number of roons
 */
-(int)count {
	return [rooms_ count];
}

@end
