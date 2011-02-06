//
//  zoneList.h
//  eLife3
//
//  Created by Richard Lemon on 3/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Zone.h"

@interface zoneList : NSObject {
	NSMutableDictionary* zones_;
	NSMutableArray* zoneNames_;
}

+(zoneList*)sharedInstance;

-(Boolean)addZone:(Zone* )zone;
-(Zone*)getZone:(NSUInteger)index;

-(Boolean)addRoom:(Room*)room;
-(Boolean)addAlert:(Alert*)alert;
-(Boolean)addControl:(NSString*)roomName:(NSString*)tabName:(Control*)control;
-(int)count;
-(NSString*)nameFor:(NSUInteger)index;
-(NSUInteger)roomsInZone:(NSUInteger)index;

@end
