//
//  logList.m
//  eLife3
//
//  Created by Richard Lemon on 7/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "logList.h"

static logList *sharedInstance = nil;

@implementation logList

+ (logList*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
		{
			sharedInstance = [[logList alloc] init];
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
	tabs_ = [[NSMutableArray alloc] init];
	controls_ = [[NSMutableDictionary alloc] init];	
	return self;
}
/**
 Gets the tab name for the index value or empty string
 */
-(NSString*)getTabNameForIndex:(NSUInteger)index {
	if (index < [tabs_ count])
		return [[tabs_ objectAtIndex:index] name_];
	return @"";
}
/**
 Gets the tab for the index value or empty string
 */
-(LogRecord*)getTabForIndex:(NSUInteger)index {
	if (index < [tabs_ count])
		return [tabs_ objectAtIndex:index];
	
	return nil;
}
/**
 Gets the number of log entries for the tab
 */
-(NSUInteger)getEntriesForIndex:(NSUInteger)index {
	
	if (index < [tabs_ count])
		return [[tabs_ objectAtIndex:index] count];

	return 0;
}
/**
 Gets the current (last) tab name
 */
-(LogRecord*)getCurrentTab {
	
	if ([tabs_ count] < 1)
		return nil;
	
	return [tabs_ objectAtIndex:[tabs_ count] - 1];
}
/**
 Gets the tab name for control name
 */
-(NSString*)getTab:(NSString*)controlName {
	
	return [controls_ objectForKey:controlName];
}
/**
 add a tab to the list of tabs
 */
-(Boolean)addTab:(LogRecord*)tab {

	[tabs_ addObject:tab];
	return YES;
}
/**
 add a control to the log list
 */
-(Boolean)addControl:(NSString*) controlKey {

	LogRecord* tab = [self getCurrentTab];
	if (tab == nil || [tab name_] == nil)
		return NO;

	// add control to tab map
	if ([controls_ objectForKey:controlKey] != nil)
		return NO; // can only have one log type per control

	[controls_ setObject:[tab name_] forKey:controlKey];
	
	[[NSNotificationCenter defaultCenter] addObserver:tab selector:@selector(addEntry:) name:controlKey object:nil];
	
	return YES;
}
/**
 returns the number of tabs (Sections) in the logs page
 */
-(int)count {
	return [tabs_ count];
}

@end
