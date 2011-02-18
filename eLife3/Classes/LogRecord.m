//
//  LogRecord.m
//  eLife3
//
//  Created by Richard Lemon on 8/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "LogRecord.h"
#import "Control.h"
#import "globalConfig.h"

@implementation LogRecord

@synthesize name_;
/**
 Construct from XML fragment
 */
-(id)initWithDictionary:(NSDictionary *)data {
	
	if ([self init])
	{
		name_ = [[data objectForKey:@"name"] copy];
		icon_ = [[data objectForKey:@"icon"] copy];
		tally_ = [[data objectForKey:@"type"] isEqualToString:@"tally"];
		timeFormat_ = [[data objectForKey:@"timeformat"] copy];
		events_ = [[data objectForKey:@"listenTo"] copy];
	}
	return self;
}

/**
 Standard constructor thingie
 */
-(id)init {
	
	self = [super init];
	format_ = [[NSMutableArray alloc] init];
	logEntries_= [[NSMutableArray alloc] init];
	return self;
}

/**
 Standard destructor thingie
 */
-(void)dealloc {
	[name_ release];
	[icon_ release];
	[timeFormat_ release];
	[events_ release];		// releases all objects as well
	[format_ release];		// releases all objects as well
	[logEntries_ release];	// releases all objects as well
	[super dealloc];
} 
/**
 TODO: Need to do the custom log entry, currently we have a fixed log entry
 */
-(void)addEntry: (NSNotification *)notification {
	// get the control this event is for
	Control * control = [[globalConfig sharedInstance].controls_ findControl:[notification name]];
	if (control == nil)
		return;
	
	// is the event in events_
	NSRange range = [events_ rangeOfString:control.command_];
	if (range.location == NSNotFound)
		return;
	// make time
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"[dd/MM/yy HH:mm:ss]"];	
	NSString* date = [dateFormatter stringFromDate:[NSDate date]];
	[dateFormatter release];
	// make message
	if (tally_) {
		control.tally_ += 1;
		if (control.tally_ > 1) {
			for (NSUInteger index = 0; index < [logEntries_ count]; index++){
				NSString* found =  [logEntries_ objectAtIndex:index];
				range = [found rangeOfString:control.name_];
				if (range.location != NSNotFound) {
					found = [NSString stringWithFormat:@"%@ %@, %@, %@ [%i]",date,control.room_,control.name_,control.command_,control.tally_];
					[logEntries_ replaceObjectAtIndex:index withObject:found];
					break;
				}
			}
		}
		else {
			[logEntries_ addObject:[NSString stringWithFormat:@"%@ %@, %@, %@ [%i]",date,control.room_,control.name_,control.command_,control.tally_]];
		}

	} else {	
		[logEntries_ addObject:[NSString stringWithFormat:@"%@ %@, %@, %@",date,control.room_,control.name_,control.command_]];
	}
	if (!tally_ && [logEntries_ count] > 20) {
		[logEntries_ removeObjectAtIndex:0];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"logUpdate" object:self];
}
/**
 Get the log entry at the index empty string if out of bounds
 */
-(NSString*)getLogEntry:(NSUInteger)index {
	if (index >= [logEntries_ count])
		return @"";
	
	return [logEntries_ objectAtIndex:index];
}


/**
 Return the number of log entries in this tab
 */
-(NSUInteger)count {
	return [logEntries_ count];
}

@end
