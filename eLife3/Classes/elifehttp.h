//
//  elifehttp.h
//  eLife3
//
//  Created by Richard Lemon on 23/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Command.h"

@interface elifehttp : NSObject {
	NSInteger state_;
	NSTimer *timer_;
}

@property (nonatomic) NSInteger state_;
@property (nonatomic, retain) NSTimer *timer_;

-(id)init;
-(Boolean)tryConnect;
-(void)disconnect;
-(void)sendCommand:(Command *)theCommand;

@end
