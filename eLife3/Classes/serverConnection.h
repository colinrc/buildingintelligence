//
//  serverConnection.h
//  eLife3
//
//  Created by Richard Lemon on 23/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Command.h"
#import "elifesocket.h"
#import "elifehttp.h"

@interface serverConnection : NSObject {
	Boolean localWIFI;
	elifesocket *socket_;
	elifehttp *http_;
}

@property (nonatomic) Boolean localWIFI;

-(id)init;
-(Boolean)connect;
-(void)disconnect;
-(void)sendCommand:(Command *)command;

@end
