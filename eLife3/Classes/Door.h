//
//  Door.h
//  eLife3
//
//  Created by Richard Lemon on 7/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Door : NSObject {
	
	NSString* name_;
	NSString* key_;
	NSString* pos_;
}

@property (nonatomic, copy) NSString* name_;

-(id)initWithDictionary:(NSDictionary *)data;

@end
