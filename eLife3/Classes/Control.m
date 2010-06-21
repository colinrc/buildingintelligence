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
@synthesize command_;
@synthesize extra_;
@synthesize extra2_;
@synthesize extra3_;
@synthesize extra4_;
@synthesize extra5_;

-(id)initWithDictionary:(NSDictionary *)data {

	self = [super init];
	
	self.name_ = [data objectForKey:@"name"];
	self.key_ = [data objectForKey:@"key"];
	self.type_ = [data objectForKey:@"type"];
	self.command_ = @"";
	self.extra_ = @"";
	self.extra2_ = @"";
	self.extra3_ = @"";
	self.extra4_ = @"";
	self.extra5_ = @"";
	
	return self;
}

-(void)release {
	[name_ release];
	[key_ release];
	[type_ release];
	[command_ release];
	[extra_ release];
	[extra2_ release];
	[extra3_ release];
	[extra4_ release];
	[extra5_ release];
}

@end
