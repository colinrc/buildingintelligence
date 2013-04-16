//
//  LogRecord.h
//  eLife3
//
//  Created by Richard Lemon on 8/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LogRecord : NSObject {
	NSString* name_;			// log group name
	NSString* icon_;			// log group icon
	NSString* events_;	// the control events to log
	NSMutableArray* format_;	// the log record format
	Boolean tally_;				// tally or log
	NSString* timeFormat_;		// the time format
	NSMutableArray* logEntries_;// the log messages
}

@property (nonatomic, copy) NSString* name_;

// adds a new log entry
-(void)addEntry: (NSNotification *)notification;
-(NSString*)getLogEntry:(NSUInteger)index;
-(NSUInteger)count;

@end
