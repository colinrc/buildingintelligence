//
//  elifeXMLParser.m
//  elife
//
//  Created by Cameron Humphries on 21/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifeXMLParser.h"
#import "elifeAppDelegate.h"
#import "elifezone.h"
#import "eliferoom.h"
#import "eliferoomtab.h"
#import "eliferoomcontrol.h"
#import "elifecontroltypes.h"
#import "elifecontroltypeitem.h"

@implementation elifeXMLParser

// State variables for XML parsing
elifezone *currentzone;
eliferoom *currentroom;
eliferoomtab *currentroomtab;
eliferoomcontrol *currentroomctrl;
elifecontroltypes *currentctrltype;
BOOL parsing_calendar;
BOOL parsing_ctrltypes;
NSInteger ctrlrowidx;

- (NSArray *)items
{
	return items;
}

- (id)parseXMLAtURL:(NSURL *)url toObject:(NSString *)aClassName parseError:(NSError **)error {
	[items release];
	items = [[NSMutableArray alloc] init];
	[currentstate release];
	currentstate = [[NSMutableArray alloc] init];
	
	className = aClassName;
	//you must then convert the path to a proper NSURL or it won't work
    //NSURL *xmlURL = [NSURL fileURLWithPath:URL];
	NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sample.xml"];
	
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    //NSXMLParser *parser = [[ NSClassFromString(@"NSXMLParser") alloc] initWithContentsOfURL:xmlURL];
    NSXMLParser *parser = [[ NSClassFromString(@"NSXMLParser") alloc] initWithData:[[NSData alloc] initWithContentsOfFile:path]];
	
	//NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:YES];
	
	[parser parse];
	
	if([parser parserError] && error) {
		*error = [parser parserError];
	}
	
	[parser release];
	
	return self;
}

- (id)parseXMLData:(NSString *)xmldata {
	NSLog(@"parsing %d bytes", [xmldata length]);
	NSLog(@"XMLDATA: %@", xmldata);
	NSXMLParser *myparser = [[NSXMLParser alloc] initWithData:[xmldata dataUsingEncoding:NSASCIIStringEncoding]];
	
	if (myparser == nil) {
		NSLog(@"XML Parser could not initiate");
		exit(0);
	}
	
	[myparser setDelegate:self];
	[myparser setShouldProcessNamespaces:YES];
	
	NSLog(@"calling XML parse()");
	[myparser parse];
	NSLog(@"Finished XML parse()");
		
	[myparser release];
	
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	NSDictionary *currentelement = [[NSDictionary alloc] init];
	elifeAppDelegate *elifeappdelegate = (elifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSLog(@"Called XML Parser()");
	
	if ([elementName isEqualToString:@"zone"] && parsing_calendar==NO) {
		// store zone name in currentstate array for future reference
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"elementtype",[attributeDict objectForKey:@"name"],@"name",nil];
		[currentstate addObject:currentelement];
		NSLog(@"Open tag: %@", elementName);
		
		// create new zone object
		elifezone *newzone = [[elifezone alloc] initWithName:[attributeDict objectForKey:@"name"] andAttributes:attributeDict];
		NSLog(@"Adding zone %@",[attributeDict objectForKey:@"name"]);
		// add newly created zone to the appdelegate elifezonelist
		[elifeappdelegate.elifezonelist addObject:newzone];
		NSLog(@"current zone count: %d", [elifeappdelegate.elifezonelist count]);
		currentzone = [elifeappdelegate.elifezonelist  objectAtIndex:[elifeappdelegate.elifezonelist indexOfObject:newzone]];
		NSLog(@"currentzone pointer %@",currentzone.name);
		//[newzone release];
		
	} else if ([elementName isEqualToString:@"room"]) {
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",[attributeDict objectForKey:@"name"],@"name",nil];
		[currentstate addObject:currentelement];
		NSLog(@"Open tag: %@", elementName);

		// create new room object
		eliferoom *newroom = [[eliferoom alloc] initWithName:[attributeDict objectForKey:@"name"] andAttributes:attributeDict];
		NSLog(@"Adding room %@",[attributeDict objectForKey:@"name"]);
		
		// Add room object to current zone
		[currentzone.roomlist addObject:newroom];
		NSLog(@"current room count: %d", [currentzone.roomlist count]);
		NSLog(@"currentzone pointer %@",currentzone.name);


		currentroom = [currentzone.roomlist objectAtIndex:[currentzone.roomlist indexOfObject:newroom]];
				
		[newroom release];
	} else if ([elementName isEqualToString:@"tab"]) {
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",[attributeDict objectForKey:@"name"],@"name",nil];
		[currentstate addObject:currentelement];
		NSLog(@"Open tag: %@", elementName);
		
		// create new roomtab object
		eliferoomtab *newroomtab = [[eliferoomtab alloc] initWithName:[attributeDict objectForKey:@"name"] andAttributes:attributeDict];
		
		// add roomtab to current room
		[currentroom.tablist addObject:newroomtab];
		currentroomtab = [currentroom.tablist objectAtIndex:[currentroom.tablist indexOfObject:newroomtab]];
		
		[newroomtab release];
	} else if ([elementName isEqualToString:@"control"] && (parsing_ctrltypes == NO)) {
		// Defining a specific control for a room
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
		[currentstate addObject:currentelement];
		NSLog(@"Open tag: %@", elementName);
		
		// create new roomcontrol object
		eliferoomcontrol *newroomctrl = [[eliferoomcontrol alloc] initWithName:[attributeDict objectForKey:@"name"] andKey:[attributeDict objectForKey:@"key"] andAttributes:attributeDict];
		
		// add control to current roomtab
		[currentroomtab.controllist addObject:newroomctrl];
		
		[newroomctrl release];		
	} else if ([elementName isEqualToString:@"control"] && (parsing_ctrltypes == YES)) {
		//Defining a new control type
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
		[currentstate addObject:currentelement];
		NSLog(@"Open tag: %@", elementName);
		
		// Create a new controltype object
		elifecontroltypes *newcontroltype = [[elifecontroltypes alloc] initWithType:[attributeDict objectForKey:@"type"]];
		
		// add newly created control type to the appdelegate elifezonelist
		[elifeappdelegate.elifectrltypes addObject:newcontroltype];
		currentctrltype = [elifeappdelegate.elifectrltypes  objectAtIndex:[elifeappdelegate.elifectrltypes indexOfObject:newcontroltype]];
		NSLog(@"currentcontroltype pointer %@",currentctrltype.controltype);
		//[newzone release];
		
		ctrlrowidx=-1;
	} else if ([elementName isEqualToString:@"calendar"]) {
		parsing_calendar=YES;
	} else if ([elementName isEqualToString:@"controlTypes"]) {
		parsing_ctrltypes=YES;
	} else if ([elementName isEqualToString:@"row"]) {
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
		[currentstate addObject:currentelement];
		NSLog(@"Open tag: %@", elementName);
		
		ctrlrowidx++;
		[currentctrltype.displayrows addObject:[[NSMutableArray alloc] init]];
	} else if ([elementName isEqualToString:@"item"]) {
		// Define new control row definition
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
		[currentstate addObject:currentelement];
		NSLog(@"Open tag: %@", elementName);

		// Create a new controltype item
		elifecontroltypeitem *newcontroltypeitem = [[elifecontroltypeitem alloc] initWithType:[attributeDict objectForKey:@"type"] andAttrs:attributeDict];
		
		// add newly created controltype item to current controltype
		NSMutableArray *currentrow = [currentctrltype.displayrows objectAtIndex:ctrlrowidx];
		[currentrow addObject:newcontroltypeitem];
		
		
	} else {
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
		[currentstate addObject:currentelement];
		NSLog(@"Open tag: %@", elementName);
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	NSLog(@"Close tag: %@", elementName);
	if ([currentstate count] > 1) {
		[currentstate removeLastObject];
	}

	if ([elementName isEqualToString:@"calendar"]) {
		parsing_calendar=NO;
	} else if ([elementName isEqualToString:@"controlTypes"]) {
		parsing_ctrltypes=NO;
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{   
	//NSLog(@"Found string: %@", string);
	[currentNodeContent appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Error %i,Description: %@, Line: %i, Column: %i", [parseError code],[[parser parserError] localizedDescription], [parser lineNumber],[parser columnNumber]);
 
}


- (void)dealloc
{
	[items release];
	[currentstate release];
	[super dealloc];
}

@end