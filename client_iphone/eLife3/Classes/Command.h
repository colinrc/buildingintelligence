//
//  Command.h
//  eLife3
//
//  Created by Richard Lemon on 23/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>

enum state_values {
	unconnected_,
	connecting_,
	connected_
};

@interface Command : NSObject {
	NSString *command_;
	NSString *key_;
	NSString *extra_;
	NSString *extra2_;
	NSString *extra3_;
	NSString *extra4_;
	NSString *extra5_;
}

@property (nonatomic, retain) NSString *command_;
@property (nonatomic, retain) NSString *key_;
@property (nonatomic, retain) NSString *extra_;
@property (nonatomic, retain) NSString *extra2_;
@property (nonatomic, retain) NSString *extra3_;
@property (nonatomic, retain) NSString *extra4_;
@property (nonatomic, retain) NSString *extra5_;

-(id)init;

@end
