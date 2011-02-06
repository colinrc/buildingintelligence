//
//  Room.h
//  eLife3
//
//  Created by Richard Lemon on 3/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Control.h"

@interface Room : NSObject {
	NSMutableDictionary* tabs_;
	
	NSString* name_;
	Boolean canOpen_;
	NSString* switchZone_;
	NSString* poly_;
}

@property (nonatomic, copy) NSString* name_;

-(id)initWithDictionary:(NSDictionary *)data;

-(Boolean)addControl:(NSString*)currentTab:(Control*)control;

@end
