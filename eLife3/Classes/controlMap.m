//
//  controlMap.m
//  eLife3
//
//  Created by Richard Lemon on 15/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "controlMap.h"

static controlMap * sharedInstance = nil;

@implementation controlMap

@synthesize controls_;


+ (controlMap*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
		{
			sharedInstance = [[controlMap alloc] init];
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
	controls_ = [[NSMutableDictionary alloc] init];
	return self;
}

/**
 Adds a control to the control map, returns false if it can't
 */
-(Boolean)addControl:(Control *)control {
	if (control.key_ == nil)
	{
		// wont be seeing updates for this object
		return NO;
	}
	
	Control * tmp = [controls_ objectForKey:control.key_];
	if (tmp == nil)
	{
		// setObject retains the control object 
		[controls_ setObject:control forKey:control.key_];
		return YES;
	}
	
	if (control.type_ != nil)
	{
		if (tmp.type_ != nil && control.type_ != tmp.type_)
		{
			// we have a problem..
			NSLog(@"Control %@ has 2 different types [%@ != %@]", control.key_, control.type_, tmp.type_);
			return NO;
		}
		else {
			// type_ accessor is type copy
			tmp.type_ = control.type_ ;
		}
	}

	if ((control.name_ != nil) && (tmp.name_ == nil)){
		// name_ accessor is type copy
		tmp.name_ = control.name_ ;
	}	
	
	return YES;
}

/**
 Finds a control for the given key
 */
-(id)findControl:(NSString *)key {
	return [controls_ objectForKey:key];
}

/**
 Update the state for the current control
 */
-(Boolean)updateControl:(NSDictionary *)data {
	
	Control *tmpCtl = [controls_ objectForKey:[data objectForKey:@"KEY"]];
	
	if (tmpCtl == nil)
	{
		// ERROR we got a server message for an unknown control
		// TODO: Think about message and stuff
		NSLog(@"Message for unkown control %@", [data objectForKey:@"KEY"]);
		return NO;
	}

	// all of the accessors are type copy for the control object
	tmpCtl.command_ = [data objectForKey:@"COMMAND"];
	tmpCtl.extra_  = [data objectForKey:@"EXTRA"];
	tmpCtl.extra2_ = [data objectForKey:@"EXTRA2"];
	tmpCtl.extra3_ = [data objectForKey:@"EXTRA3"];
	tmpCtl.extra4_ = [data objectForKey:@"EXTRA4"];
	tmpCtl.extra5_ = [data objectForKey:@"EXTRA5"];

	// Send notification message to any observers
	[[NSNotificationCenter defaultCenter] postNotificationName:tmpCtl.key_ object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:[tmpCtl.key_ stringByAppendingString:@"_status"] object:self];
	
	return YES;
}

@end
