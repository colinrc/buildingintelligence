//
//  elifesocket.h
//  elife
//
//  Created by Cameron Humphries on 13/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CFNetwork/CFSocketStream.h>

@interface elifesocket : NSObject {
	NSInputStream *iStream;
	NSOutputStream *oStream;
	NSInteger error_status;
}

@property (nonatomic, retain) NSInputStream *iStream;
@property (nonatomic, retain) NSOutputStream *oStream;
@property (nonatomic) NSInteger error_status;

- (void)connecttoelife;
- (void)sendmessage;
- (void)alertOtherAction;

@end
