//
//  logList.h
//  eLife3
//
//  Created by Richard Lemon on 7/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Control.h"
#import "LogRecord.h"

@interface logList : NSObject {
	NSMutableArray* tabs_;
	NSMutableDictionary* controls_;
}

+(logList*)sharedInstance;

-(NSString*)getTabNameForIndex:(NSUInteger)index;
-(NSUInteger)getEntriesForIndex:(NSUInteger)index;
-(LogRecord*)getTabForIndex:(NSUInteger)index;

-(Boolean)addTab:(LogRecord*)tab;
-(Boolean)addControl:(NSString*)controlKey;
-(int)count;

@end
