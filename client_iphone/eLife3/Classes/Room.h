//
//  Room.h
//  eLife3
//
//  Created by Richard Lemon on 3/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Control.h"
#import "Alert.h"
#import "Door.h"

@interface Room : NSObject {
	NSMutableDictionary* tabs_;
	NSMutableArray* tabNames_;
	NSMutableArray* alerts_;
	NSMutableArray* doors_;
	
	NSString* name_;
	Boolean canOpen_;
	NSString* switchZone_;
	NSString* poly_;
}

@property (nonatomic, copy) NSString* name_;

-(id)initWithDictionary:(NSDictionary *)data;

-(Boolean)addTab: (NSString*)tabName;
-(Boolean)addAlert:(Alert *)alert;
-(Boolean)addDoor:(Door*)door;
  
-(Boolean)addControl: (Control*)control;

-(NSUInteger)tabCount;
-(NSString*)tabNameForIndex:(NSUInteger)index;
-(NSMutableArray*)tabForIndex:(NSUInteger)index;
-(NSUInteger)itemCountForTabIndex:(NSUInteger)index;
-(Control*)itemForIndex:(NSUInteger)tabIndex:(NSUInteger)itemIndex;

@end
