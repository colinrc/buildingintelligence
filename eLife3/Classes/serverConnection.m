//
//  serverConnection.m
//  eLife3
//
//  Created by Richard Lemon on 23/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "serverConnection.h"
#import "Command.h"

@implementation serverConnection

@synthesize localWIFI;

-(id)init {

	if (self = [super init]) {
		// TODO: watch for network status, either wifi or 3G
		//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(networkChanged:) name: kReachabilityChangedNotification object: nil];
		localWIFI = YES; // FIXME: only true right now...
		socket_ = [[elifesocket alloc] init];
		http_ = [[elifehttp alloc] init];
	}
	return self;
}
// Connects the most likely connection
-(Boolean)connect {

	if (localWIFI) {
		// elifesocket connect
		return [socket_ tryConnect];
	} else {
		// https connect
		return [http_ tryConnect];
	}
}
// Disconnects both connections
-(void)disconnect {
	// just disconnect both
	[socket_ disconnect];
}
// Sends the command on the connected protocol
-(void)sendCommand:(Command *)command {
	if (localWIFI) {
		// elifesocket send
		[socket_ sendCommand:command];
	} else {
		// https send
		[http_ sendCommand:command];
	}
}
/**
 Notified when the reachability class has some news
 */
-(void)networkChanged:(NSNotification *)notif {
	
}

@end
