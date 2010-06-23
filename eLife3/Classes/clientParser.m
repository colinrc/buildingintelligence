//
//  clientParser.m
//  eLife3
//
//  Created by Richard Lemon on 11/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "clientParser.h"
#import "xmlParser.h"
#import "eLife3AppDelegate.h"
#import "statusViewController.h"
#import "Control.h"
#import "controlMap.h"
#import "statusGroupMap.h"

@implementation clientParser

@synthesize timer_;
@synthesize parserSuccess;

bool superuseronly = false;

typedef enum {
	parsing_none,
	parsing_calendar,
	parsing_room,
	parsing_status,
	parsing_ctrltypes,
	parsing_arbitrary,
	parsing_logging
	
} parserState;

parserState current_state;
NSString *zone_name;
NSString *room_name;


- (id)init {
	
	self = [super init];
	[self retain]; //we are going to manage our own lifecycle and release when we have got the config...
	[self loadConfig];
	return self;
}

// TODO: refactor for edge cases
-(void)loadConfig {
	static BOOL firstAlert = TRUE;
	self.parserSuccess = NO;
	NSData *data;
	//Let's try to get the client XML from the server @ http://{server ip}/html/iphone/{config xml filename}
	NSURL *configurl = nil;
	NSString *path = nil;
    NSXMLParser *parser = nil;
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  
	NSString *elifehost = [userDefaults stringForKey:@"elifesvr"]; 
	NSString *defconfig = [userDefaults stringForKey:@"config_file"];
	if (defconfig == nil)
		defconfig = @"client.xml";
	NSString *defport = [userDefaults stringForKey:@"config_port"];
	if (defport == nil)
		defport = @"8081";
	
	path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:defconfig];

//	NSLog(@"loadConfig: trying to load the client config file %@",path);
	
	
	if (elifehost != nil )
	{
		
		NSString *str_url = [[@"http://" stringByAppendingString:elifehost]
							 stringByAppendingString:[@":" 
													  stringByAppendingString:[defport 
																			   stringByAppendingString:[@"/html/iphone/" stringByAppendingString:defconfig]]]];
		
		configurl = [[NSURL alloc] initWithString:str_url];
		
		NSURLRequest * request = [NSURLRequest requestWithURL:configurl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3];
		NSURLResponse *response;
		NSError *error;
		data = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: &error];
		int status_code = [(NSHTTPURLResponse*) response statusCode];
		if (status_code < 400) // http ok from jetty
			parser = [[NSXMLParser alloc] initWithData:data];

		[configurl release];
	}
	
	// if we can't get the file from the server let's try to get a locally cached version
	if (parser == nil) {
		data = [NSData dataWithContentsOfFile:path];
		parser = [[NSXMLParser alloc] initWithData:data];
	}
	
	if (parser != nil)
	{
		// setup the parser
		[parser setDelegate:self];
		[parser setShouldProcessNamespaces:YES];
		
		// if parse fails
		self.parserSuccess = [parser parse];
		
		if (parserSuccess == NO) {
			// try again with local file
			[parser release];
			parser = [[NSXMLParser alloc] initWithData:[[NSData alloc] initWithContentsOfFile:path]];
			[parser setDelegate:self];
			[parser setShouldProcessNamespaces:YES];
			self.parserSuccess = [parser parse];
		}
		// cleanup
		[parser release];
	}
	
	if (self.parserSuccess == YES){
		// need to get the XML into a local file...
		[data writeToFile:path atomically:NO];
		// if we warned them should we tell them all is good now?
		if (!firstAlert)
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"eLife Cofiguration Success" message:@"Finished downloading the configuration and caching a local copy."
														   delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		[self release]; // we can suicide, job done
	}
	else {
		// Need to add a timer event to try again in 5 seconds
		self.timer_ = [NSTimer scheduledTimerWithTimeInterval:5 
													   target:self
													 selector:@selector(loadConfig)
													 userInfo:nil
													  repeats:NO];
		
		// warn the user once that the config doesn't exist
		if ((elifehost != nil) && ![elifehost isEqualToString:@""] && firstAlert == YES) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"eLife Cofiguration Error" message:@"Could not download the configuration and there is no local copy."
														   delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
			firstAlert = FALSE;
		}
	}
}
/**
 \brief	Handles the status bar entries for tab and group elements
 */
void handleZone(NSDictionary *attributeDict) {
//	NSLog(@"handleZone %@",[attributeDict objectForKey:@"name"]);
	// create a new zone object if required
	zone_name = [attributeDict objectForKey:@"name"];
}	
/**
 \brief	Adds a room 
 */
void addRoom(NSDictionary *attributeDict) {
//	NSLog(@"addRoom %@",[attributeDict objectForKey:@"name"]);

	current_state = parsing_room;
	// set the room name to the name found
	room_name = [attributeDict objectForKey:@"name"];
	// push a room object onto the room list
}	
/**
 \brief	Handles the room window tab entries
 */
void handleRoomTab(NSDictionary * attributeDict)
{
//	NSLog(@"handleRoomTab %@", [attributeDict objectForKey:@"name"]);
	if (!superuseronly) {
		// create new roomtab object
		//		eliferoomtab *newroomtab = [[eliferoomtab alloc] initWithName:[attributeDict objectForKey:@"name"] andAttributes:attributeDict];
		
		// add roomtab to current room
		//		[currentroom.tablist addObject:newroomtab];
		//		currentroomtab = [currentroom.tablist objectAtIndex:[currentroom.tablist indexOfObject:newroomtab]];
		
		//		[newroomtab release];
	}
}
/**
 \brief	Adds a room entry from a control element
 */
void addRoomItem(NSDictionary *attributeDict) {
//	NSLog(@"addRoomItem %@",[attributeDict objectForKey:@"name"]);
	// create new control object
	Control *control = [[Control alloc] initWithDictionary:attributeDict];
	if ([[controlMap sharedInstance] addControl:control] == NO)
	{
		NSLog(@"Control problem adding %@", [attributeDict objectForKey:@"key"]);
	}
	[control release];
}
/**
 \brief	Handles the status bar entries for tab and group elements
 */
void handleStatus(NSDictionary *attributeDict) {
//	NSLog(@"handleStatus %@", [attributeDict objectForKey:@"name"]);
	
	// create new status group
	[[statusGroupMap sharedInstance] addGroup:attributeDict];
}
/**
 \brief	Adds a status bar entry from a control element
 */
void addStatusItem(NSDictionary *attributeDict) {
//	NSLog(@"addStatusItem %@",[attributeDict objectForKey:@"key"]);
	// create new control object
	Control *control = [[Control alloc] initWithDictionary:attributeDict];
	if ([[controlMap sharedInstance] addControl:control] == NO)
	{
		NSLog(@"Control problem adding %@", [attributeDict objectForKey:@"key"]);
	}
	[[statusGroupMap sharedInstance] addStatusItem:control];
	[control release];
}
/**
 \brief	Adds a control entry from a controltype element
 */
void addControl(NSDictionary *attributeDict) {
//	NSLog(@"addControl ");
	// Create a new controltype object
	//	elifecontroltypes *newcontroltype = [[elifecontroltypes alloc] initWithType:[attributeDict objectForKey:@"type"]];
	
	// add newly created control type to the appdelegate elife control type list
	//	[elifeappdelegate.elifectrltypes addObject:newcontroltype];
	//	currentctrltype = [elifeappdelegate.elifectrltypes  objectAtIndex:[elifeappdelegate.elifectrltypes indexOfObject:newcontroltype]];
	//[newzone release];
}
/**
 \brief	Adds a control item from a control element
 */
void addArbitraryItem(NSDictionary *attributeDict) {
//	NSLog(@"addControlItem ");
	if (!superuseronly) {
		// add a new controltype item
	}
}
/**
 \brief	Adds a control row from a control element
 */
void addControlRow(NSDictionary *attributeDict) {
//	NSLog(@"addControlRow ");
	if (!superuseronly) {
		// add a new row object
	}
}
/**
 \brief Parser start tag callback funciton.
 Handles the found tag event from the parser and then does a 
 big switch statement depending on which tag we are looking at.
 Because there are duplicate tag usages we need to keep some
 state information so we know who is our parent
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
//	NSDictionary *currentelement = [[NSDictionary alloc] init];
	//	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([elementName isEqualToString:@"zone"]) {
		// are we parsing the calendar
		if (current_state == parsing_calendar)
		{
		}
		else
		{
			NSString *canOpen = [attributeDict objectForKey:@"canOpen"];
			// check if zone is superuser only access and do not add to zonelist
			if ([canOpen isEqualToString:@"superuser"]) 
				superuseronly=YES;
			else
			{
				superuseronly=NO;
//				currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"elementtype",[attributeDict objectForKey:@"name"],@"name",nil];
				handleZone(attributeDict);
			}
		}
	} else if ([elementName isEqualToString:@"room"]) {
//		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",[attributeDict objectForKey:@"name"],@"name",nil];
		addRoom(attributeDict);
		
	} else if ([elementName isEqualToString:@"tab"]) {
		// status bar or room
//		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",[attributeDict objectForKey:@"name"],@"name",nil];
		if (current_state == parsing_status)
		{
			handleStatus(attributeDict);
		}
		else if (current_state == parsing_room) {
			// handle roomtab
			handleRoomTab(attributeDict);
		}
	} else if ([elementName isEqualToString:@"group"]) {
		if (current_state == parsing_status)
		{
//			currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",[attributeDict objectForKey:@"name"],@"name",nil];
			handleStatus(attributeDict);
		}
		else if (current_state == parsing_logging)
		{
			NSLog(@"TODO: add the logging handling code");
		}
	} else if ([elementName isEqualToString:@"control"]) {
//		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",[attributeDict objectForKey:@"name"],@"name",nil];
		if (current_state == parsing_status)
		{
			addStatusItem(attributeDict);
		}
		else if (current_state == parsing_ctrltypes){
			// handle control types
			addControl(attributeDict);
		}
		else if (current_state == parsing_room){
			// handle room controls
			addRoomItem(attributeDict);
		}
	} else if ([elementName isEqualToString:@"item"]) {
//		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
		if (current_state == parsing_arbitrary) {
			// add a zone arbitrary item
			addArbitraryItem(attributeDict);
		}
	} else if ([elementName isEqualToString:@"statusBar"]) {
		current_state = parsing_status;
	} else if ([elementName isEqualToString:@"controlTypes"]) {
		current_state = parsing_ctrltypes;
	} else 	if ([elementName isEqualToString:@"calendar"]) {
		current_state = parsing_calendar;
	} else 	if ([elementName isEqualToString:@"arbitrary"]) {
		current_state = parsing_arbitrary;
	} else 	if ([elementName isEqualToString:@"logging"]) {
		current_state = parsing_logging;
	} else {
//		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
	}
}

/**
 Parser callback, handles the close tags
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	
	if ([elementName isEqualToString:@"calendar"]) {
		current_state = parsing_none;
	}
	else if ([elementName isEqualToString:@"statusBar"]) {
		current_state = parsing_none;
	}
	else if ([elementName isEqualToString:@"controlTypes"]) {
		current_state = parsing_none;
	}
	else if ([elementName isEqualToString:@"room"]) {
		current_state = parsing_none;
		room_name = nil;
	}
	else if ([elementName isEqualToString:@"arbitrary"]) {
		current_state = parsing_none;
	}
	else if ([elementName isEqualToString:@"zone"]) {
		// reset zone state
		superuseronly=NO;
		zone_name = nil;
	}
	else if ([elementName isEqualToString:@"logging"]) {
		current_state = parsing_none;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{   
	[currentNodeContent appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
//	NSLog(@"Error %i,Description: %@, Line: %i, Column: %i", [parseError code],[[parser parserError] localizedDescription], [parser lineNumber],[parser columnNumber]);
}

- (void)dealloc
{
	[super dealloc];
}




@end
