//
//  LogRecord.h
//  eLife3
//
//  Created by Richard Lemon on 8/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LogRecord : NSObject {
	NSString* name_;
	NSString* icon_;
	NSMutableArray* messages_;
	NSMutableArray* format_;
	Boolean tally_;
	NSString* timeFormat_;
}

@property (nonatomic, copy) NSString* name_;

@end
