//
//  elifesocket.m
//  elife
//
//  Created by Cameron Humphries on 13/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifesocket.h"
#import "elifeXMLParser.h"


@implementation elifesocket
@synthesize iStream;
@synthesize oStream;

- (void)connecttoelife {
	
	NSHost *host = [NSHost hostWithAddress:@"192.168.1.2"];
	if (host != nil)
	{		
		// iStream and oStream are instance variables
		[NSStream getStreamsToHost:host port:10000 inputStream:&iStream outputStream:&oStream];
	
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

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
	UILabel *resultText;
	NSString *io;
	if (theStream == iStream) io = @">>";
	else io = @"<<";
	
	NSString *event;
	switch (streamEvent)
	{
		case NSStreamEventNone:
			event = @"NSStreamEventNone";
			/*resultText.font = [UIFont fontWithName:@"Helvetica" size:10.0];
			resultText.textColor = [UIColor whiteColor];
			resultText.text = [[NSString alloc] initWithFormat: @"Can not connect to the host!"];*/
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
				while ([iStream hasBytesAvailable])
				{
					len = [iStream read:buffer maxLength:sizeof(buffer)];
					/*NSLog(@"Bytes read: %d", len);*/
					if (len > 0)
					{
						elifeXMLParser *myparser;
						uint8_t tmpbuf[4096];
						int currchar = 0;
						int i;
						// pull out each string from the buffer and XML Parse them
						while (currchar < len) {
							i=0;
							while (buffer[currchar]!='\0') {
								tmpbuf[i++]=buffer[currchar++];
							}
							tmpbuf[i]='\0';
							currchar++;
							NSString *output = [[NSString alloc] initWithBytes:tmpbuf length:i+1 encoding:NSASCIIStringEncoding];
							/*NSData *theData = [[NSData alloc] initWithBytes:buffer length:len];*/
							NSLog(@"Sending data to XML Parser: %d bytes", [output length]);
							NSLog(@"XMLDATA: %@", output);
						
							myparser = [[elifeXMLParser alloc] parseXMLData:output];
							[myparser release];
						}
					}
				}


			}
			break;
		case NSStreamEventHasSpaceAvailable:
			event = @"NSStreamEventHasSpaceAvailable";
			if (theStream == oStream)
			{
				//send data
				uint8_t buffer[11] = "I send this";				
				int len;
				
				len = [oStream write:buffer maxLength:sizeof(buffer)];
				if (len > 0)
				{
					NSLog(@"Command send");
					[oStream close];
				}
			}
			break;
		case NSStreamEventErrorOccurred:
			event = @"NSStreamEventErrorOccurred";
			/*resultText.font = [UIFont fontWithName:@"Helvetica" size:10.0];
			resultText.textColor = [UIColor whiteColor];
			resultText.text = [[NSString alloc] initWithFormat: @"Can not connect to the host!"];*/
			NSLog(@"Connot connect to host #2");
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
