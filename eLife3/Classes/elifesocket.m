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

#include <sys/socket.h>

@implementation elifesocket
@synthesize iStream;
@synthesize oStream;
@synthesize error_status;

- (void)connectToELife {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  
	NSString *elifehost = [userDefaults stringForKey:@"elifesvr"];  
	int elifeport = [userDefaults integerForKey:@"elifesvrport"];
	
	// Reset error status variable
	self.error_status = 0;
	
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
			return;
		}
		
		iStream = [(NSInputStream *) readStream retain];
		oStream = [(NSOutputStream *) writeStream retain];
		
		// Ensure the CF & BSD socket is closed when the streams are closed.
		int optval;
		CFReadStreamSetProperty((CFReadStreamRef)iStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
		CFWriteStreamSetProperty((CFWriteStreamRef)oStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
		setsockopt((int)CFWriteStreamCopyProperty((CFWriteStreamRef)oStream, kCFStreamPropertySocketNativeHandle), SOL_SOCKET, SO_KEEPALIVE, &optval, sizeof(optval));
		
		[iStream setDelegate:self];
		[oStream setDelegate:self];
		[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[iStream open];
		[oStream open];
	}
}

/**
 Writes the data to the open server connection.
 */
- (void)sendmessage:(NSString *)theMessage {

	NSString *stringToSend;
	NSData *dataToSend;
	void *marker;
	
	if (self.error_status > 0) {
		return;
	}
	
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
		xmlParser *myparser = [[[xmlParser alloc] initParser] parseXMLData:theMessage];
		[myparser release];
	}
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{	
	NSString *io;
	if (theStream == iStream) io = @">>";
	else io = @"<<";
	
	NSString *event;
	switch (streamEvent)
	{
		case NSStreamEventNone:
			event = @"NSStreamEventNone";
			NSLog(@"Cannot connect to host");
			self.error_status++;
			self.alertOtherAction;
			break;
		case NSStreamEventOpenCompleted:
			event = @"NSStreamEventOpenCompleted";
			self.error_status=0;
//			NSLog(@"Socket is open");
			break;
		case NSStreamEventHasBytesAvailable:
			event = @"NSStreamEventHasBytesAvailable";
			if (theStream == iStream)
			{
				//read data
				uint8_t buffer[4096];
				int len;
				//while ([iStream hasBytesAvailable])
				//{
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
				//}

			}
			break;
		case NSStreamEventHasSpaceAvailable:
/*			event = @"NSStreamEventHasSpaceAvailable";
			NSLog(@"Space in the stream available");
			if (theStream == oStream)
			{
				[self sendMessage];
			}
*/			break;
		case NSStreamEventErrorOccurred:
			event = @"NSStreamEventErrorOccurred";
			NSLog(@"Cannot connect to host #2");
			self.error_status++;
			self.alertOtherAction;
			break;
		case NSStreamEventEndEncountered:
			event = @"NSStreamEventEndEncountered";
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [theStream release];
            theStream = nil;
			
			break;
		default:
			event = @"** Unknown";
	}
}

- (void)alertOtherAction
{
	if (self.error_status == 1) {
		// open an alert with two custom buttons
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"eLife Connection Error" message:@"The connection to the eLife server has been lost."
													   delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:@"Reconnect", nil];
		[alert show];
		[alert release];
	}
}

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
		[self connectToELife];
	}
}

@end
