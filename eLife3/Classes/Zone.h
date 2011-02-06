//
//  Zone.h
//  eLife3
//
//  Created by Richard Lemon on 3/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Room.h"
#import "Alert.h"

@interface Zone : NSObject {
	NSMutableDictionary* rooms_;
	NSMutableArray* roomNames_;
	NSMutableArray* alerts_;

	Boolean cycle_;
	Boolean skipForPDA_;
	NSString* background_;
	NSString* alignment_;
	Boolean canOpen_;
	Boolean hideFromList_;
	NSString* name_;
	NSString* map_;
}

@property (nonatomic, copy) NSString* name_;

-(id)initWithDictionary:(NSDictionary *)data;

-(Boolean)addRoom:(Room*)room;
-(Boolean)addAlert:(Alert*)alert;

-(Room*)getCurrentRoom: (NSString*)roomName;
-(Room*)getRoom:(NSUInteger)index;
-(int)count;

@end
