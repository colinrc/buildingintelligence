//
//  socket.m
//  eLife3
//
//  Created by Cameron Humphries on 16/01/10.
//  Copyright 2010 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifesocket.h"
#import <CFNetwork/CFSocketStream.h>
#import "xmlParser.h"
#import "eLife3AppDelegate.h"
#import "macroList.h"
#import "Command.h"

#include <sys/socket.h>

@implementation elifesocket
@synthesize iStream;
@synthesize oStream;
@synthesize state_;
@synthesize lastCommTime;
@synthesize timer_;

/**
 default initializer sets up a listen to the network status
 */
-(id)init {
	if ( self = [super init])
	{
	}
	return self;
}
// Alert the user about our network state
- (void)alertOtherAction
{
	if (self.state_ == unconnected_) {
		// open an alert with two custom buttons
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"eLife Connection Error" message:@"The connection to the eLife server has been lost."
													   delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:@"Reconnect", nil];
		[alert show];
		[alert release];
	}
}
// Alert the user about our network state
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
	//	NSLog(@"Button clicked:%d",buttonIndex);
	if (buttonIndex == 0) {
		// cancel button clicked
		exit(0);
	} else {
		// Reconnect button clicked
		[self tryConnect];
	}
}
// close any open streams
-(void)closeStream:(NSStream *)theStream {
	if (theStream == nil)
		return;
	[theStream close]; // implicitly removes from runloop
	[theStream release];
	theStream = nil;
}
// shutdown the class
-(void)disconnect {
	[self closeStream:iStream];
	[self closeStream:oStream];
	[self.timer_ invalidate];
}
/**
 Connect to the server using the sockets connection.
 This is the option when we are local to our network
 or can route to it over a VPN? 
 */
- (Boolean)localConnect {
	[self closeStream:iStream];
	[self closeStream:oStream];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  
	NSString *elifehost = [userDefaults stringForKey:@"elifesvr"];  
	int elifeport = [userDefaults integerForKey:@"elifesvrport"];
	self.lastCommTime = [NSDate date];

	if (![elifehost isEqualToString:@""] && elifehost != NULL) {
		CFHostRef           host;
		CFReadStreamRef     readStream;
		CFWriteStreamRef    writeStream;
		
		host = CFHostCreateWithName(NULL, (CFStringRef) elifehost);
		if (host != NULL) {
			(void) CFStreamCreatePairWithSocketToCFHost(NULL, host, elifeport, &readStream, &writeStream);
			CFRelease(host);
		}
		else {
			return NO;
		}
		
		iStream = [(NSInputStream *) readStream retain];
		oStream = [(NSOutputStream *) writeStream retain];
		
		// Ensure the CF & BSD socket is closed when the streams are closed.
		CFReadStreamSetProperty((CFReadStreamRef)iStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
		CFWriteStreamSetProperty((CFWriteStreamRef)oStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
		//int optval;
		//setsockopt((int)CFWriteStreamCopyProperty((CFWriteStreamRef)oStream, kCFStreamPropertySocketNativeHandle), SOL_SOCKET, SO_KEEPALIVE, &optval, sizeof(optval));
		
		[iStream setDelegate:self];
		[oStream setDelegate:self];
		[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[iStream open];
		[oStream open];
		// put a timed event on the queue to see if things are good...
		[self.timer_  invalidate];
		// Need to add a timer event to try again in 5 seconds
		self.timer_ = [NSTimer scheduledTimerWithTimeInterval:15 
													   target:self
													 selector:@selector(watchdog)
													 userInfo:nil
													  repeats:NO];
		
		return YES;
	}
	return NO;
}
// try to connect to eLife
-(Boolean)tryConnect {
	state_ = connecting_;
	return [self localConnect];
}
/**
 Tests to see the connection is still valid server sends 60 second poll <heartbeat/>
 */
-(void)watchdog {
	NSTimeInterval timeInterval = [lastCommTime timeIntervalSinceNow];
#ifdef _DEBUG
	NSLog(@"testConnection: last comms %f",timeInterval);
#endif
	if ( timeInterval < -65.0 ) {
		// no heartbeat received
		state_ = unconnected_;
#ifdef _DEBUG
		NSLog(@"testConnection: last comms %f",timeInterval);
#endif
		[self alertOtherAction];
		return;
	}
	
	self.timer_ = [NSTimer scheduledTimerWithTimeInterval:15
												   target:self
												 selector:@selector(watchdog)
												 userInfo:nil
												  repeats:NO];
}
/**
 Writes the data to the open server connection.
 */
- (void)sendmessage:(NSString *)theMessage {

	if (self.state_ == unconnected_) {
		return;
	}
	NSString *stringToSend;
	NSData *dataToSend;
	void *marker;
	
	//send data
	stringToSend = [NSString stringWithFormat:@"%@\n", theMessage];
#ifdef _DEBUG
	NSLog(@"Sending message: %@",stringToSend);
#endif
	dataToSend = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
	if (oStream) {
		int remainingToWrite = [dataToSend length];
		marker = (void *)[dataToSend bytes];
		while (0 < remainingToWrite) {
			int actuallyWritten = 0;
			actuallyWritten = [oStream write:marker maxLength:remainingToWrite];
			remainingToWrite -= actuallyWritten;
			marker += actuallyWritten;
		}
		
		// update our state with the message we sent
		xmlParser *myparser = [[xmlParser alloc] initParser];
		[myparser parseXMLData:theMessage];
		[myparser release];
		self.lastCommTime = [NSDate date];
	}
}
/**
 Writes the data to the open server connection.
 */
- (void)sendCommand:(Command *)theCommand {

	NSString *msg = @"<CONTROL KEY=\"";
	msg = [msg stringByAppendingString:theCommand.key_];
	msg = [msg stringByAppendingString:@"\" COMMAND=\""];
	msg = [msg stringByAppendingString:theCommand.command_];
	msg = [msg stringByAppendingString:@"\" EXTRA=\""];
	msg = [msg stringByAppendingString:theCommand.extra_];
	msg = [msg stringByAppendingString:@"\" EXTRA2=\""];
	msg = [msg stringByAppendingString:theCommand.extra2_];
	msg = [msg stringByAppendingString:@"\" EXTRA3=\""];
	msg = [msg stringByAppendingString:theCommand.extra3_];
	msg = [msg stringByAppendingString:@"\" EXTRA4=\""];
	msg = [msg stringByAppendingString:theCommand.extra4_];
	msg = [msg stringByAppendingString:@"\" EXTRA5=\""];
	msg = [msg stringByAppendingString:theCommand.extra5_];
	msg = [msg stringByAppendingString:@"\" />"];
	[self sendmessage:msg];
}
/**
 Callback handler for the socket stream class.
 */
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{	
	NSString *event;
	switch (streamEvent)
	{
		case NSStreamEventNone:
			NSLog(@"Waiting away for something interesting");
			break;
		case NSStreamEventOpenCompleted:
			self.state_= connected_;
//			NSLog(@"Socket is open");
			break;
		case NSStreamEventHasBytesAvailable:
			self.state_ = connected_;
			if (theStream == iStream)
			{
				//read data
				uint8_t buffer[4096];
				int len;
				len = [iStream read:buffer maxLength:sizeof(buffer)];
				if (len > 0)
				{
					xmlParser *myparser;
					uint8_t tmpbuf[4096];
					int currchar = 0;
					int i;
					// pull out each string from the buffer and XML Parse them
					while (currchar < len) {
						i=0;
						while (currchar < len && buffer[currchar]!='\0') {
							tmpbuf[i++]=buffer[currchar++];
						}
						tmpbuf[i]='\0';
						currchar++;
						//NSLog(@"i=%d, currchar=%d",i,currchar);
						if (i != 0) {
							NSString *output = [[NSString alloc] initWithBytes:tmpbuf length:i+1 encoding:NSASCIIStringEncoding];
							//NSData *theData = [[NSData alloc] initWithBytes:buffer length:len];
							//NSLog(@"Sending data to XML Parser: %d bytes", [output length]);
#ifdef _DEBUG
							NSLog(@"Bytes read: %d", len);
							NSLog(@"received xml data: %@", output);
#endif							
							myparser = [[[xmlParser alloc] initParser] parseXMLData:output];
							[myparser release];
							[output release];
						}
					}
				}
				// last comm time...
				self.lastCommTime = [NSDate date];
			}
			break;
		case NSStreamEventHasSpaceAvailable:
/*			NSLog(@"Space in the stream available");
			if (theStream == oStream)
			{
				[self sendMessage];
			}
*/			break;
		case NSStreamEventErrorOccurred:
			NSLog(@"Cannot connect to host #2");
			self.state_ = unconnected_;
			[self alertOtherAction];
			break;
		case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [theStream release];
            theStream = nil;
			// TODO: think about this edge case
			break;
		default:
			event = @"** Unknown";
			NSLog(@"event %@",event);
	}
}

@end
