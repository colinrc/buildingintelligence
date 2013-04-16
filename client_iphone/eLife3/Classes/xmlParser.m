//
//  xmlParser.m
//  eLife3
//	Parses the XML from the server, used to parse both the client XML and the server commands.
//	Adapted from Cameron's eLife-B code. The class is passed to the framework parser as a 
//	delegate so the following slots are callbacks for the NSXMLParser
//	parser:didStartElement - open tag
//	parser:didEndElement - close tag
//	parser:foundCharacters - data
//	parser:parseErrorOccurred - oops
//	
//  Created by Richard Lemon on 9/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "xmlParser.h"
#import "globalConfig.h"
#import "macro.h"

bool parsing_macros = false;

@implementation xmlParser

-(id)initParser {
	self = [super init];
//	[currentstate release];
//	currentstate = [[NSMutableArray alloc] init];

	return self;
}

/**
 Parses the string passed in
 */
-(id)parseXMLData:(NSString *)xmldata {
	NSXMLParser *myparser = [[NSXMLParser alloc] initWithData:[xmldata dataUsingEncoding:NSASCIIStringEncoding]];
	
	if (myparser == nil) {
		exit(0);
	}
	
	[myparser setDelegate:self];
	[myparser setShouldProcessNamespaces:YES];
	
	[myparser parse];
	
	[myparser release];
	
	return self;
}

/**
 \brief	handles control update notification
 */
void updateControl(NSDictionary *attributeDict) {
	// Update the data object
	NSString *tmpStr = [attributeDict objectForKey:@"KEY"];
	if ([tmpStr isEqualToString:@"MACRO"] || [tmpStr isEqualToString:@"SCRIPT"])
		 return;
		 
	[[globalConfig sharedInstance].controls_ updateControl:attributeDict ];
}	


/**
 \brief Parser start tag callback funciton.
 Handles the found tag event from the parser and then does a 
 big switch statement depending on which tag we are looking at.
 Because there are duplicate tag usages we need to keep some
 state information so we know who is our parent
*/
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

	if ([elementName isEqualToString:@"CONTROL"]) {
		// parsing macro stuff
		if (parsing_macros)
		{
			// defining the macros
			// add a macro to the macro list
			[[globalConfig sharedInstance].macros_ addMacro:attributeDict];
		} else if ([[attributeDict objectForKey:@"KEY"] isEqualToString:@"MACRO"]) {
			// macro state change being reported
			// locate macro and update status
			[[globalConfig sharedInstance].macros_ updateMacro:attributeDict];
		} else {
			// control element state change
			updateControl(attributeDict);
		}

	} else if ([elementName isEqualToString:@"MACROS"]) {
		// parsing connect return?
		parsing_macros = YES;
	}
}

/**
 Called by the parser for close tag elements
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

//	if ([currentstate count] > 1) {
//		[currentstate removeLastObject];
//	}
	
	if ([elementName isEqualToString:@"MACROS"]) {
		parsing_macros = NO;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{   
	[currentNodeContent appendString:string];
}
	
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
//	NSLog(@"Error %i,Description: %@, Line: %i, Column: %i", [parseError code],[[parser parserError] localizedDescription], [parser lineNumber],[parser columnNumber]);
}

/**
 Cleanup code
 */
- (void)dealloc
{
//	[currentstate release];
	[super dealloc];
}


@end
