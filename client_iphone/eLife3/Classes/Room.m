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
	tabNames_ = [[NSMutableArray alloc] init];
	return self;
}
/**
 Standard destructor thingie
 */
-(void)dealloc {
	NSLog(@"************** dealloc room");
	
	[name_ release];
	[switchZone_ release];
	[poly_ release];
	[tabs_ release];	// releases all objects as well
	[alerts_ release];	// releases all objects as well
	[doors_ release];	// releases all objects as well
	[tabNames_ release];// releases all objects as well
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
		NSString* tmpStr = [tabName copy];
		[tabNames_ addObject:tmpStr];
		[tmpStr release];
		NSMutableArray *newArray = [[NSMutableArray alloc] init];
		[tabs_  setObject:newArray forKey:tabName];
		[newArray release]; // collection holds reference
	}

	return YES;
}
/**
 Gets the contents of the current tab
 */
-(NSMutableArray*)currentTab {
	// get the item from the map
	if ([tabNames_ count] < 1)
		return nil;
	
	return [tabs_ objectForKey:[self tabNameForIndex:[tabNames_ count] - 1]];	
}
/**
 Add control to room
 */
-(Boolean)addControl: (Control*)control {
	
	NSMutableArray* tmpArray = [self currentTab];
	
	if (tmpArray == nil) {
		return NO;
	}

	// add the control to the array
	[tmpArray addObject:control];
	return YES;
}
/**
 Returns the number of tabs in this room
 */
-(NSUInteger)tabCount {
	return [tabNames_ count];
}
/**
 Returns the tab name for the given index, empty string if out of bounds
 */
-(NSString*)tabNameForIndex:(NSUInteger)index {
	if (index >= [tabNames_ count])
		return @"";
	
	return [tabNames_ objectAtIndex:index];
}
/**
 Gets the array of controls for the tab
 */
-(NSMutableArray*)tabForIndex:(NSUInteger)index {
	
	return [tabs_ objectForKey:[self tabNameForIndex:index]];
}
/**
 Returns the number of controls in this tab
 */
-(NSUInteger)itemCountForTabIndex:(NSUInteger) index {
	
	NSMutableArray* tmpArray = [self tabForIndex:index];
	if (tmpArray == nil)
		return 0;
	
	return [tmpArray count];
}
/**
 Returns the control for the tab and item index
 */
-(Control*)itemForIndex:(NSUInteger) tabIndex:(NSUInteger) itemIndex {
	
	NSMutableArray* tmpArray = [self tabForIndex:tabIndex];
	if (tmpArray == nil)
		return nil;
	
	if (itemIndex >= [tmpArray count])
		return nil;

	return [tmpArray objectAtIndex:itemIndex];
}

@end
