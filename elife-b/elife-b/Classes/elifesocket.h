//
//  elifesocket.h
//  elife
//
//  Created by Cameron Humphries on 13/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface elifesocket : NSObject {
	NSInputStream *iStream;
	NSOutputStream *oStream;
}

@property (nonatomic, retain) NSInputStream *iStream;
@property (nonatomic, retain) NSOutputStream *oStream;

- (void)connecttoelife;
- (void)sendmessage;

@end
