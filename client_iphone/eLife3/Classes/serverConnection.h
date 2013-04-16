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
#import "Reachability.h"
#import "AsyncUdpSocket.h"

@interface serverConnection : NSObject {
	NetworkStatus status_;
	Boolean serverUp_;
	NSInteger discoverTries_;
	elifesocket *socket_;
	elifehttp *http_;
	NSTimer *reconnect_timer_;
	Reachability *local_;
	Reachability *remote_;
	AsyncUdpSocket *ssdpSock;
}

@property (nonatomic) Boolean serverUp_;
@property (nonatomic) NetworkStatus status_;

-(id)init;
-(Boolean)connect;
-(void)disconnect;
-(void)sendCommand:(Command *)command;
-(void)setReachability;

-(void)discover_eLife;
-(void)listen_eLife;
-(void)completeSearch: (NSString *) data;
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port;
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error;


@end
