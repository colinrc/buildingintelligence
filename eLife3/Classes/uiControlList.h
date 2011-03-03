//
//  uiControlList.h
//  eLife3
//
//  Created by Richard Lemon on 2/03/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "controlRow.h"

@interface uiControlList : NSObject {
	NSMutableDictionary* controlTypes_;
	NSString* currentName_;
	controlRow* currentRow_;
}

@property (nonatomic, copy) NSString* currentName_;
@property (nonatomic, retain) controlRow* currentRow_;

-(Boolean) addControlType: (NSDictionary*) attributeDict;
-(Boolean) addControlRow: (NSDictionary*) attributeDict;
-(Boolean) addControlItem: (NSDictionary*) attributeDict;
-(NSMutableArray*) getControlRows: (NSString*)controlTypeName;

@end
