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
		[zones_ setObject:zone forKey:zone.name_ ];
		[zoneNames_ addObject:zone.name_ ];
		return YES;
	}
	// zone already exists, error...
	NSAssert(NO, @"Unfinished code");
	return NO;
}
/**
 Gets the last zone added
 */
-(Zone*) getCurrentZone {
	if ([zoneNames_ count] < 1)
		return nil;
	
	NSString* zoneName = [zoneNames_ objectAtIndex:[zoneNames_ count] -1];
	return [zones_ objectForKey:zoneName];
}

/**
 Add a room to the current zone
 */
-(Boolean)addRoom:(Room *)room {
	Zone* currentZone = [self getCurrentZone];
	
	if (currentZone == nil) {
		return NO;
	}
	
	return [currentZone addRoom:room];		 
}
/**
 Add an alert to the current zone
 */
-(Boolean)addAlert:(Alert *) alert {
	Zone* currentZone = [self getCurrentZone];
	
	if (currentZone == nil) {
		return NO;
	}
	
	return [currentZone addAlert: alert];		 
}
/**
 Add a door to the current zone
 */
-(Boolean)addDoor:(Door *) door {
	Zone* currentZone = [self getCurrentZone];
	
	if (currentZone == nil) {
		return NO;
	}
	
	return [currentZone addDoor: door];		 
}
/**
 Add a control to the current zone
*/
-(Boolean)addControl:(Control*)control {
	Zone* currentZone = [self getCurrentZone];

	if (currentZone == nil) {
		NSAssert(NO, @"Unfinished code");
		return NO;
	}
	return [currentZone addControl: control];
}
/**
 Add a tab to the current zone
 */
-(Boolean)addTab:(NSString*)tabName {
	Zone* currentZone = [self getCurrentZone];
	
	if (currentZone == nil) {
		NSAssert(NO, @"Unfinished code");
		return NO;
	}
	
	return [currentZone addTab:tabName];
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
/**
 Returns the number of rooms in the Zone by index
 */
-(NSUInteger)roomsInZone:(NSUInteger)index {
	
	if ((index < 0) || index > [zoneNames_ count]) {
		NSLog(@"tried to index out of zoneNames_ bounds");
		return 0;
	}	
	
	return [[zones_ objectForKey:[zoneNames_ objectAtIndex:index]] count];
	
}
/**
 Returns a Zone for the given index
 */
-(Zone*)getZone:(NSUInteger)index {

	if ((index < 0) || index > [zoneNames_ count]) {
		NSLog(@"tried to index out of zoneNames_ bounds");
		return nil;
	}
	return [zones_ objectForKey:[zoneNames_ objectAtIndex:index]];	
}

@end
