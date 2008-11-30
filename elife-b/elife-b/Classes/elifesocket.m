//
//  elifesocket.m
//  elife
//
//  Created by Cameron Humphries on 13/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifesocket.h"
#import "elifeXMLParser.h"
#import "elifeAppDelegate.h"


@implementation elifesocket
@synthesize iStream;
@synthesize oStream;

- (void)connecttoelife {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  
	NSString *elifehost = [userDefaults stringForKey:@"local_server_ip"];  
	//NSString *elifehost = @"192.168.1.2";  
	NSHost *host = [NSHost hostWithAddress:elifehost];
	int elifeport = [userDefaults integerForKey:@"local_server_port"];
	//int elifeport = 10000;
	NSLog(@"Preparing to connect");
	
	if (host != nil)
	{		
		// iStream and oStream are instance variables
		[NSStream getStreamsToHost:host port:elifeport inputStream:&iStream outputStream:&oStream];
	
		//iStream is instance var of NSSInputStream
		[iStream retain];
		[iStream setDelegate:self];
		[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[iStream open];
		
		//oStream is instance var of NSSOutputStream
		[oStream retain];
		[oStream setDelegate:self];
		[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[oStream open];		
		
		NSError *streamError;
		streamError = [iStream streamError];
		streamError = [oStream streamError];
		
		NSStreamStatus streamStatus;
		streamStatus = [iStream streamStatus];
		streamStatus = [oStream streamStatus];
	}
	
}

- (void)sendmessage {
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *sendmsgs = elifeappdelegate.msgs_for_svr;
	NSString *stringToSend;
	NSData *dataToSend;
	void *marker;
	
	NSLog(@"Messages pending: %d",[sendmsgs count]);
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
			NSLog(@"Command send: %@", stringToSend);
			[sendmsgs removeObject:[sendmsgs objectAtIndex:0]];
		}
	}
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *sendmsgs = elifeappdelegate.msgs_for_svr;
	NSLog(@"Stream event occurred, messages waiting to go: %d",[sendmsgs count]);
	
	NSString *io;
	if (theStream == iStream) io = @">>";
	else io = @"<<";
	
	NSString *event;
	switch (streamEvent)
	{
		case NSStreamEventNone:
			event = @"NSStreamEventNone";
			NSLog(@"Cannot connect to host");
			break;
		case NSStreamEventOpenCompleted:
			event = @"NSStreamEventOpenCompleted";
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
	
	NSLog(@"%@ : %@", io, event);
}


@end
