//
//  statusGroup.m
//  eLife3
//
//  Created by Richard Lemon on 16/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "statusGroup.h"


@implementation statusGroup

@synthesize name_;
@synthesize icon_;
@synthesize show_;
@synthesize hide_;

-(id)initWithDictionary:(NSDictionary *)data {

	self = [super init];
	// accessors are type copy so we *should* be right...
	self.name_ = [data objectForKey:@"name"];
	self.icon_ = [data objectForKey:@"icon"];
	self.show_ = [data objectForKey:@"show"];
	self.hide_ = [data objectForKey:@"hide"];
	
	return self;
}

// need to free the copied strings
-(void)release {

	[name_ release];
	[icon_ release];
	[show_ release];
	[hide_ release];
}

@end
