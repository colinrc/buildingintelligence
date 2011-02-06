//
//  zoneList.m
//  eLife3
//
//  Created by Richard Lemon on 3/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "zoneList.h"

static zoneList * sharedInstance = nil;

@implementation zoneList

/**
 Singleton ctr
 */
+ (zoneList*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
		{
			sharedInstance = [[zoneList alloc] init];
		}
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

/**
 Standard constructor thingie
 */
-(id)init {
	
	self = [super init];

	zones_ = [[NSMutableDictionary alloc] initWithCapacity:5];
	zoneNames_ = [[NSMutableArray alloc] initWithCapacity:5];
	
	return self;
}


/**
 Add the zone to the zone list
 */
-(Boolean)addZone:(Zone* )zone {
	
	if ([zones_ objectForKey:zone.name_] == nil) { 
		[zones_ setObject:zone forKey:zone.name_];
		[zoneNames_ addObject:zone.name_];
		return YES;
	}
	// zone already exists, error...
	NSAssert(NO, @"Unfinished code");
	return NO;
}
	
/**
 Add a room to the specified zone
 */
-(Boolean)addRoom:(Room *)room {
	if ([zoneNames_ count] < 1)
		return NO;
	
	NSString* zoneName = [zoneNames_ objectAtIndex:[zoneNames_ count] -1];
	Zone* currentZone = [zones_ objectForKey:zoneName];
	
	if (currentZone == nil) {
		return NO;
	}
	
	return [currentZone addRoom:room];		 
}
/**
 Add a room to the specified zone
 */
-(Boolean)addAlert:(Alert *) alert {
	if ([zoneNames_ count] < 1)
		return NO;
	
	NSString* zoneName = [zoneNames_ objectAtIndex:[zoneNames_ count] -1];
	Zone* currentZone = [zones_ objectForKey:zoneName];
	
	if (currentZone == nil) {
		return NO;
	}
	
	return [currentZone addAlert: alert];		 
}
/**
 Add a control to the specified zone:room 
*/
-(Boolean)addControl:(NSString*)roomName:(NSString*)tabName:(Control*)control {
	
	if ([zoneNames_ count] < 1)
		return NO;
	
	NSString* zoneName = [zoneNames_ objectAtIndex:[zoneNames_ count] -1];
	Zone* currentZone = [zones_ objectForKey:zoneName];

	if (currentZone == nil) {
		NSAssert(NO, @"Unfinished code");
		return NO;
	}
	
	Room* currentRoom = [currentZone getCurrentRoom:roomName];
	if (currentRoom == nil){ 
		NSAssert(NO, @"Unfinished code");
		return NO;
	}
	
	return [currentRoom addControl: tabName: control];
}
/**
 Returns the number of zones
 */
-(int)count {
	return [zoneNames_ count];
}
/**
 returns name for index "" if index out of bounds
*/
-(NSString*)nameFor:(NSUInteger)index {
	if ((index < 0) || index > [zoneNames_ count]) {
		NSLog(@"tried to index out of zoneNames_ bounds");
		return @"";
	}

	return [zoneNames_ objectAtIndex:index];
}

-(NSUInteger)roomsInZone:(NSUInteger)index {
	
	if ((index < 0) || index > [zoneNames_ count]) {
		NSLog(@"tried to index out of zoneNames_ bounds");
		return 0;
	}	
	
	return [[zones_ objectForKey:[zoneNames_ objectAtIndex:index]] count];
	
}

-(Zone*)getZone:(NSUInteger)index {

	if ((index < 0) || index > [zoneNames_ count]) {
		NSLog(@"tried to index out of zoneNames_ bounds");
		return nil;
	}
	return [zones_ objectForKey:[zoneNames_ objectAtIndex:index]];	
}

@end
