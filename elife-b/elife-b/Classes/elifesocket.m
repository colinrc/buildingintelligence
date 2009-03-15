//
//  elifesocket.m
//  elife
//
//  Created by Cameron Humphries on 13/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifesocket.h"
#import "elifeXMLParser.h"
#import "elife_bAppDelegate.h"


@implementation elifesocket
@synthesize iStream;
@synthesize oStream;
@synthesize error_status;

- (void)connecttoelife {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  
	NSString *elifehost = [userDefaults stringForKey:@"local_server_ip"];  
	int elifeport = [userDefaults integerForKey:@"local_server_port"];
	
	// Reset error status variable
	self.error_status = 0;
	
	if (![elifehost isEqualToString:@""]) {
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
			
		[iStream setDelegate:self];
		[oStream setDelegate:self];
		[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[iStream open];
		[oStream open];
	}
}

- (void)sendmessage {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *sendmsgs = elifeappdelegate.msgs_for_svr;
	NSString *stringToSend;
	NSData *dataToSend;
	void *marker;
		
	if (self.error_status > 0) {
		return;
	}
	
	while ([sendmsgs count] > 0) {
		//send data
		stringToSend = [NSString stringWithFormat:@"%@\n", [sendmsgs objectAtIndex:0]];
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
			[sendmsgs removeObject:[sendmsgs objectAtIndex:0]];
		}
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
			NSLog(@"Socket is open");
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
					NSLog(@"Bytes read: %d", len);
					if (len > 0)
					{
						elifeXMLParser *myparser;
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
							NSLog(@"i=%d, currchar=%d",i,currchar);
							if (i != 0) {
								NSString *output = [[NSString alloc] initWithBytes:tmpbuf length:i+1 encoding:NSASCIIStringEncoding];
								/*NSData *theData = [[NSData alloc] initWithBytes:buffer length:len];*/
								NSLog(@"Sending data to XML Parser: %d bytes", [output length]);
								NSLog(@"XMLDATA: %@", output);
						
								myparser = [[elifeXMLParser alloc] parseXMLData:output];
								[myparser release];
								[output release];
							}
						}
					}
				//}


			}
			break;
		case NSStreamEventHasSpaceAvailable:
			event = @"NSStreamEventHasSpaceAvailable";
			NSLog(@"Space in the stream available");
			if (theStream == oStream)
			{
				[self sendmessage];
			}
			break;
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
	NSLog(@"Button clicked:%d",buttonIndex);
	if (buttonIndex == 0) {
		// cancel button clicked
		exit(0);
	} else {
		// Reconnect button clicked
		[self connecttoelife];
	}
}


@end
