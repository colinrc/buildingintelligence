//
//  Command.m
//  eLife3
//
//  Created by Richard Lemon on 23/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "Command.h"


@implementation Command

@synthesize command_;
@synthesize key_;
@synthesize extra_;
@synthesize extra2_;
@synthesize extra3_;
@synthesize extra4_;
@synthesize extra5_;

-(id)init {

	if (self = [super init]) {
		key_ = @"";
		command_ = @"";
		extra_ = @"";
		extra2_ = @"";
		extra3_ = @"";
		extra4_ = @"";
		extra5_ = @"";
	}
	
	return self;		
}

@end
