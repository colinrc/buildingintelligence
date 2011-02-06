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
		background_ = [data objectForKey:@"background"];
		alignment_ = [data objectForKey:@"alignment"];
		canOpen_ = [[data objectForKey:@"canOpen"] boolValue];
		hideFromList_ = [[data objectForKey:@"hideFromList"] boolValue];
		map_ = [data objectForKey:@"map"];
		name_ = [data objectForKey:@"name"];
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
	alerts_ = [[NSMutableArray alloc] init];	
	return self;
}

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
 Add a new room to the zone
 */
-(Boolean)addAlert:(Alert*)alert {

	[alerts_ addObject:alert];
	return YES;
}
/**
 get the last room
 */
-(Room*)getCurrentRoom:(NSString*)roomName {
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
 get number of roons
 */
-(int)count {
	return [rooms_ count];
}

@end
