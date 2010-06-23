//
//  elifehttp.m
//  eLife3
//
//  Created by Richard Lemon on 23/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "elifehttp.h"


@implementation elifehttp

@synthesize state_;
@synthesize timer_;

-(id)init {

	if (self = [super init]) {
		// do more initialization
	}
	return self;
}
// Get the data from the server
-(void)httpGetStatus {
	if (self.state_ == connecting_)
	{
		// add the ?INIT=Y to the URL 
	}
	// add /webclient/update/ to the URL
	// if we get a auth request then handle auth
	// ignore the certificate error
	// cache the session token
}
// Get the data from the server
-(void)httpSetStatus:(NSString *)theMessage {
	if (self.state_ != connected_)
	{
		return;
	}
	// add /webclient/update/ to the URL
	// add theMessage to the URL
	
	// if we get a auth request then handle auth
	// ignore the certificate error
	// add the session token
}
// connect using the remote address
- (Boolean)tryConnect {

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  
	NSString *elifehost = [userDefaults stringForKey:@"remote_server_url"];  
	int web_refresh = [userDefaults integerForKey:@"web_refresh_rate"];
	if (web_refresh < 5 ) web_refresh = 5; // set the minimum
	
	if (![elifehost isEqualToString:@""] && elifehost != NULL) {

		// stop the watchdog
		[self.timer_  invalidate];
		// set a timer to request every request interval
		self.timer_ = [NSTimer scheduledTimerWithTimeInterval:web_refresh 
													   target:self
													 selector:@selector(httpGet)
													 userInfo:nil
													  repeats:NO];
	}	
	return NO;
}
// Disconnect from the http session
-(void)disconnect {
	// want to invalidate the https session there is a logout page?
}
// do the http get with the crazy URL
- (void)sendCommand:(Command *)theCommand {
	// using URL to send command
	NSString *msg = @"?ds=";
	msg = [msg stringByAppendingString:theCommand.key_];
	msg = [msg stringByAppendingString:@"&co="];
	msg = [msg stringByAppendingString:theCommand.command_];
	msg = [msg stringByAppendingString:@"&ex="];
	msg = [msg stringByAppendingString:theCommand.extra_];
	msg = [msg stringByAppendingString:@"&ex2="];
	msg = [msg stringByAppendingString:theCommand.extra2_];
	msg = [msg stringByAppendingString:@"&ex3="];
	msg = [msg stringByAppendingString:theCommand.extra3_];
	msg = [msg stringByAppendingString:@"&ex4="];
	msg = [msg stringByAppendingString:theCommand.extra4_];
	msg = [msg stringByAppendingString:@"&ex5="];
	msg = [msg stringByAppendingString:theCommand.extra5_];
	
	[self httpSetStatus:msg];
	
}

@end
