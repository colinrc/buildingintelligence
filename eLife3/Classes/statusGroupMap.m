//
//  statusGroupMap.m
//  eLife3
//
//  Created by Richard Lemon on 16/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "statusGroupMap.h"
#import "controlMap.h"

static statusGroupMap * sharedInstance = nil;


@implementation statusGroupMap

@synthesize group_names_;
@synthesize group_data_;


+ (statusGroupMap*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
		{
			sharedInstance = [[statusGroupMap alloc] init];
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

	group_names_ = [[NSMutableArray alloc] initWithCapacity:5];
	group_data_ = [[NSMutableDictionary alloc] initWithCapacity:5];

	return self;
}

// add a status group to array
-(void)addGroup:(NSDictionary *)data {
	
	statusGroup *group = [[statusGroup alloc] initWithDictionary:data];
	[group_names_ addObject:group];
	//[group release]; // collection has added a retain
}

// add a status item to the current group tag 
-(void)addStatusItem:(Control *)control {
	// get the item from the map
	statusGroup *currentKey = [group_names_ objectAtIndex:([group_names_ count] - 1)];
	NSMutableArray *tmpArray = [group_data_ objectForKey:currentKey.name_];
	
	if (tmpArray == nil)
	{
		NSMutableArray *newArray = [[NSMutableArray alloc] init];
		[group_data_  setObject:newArray forKey:currentKey.name_];
		[newArray release]; // collection holds reference
		tmpArray = [group_data_ objectForKey:currentKey.name_];
	}
	// add something to the array
	[tmpArray addObject:[control.key_ copy]];
	
}

// return the status group object at the index
-(statusGroup*)getGroup:(NSInteger)group {
	@try {
		return [group_names_ objectAtIndex:group];
	}
	@catch (NSException * e) {
		
	}
	return nil;
}

// return the number of active items for the group
-(NSInteger)activeItems:(NSInteger)group {
	NSInteger count = 0;
	@try {
		statusGroup *groupKey = [group_names_ objectAtIndex:group];
		NSMutableArray *tmpArray = [group_data_ objectForKey:groupKey.name_];
		
		for (int i = 0; i < [tmpArray count]; i++) {
			Control *control = [[controlMap sharedInstance] findControl:[tmpArray objectAtIndex:i]];
			if ([control.command_ isEqualToString:groupKey.show_])
				count++;
		}
	}
	@catch (NSException * e) {
	}
	
	return count;
}

// return the active item for the group and row
-(Control*)activeControl:(NSInteger)section:(NSInteger)row {
	NSInteger count = 0;
	statusGroup *groupKey = [group_names_ objectAtIndex:section];
	NSMutableArray *tmpArray = [group_data_ objectForKey:groupKey.name_];
	
	for (int i = 0; i < [tmpArray count]; i++) {
		Control *control = [[controlMap sharedInstance] findControl:[tmpArray objectAtIndex:i]];
		if ([control.command_ isEqualToString:groupKey.show_])
		{
			if (count == row)
				return control;
			else
				count++;
		}
	}
	return nil;
}

@end
