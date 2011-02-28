//
//  socket.h
//  eLife3
//
//  Created by Cameron Humphries on 16/01/10.
//  Copyright 2010 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Command.h"

@interface elifesocket : NSObject <NSStreamDelegate> {
	NSInputStream *iStream;
	NSOutputStream *oStream;
	NSInteger state_;
	NSDate *lastCommTime;
	NSTimer *timer_;

	CFHostRef           host_;
	CFReadStreamRef     readStream_;
	CFWriteStreamRef    writeStream_;
}

@property (nonatomic, retain) NSDate *lastCommTime;
@property (nonatomic) NSInteger state_;

-(id)init;
-(Boolean)tryConnect;
-(void)disconnect;
-(void)sendCommand:(Command *)theCommand;

@end
