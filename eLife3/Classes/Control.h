//
//  Control.h
//  eLife3
//
//  Created by Richard Lemon on 15/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>

// control needs a state variable map
// state can be {state, on, src}
// not sure if there are other state
// variable names, seems as though it is
// free form key / value pair of strings

@interface Control : NSObject {
	NSString *name_;
	NSString *key_;
	NSString *type_;
	NSString *command_;
	NSString *extra_;
	NSString *extra2_;
	NSString *extra3_;
	NSString *extra4_;
	NSString *extra5_;
	NSString *room_;
	NSUInteger tally_;
	NSMutableDictionary *state_info_;
}

@property (nonatomic, copy) NSString *name_;
@property (nonatomic, copy) NSString *key_;
@property (nonatomic, copy) NSString *type_;
@property (nonatomic, copy) NSString *command_;
@property (nonatomic, copy) NSString *extra_;
@property (nonatomic, copy) NSString *extra2_;
@property (nonatomic, copy) NSString *extra3_;
@property (nonatomic, copy) NSString *extra4_;
@property (nonatomic, copy) NSString *extra5_;
@property (nonatomic, copy) NSString *room_;
@property (nonatomic) NSUInteger tally_;

-(id)initWithDictionary:(NSDictionary *)data;

@end
