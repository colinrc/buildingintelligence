//
//  Control.m
//  eLife3
//
//  Created by Richard Lemon on 15/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "Control.h"


@implementation Control

@synthesize name_;
@synthesize key_;
@synthesize type_;
@synthesize extra_;
@synthesize extra2_;
@synthesize extra3_;
@synthesize extra4_;
@synthesize extra5_;
@synthesize tally_;
@synthesize room_;

-(id)initWithDictionary:(NSDictionary *)data {

	self = [self init];
	keys_ = [[NSMutableDictionary alloc ]initWithDictionary:data copyItems:YES];
	NSString *tmp = [data objectForKey:@"name"];
	self.name_ = (tmp != nil) ? tmp : @"";
	
	tmp = [data objectForKey:@"key"];
	self.key_ = (tmp != nil) ? tmp : @"";
	
	if ([key_ isEqualToString:@"KEYPAD"]) NSLog(@"name=%@",name_);
	
	tmp = [data objectForKey:@"type"];
	self.type_ = (tmp != nil) ? tmp : @"";
	tmp = [data objectForKey:@"command"];
	self.command_ = tmp;
	tmp = [data objectForKey:@"extra_"];
	self.extra_ = (tmp != nil) ? tmp : @"";
	tmp = [data objectForKey:@"extra2_"];
	self.extra2_ = (tmp != nil) ? tmp : @"";
	tmp = [data objectForKey:@"extra3_"];
	self.extra3_ = (tmp != nil) ? tmp : @"";
	tmp = [data objectForKey:@"extra4_"];
	self.extra4_ = (tmp != nil) ? tmp : @"";
	tmp = [data objectForKey:@"extra5_"];
	self.extra5_ = (tmp != nil) ? tmp : @"";

	self.tally_ = 0;
	self.room_ = @"";
	return self;
}
/**
 Standard constructor thingie
 */
-(id)init {
	
	self = [super init];
	state_info_ = [[NSMutableDictionary alloc] init];
	return self;
}
/**
 Standard destructor thingie
 */
-(void)dealloc {
	[name_ release];
	[key_ release];
	[type_ release];
	[command_ release];
	[extra_ release];
	[extra2_ release];
	[extra3_ release];
	[extra4_ release];
	[extra5_ release];
	[room_ release];
	[state_info_ release];
	[keys_ release];
	[super dealloc];
}
/**
 Custom getter for the command_ string
 */
-(NSString*)command_ {
	return command_;
}
/**
 setter for the command string, custom implementation to update the state
 map as well.
 If the command is on | off then set the control state to on or off
 if command == on | off
	state_info_["state"] = command
*/
-(void)setCommand_:(NSString *) newCommand {
	if (newCommand != command_) {
		[command_ release];
		command_ = [newCommand copy];
		if (([command_ caseInsensitiveCompare:@"on"] == NSOrderedSame) || 
			([command_ caseInsensitiveCompare:@"off"] == NSOrderedSame)) {
			[state_info_ setObject:command_ forKey:@"state"];
		}
	}
}
/**
 Custom getter for the extra string
 */
-(NSString*) extra_ {
	return extra_;
}
/**
 setter for the extra string, custom implementation to update the state
 map as well
 Set the control state with the command as the key to the extra value
 state_info_[command] = extra 
 */
-(void)setExtra_:(NSString *) newExtra {
	if (extra_ != newExtra) {
		[extra_ release];
		extra_ = [newExtra copy];
		if (extra_ != nil && command_ != nil)
			[state_info_ setObject:extra_ forKey:command_];
	}
}
/**
 Get the stored state
 */
-(NSString*) stateFor:(NSString*)key {
	if (key == nil)
		return nil;
	return [state_info_ objectForKey:key];
}
/** 
 Get the key-value for the control
 */
-(NSString*) valueFor:(NSString*)key {
	return [keys_ objectForKey:key] ;
}
/**
 Set the key dictionary, loop the new dict and push the
 Key value pairs in
 */
-(void)setKeys_:(NSMutableDictionary *) newKey {
	for (NSString* current_key in newKey) {
		if ([keys_ objectForKey:current_key] == nil) {
			[keys_ setObject:[[newKey objectForKey:current_key] copy] forKey:current_key];
		}
		else if ([[keys_ objectForKey:current_key] caseInsensitiveCompare:[newKey objectForKey:current_key]] != NSOrderedSame) {
			NSLog(@"control key differs %@ ",current_key);
		}
	}
}
/** 
 Get the XML attr dictionary
 */
-(NSMutableDictionary*) keys_ {
	return keys_;
}

@end
