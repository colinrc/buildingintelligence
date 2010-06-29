//
//  serverConnection.m
//  eLife3
//
//  Created by Richard Lemon on 23/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//
// TODO: Need to look at the Reachable code and whether it is 
// possible to test both routes and use the following fallback
// 1// WIFI and local address:port
// 2// WIFI and remote address
// 3// 3G and remote address
// 4// FAIL no route to home
// Then we want to automatically promote back up the chain as
// "cheaper" and faster options become available.

#import "serverConnection.h"
#import "Command.h"

@implementation serverConnection

@synthesize status_;
@synthesize serverUp_;

/**
 Setup the class
 */
-(id)init{

	if (self = [super init]) {

		status_ = ReachableDirect; // FIXME: only true right now...
		socket_ = [[elifesocket alloc] init];
		http_ = [[elifehttp alloc] init];
		reconnect_timer_ = nil;
		serverUp_ = YES;
		[self setReachability];
		// listen for network failure messages
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkFault:)
													 name:@"network_down" object:nil];
		// listen for network data messages
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkData:)
													 name:@"network_data" object:nil];
		// listen for app settings changes
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:)
													 name:@"elife_settings_end" object:nil];
		// listen for connectivity changes
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(networkChanged:)
														name: kReachabilityChangedNotification object: nil];
	}
	
	return self;
}
/**
 setup the Reachability callbacks
 */
-(void)setReachability {
	// if we have some addresses
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (([[defaults objectForKey:@"elifesvr"] length] > 0) &&
		([[defaults objectForKey:@"elifesvrport"] length] > 0)) {
		[local_ release];
		//Change the host name here to change the server your monitoring
		local_ = [[Reachability reachabilityWithHostName:[defaults objectForKey:@"elifesvr"]] retain];
		[local_ startNotifier];
		
	}
	if ([[defaults objectForKey:@"remote_server_url"] length] <= 0) {
		[remote_ release];
		//Change the host name here to change the server your monitoring
		remote_ = [[Reachability reachabilityWithHostName: [defaults objectForKey:@"remote_server_url"]] retain];
		[remote_ startNotifier];
	}
}
/**
 Connects the most likely connection
 */
-(Boolean)connect {
	
	if (status_ == ReachableDirect)
	{
		// means we have WIFI and that the address and port are reachable
		// in the local address space
		return [socket_ tryConnect];
	} else if (status_ == NotReachable)
	{
		// means there is no network available
		// WIFI or 3G
		return NO;
	}
	else
	{
		// means we have either 3G or WIFI
		// but we cannot route directly
		return [http_ tryConnect];
	}
}
/**
 Disconnects all connections
 */
-(void)disconnect {
	// just disconnect both
	[socket_ disconnect];
	[http_ disconnect];
}
/**
 Sends the command on the connected protocol
 */
-(void)sendCommand:(Command *)command {
	// TODO: decide whether to cache on not reachable
	if (status_ == ReachableDirect)
	{
		// elifesocket send
		[socket_ sendCommand:command];
	}
	else
	{
		// https send
		[http_ sendCommand:command];
	}
}
/**
 Notified when the reachability class has some news
 */
-(void)networkChanged:(NSNotification *)notif {
	NSLog(@"networkChanged: ");
	
	Reachability* curReach = [notif object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	
	NetworkStatus old_status = status_;
	if (curReach == local_) {
		NSLog(@"networkChanged: local_");
		// if we are now reachable by WIFI
		if ([local_ currentReachabilityStatus] == ReachableDirect) 
		{
			NSLog(@"networkChanged: local_ ReachableDirect");
			// if we weren't reachable by WIFI before
			if (old_status == NotReachable)
			{
				status_ = ReachableDirect;
				NSLog(@"networkChanged: status change direct");
				[[NSNotificationCenter defaultCenter] postNotificationName:@"networkChange:" object: self];
				[self connect];
			}
		}
		else if (old_status == ReachableDirect)
		{
			// we are no longer reachable via local wifi
			if ([remote_ currentReachabilityStatus] == NotReachable)
			{
				// we have a problem, nowhere to fallback to...
				status_ = NotReachable;
				[[NSNotificationCenter defaultCenter] postNotificationName:@"networkChange:" object: self];
				NSLog(@"networkChanged: Not Reachable");
			}
			else
			{
				status_ = ReachableViaRouting;
				[[NSNotificationCenter defaultCenter] postNotificationName:@"networkChange:" object: self];
				NSLog(@"networkChanged: Reachable HTTP");
			}
		}
	}
	else if ((curReach == remote_) && (old_status != ReachableDirect))
	{
		NSLog(@"networkChanged: remote_");
		if ([remote_ currentReachabilityStatus] == NotReachable)
		{
			// we have a problem, nowhere to fallback to...
			status_ = NotReachable;
			NSLog(@"networkChanged: Not Reachable");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"networkChange:" object: self];
		}
		else
		{
			status_ = ReachableViaRouting;
			NSLog(@"networkChanged: Reachable HTTP");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"networkChange:" object: self];
		}
	} 
}
/**
 Notified when the settings class has changed
 */
-(void)settingsChanged:(NSNotification *)notif {
	[reconnect_timer_ invalidate];
	reconnect_timer_ = nil;
	serverUp_ = YES;
	
	[self setReachability];
	[self disconnect];
	[self connect];
}
/**
 Notified when the comms class has lost connection
 */
-(void)networkFault:(NSNotification *)notif {
	NSLog(@"networkFault from %@", [[notif object] description] );
	// try connect?
	if (serverUp_) 
	{
		[self disconnect];
		serverUp_ = NO;
		// open an alert with two custom buttons
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"eLife Connection Error" message:@"The connection to the eLife server has been lost."
													   delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:@"Reconnect", nil];
		[alert show];
		[alert release];
	}
	else {
		NSLog(@"set the reconnect timer");
		[self disconnect];
		reconnect_timer_ = [NSTimer scheduledTimerWithTimeInterval:5
															target:self
														  selector:@selector(connect)
														  userInfo:nil
														   repeats:NO];
		
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"networkChange:" object: self];

}
/**
 Notified when the comms class has data
 */
-(void)networkData:(NSNotification *)notif {
	NSLog(@"network data notification");
	serverUp_ = YES;
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"networkChange:" object: self];
}
/**
 Handle the alert button
 */
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	//	NSLog(@"Button clicked:%d",buttonIndex);
	if (buttonIndex == 0) {
		exit(0);// cancel button clicked
	} else {
		// Reconnect button clicked
		[self connect];
	}
}
/**
 Clean up our mess
 */
-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[local_ release];
	[remote_ release];
	[super dealloc];
}

@end
