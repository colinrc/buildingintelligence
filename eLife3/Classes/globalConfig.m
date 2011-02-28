//
//  globalConfig.m
//  eLife3
//
//  Created by Richard Lemon on 18/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "globalConfig.h"

static globalConfig *sharedInstance = nil;

@implementation globalConfig

+(globalConfig*)sharedInstance {
	@synchronized(self)
	{
		if (sharedInstance == nil) {
			sharedInstance = [[globalConfig alloc] init];
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
	
	logging_ = [[logList alloc] init];
	controls_ = [[controlMap alloc] init];
	macros_ = [[macroList alloc] init];
	zones_ = [[zoneList alloc] init];
	statusbar_ = [[statusGroupMap alloc] init];
	
	return self;
}

//======== getter and setter stuff ===========
@synthesize logging_;
@synthesize controls_;
@synthesize macros_;
@synthesize zones_;
@synthesize statusbar_;

-(void)reset {
	[logging_ release];
	[controls_ release];
	[macros_ release];
	[zones_ release];
	[statusbar_ release];

	logging_ = [[logList alloc] init];
	controls_ = [[controlMap alloc] init];
	macros_ = [[macroList alloc] init];
	zones_ = [[zoneList alloc] init];
	statusbar_ = [[statusGroupMap alloc] init];
}

@end
