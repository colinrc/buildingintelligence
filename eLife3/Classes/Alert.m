//
//  Alert.m
//  eLife3
//
//  Created by Richard Lemon on 4/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "Alert.h"
#import "Control.h"
#import "controlMap.h"

@implementation Alert
@synthesize name_;
/**
 Construct from XML fragment
 */
-(id)initWithDictionary:(NSDictionary *)data {
	
	if ([self init])
	{
		name_ = [[data objectForKey:@"name"] copy];
		icon_ = [[data objectForKey:@"icon"] copy];
		[self addKeys:[data objectForKey:@"keys"]];
	}
	return self;
}
/**
 Standard constructor thingie
 */
-(id)init {
	
	self = [super init];
	keys_ = [[NSMutableArray alloc] init];	
	return self;
}
/**
 Standard destructor thingie
 */
-(void) release {
	[name_ release];
	[icon_ release];
	[keys_ release]; // releases all objects as well
}
/**
 Add a key for the alert,
 need to subscribe to the control updates.
 */
-(void)addKeys:(NSString*)keysString {
	NSLog(@"Alert keys: %@", keysString);
	
	NSArray *controlKeys = [keysString componentsSeparatedByString:@","];
	if ([controlKeys count] < 1) {
		Control *control = [[controlMap sharedInstance] findControl:keysString];
		if (control != nil) {
			NSLog(@"Found key: %@", control.key_);
		}
		else {
			NSLog(@"Key not found:", keysString);
		}	
	}
	else {	
		for (NSString* key in controlKeys)
		{
			Control *control = [[controlMap sharedInstance] findControl:key];
			if (control != nil) {
				NSLog(@"Found key: %@", control.key_);
			}
			else {
				NSLog(@"Key not found:", key);
			}
		}
	}
}

@end
