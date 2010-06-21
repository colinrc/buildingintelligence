//
//  socket.h
//  eLife3
//
//  Created by Cameron Humphries on 16/01/10.
//  Copyright 2010 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface elifesocket : NSObject {
	NSInputStream *iStream;
	NSOutputStream *oStream;
	NSInteger error_status;
	
}
@property (nonatomic, retain) NSInputStream *iStream;
@property (nonatomic, retain) NSOutputStream *oStream;
@property (nonatomic) NSInteger error_status;

- (void)connectToELife;
- (void)sendmessage:(NSString *)theMessage;
- (void)alertOtherAction;

@end
