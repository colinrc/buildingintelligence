//
//  controlMap.m
//  eLife3
//
//  Created by Richard Lemon on 15/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "controlMap.h"

@implementation controlMap

@synthesize controls_;

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
	if (control.key_ == nil){
		// wont be seeing updates for this object
		return NO;
	}
	
	Control * tmp = [controls_ objectForKey:control.key_];
	if (tmp == nil) // new control, set and leave
	{
		// setObject retains the control object 
		[controls_ setObject:control forKey:control.key_];
		return YES;
	}
	
	// already have a control set fields equal
	if (control.type_ != nil)
	{
		if ( tmp.type_ == nil )
		{
			// type_ accessor is type copy
			tmp.type_ = control.type_ ;
		}
		else if (![control.type_ isEqualToString:tmp.type_])
		{
			// we have a problem..
			NSLog(@"Control %@ has 2 different types [%@ != %@]", control.key_, control.type_, tmp.type_);
			return NO;
		}
	}
	
	if (control.name_ != nil) {
		
		if ((tmp.name_ == nil) || ([tmp.name_ length] == 0)) {
			// name_ accessor is type copy
			tmp.name_ = control.name_ ;
		} else if (![control.name_ isEqualToString:tmp.name_]) {
			// something odd many named string
			NSLog(@"Control %@ has 2 different names [%@ != %@]", control.key_, control.name_, tmp.name_);
		}
	}	

	if ((control.room_ != nil) && (tmp.room_ == nil)){
		// name_ accessor is type copy
		tmp.room_ = control.room_;
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
