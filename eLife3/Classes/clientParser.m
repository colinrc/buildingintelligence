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
#import "Room.h"
#import "Zone.h"
#import "zoneList.h"
#import "logList.h"
#import "LogRecord.h"

@implementation clientParser

@synthesize timer_;
@synthesize parserSuccess;

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

NSString * current_zone_name;
NSString * current_room_name;
NSString * current_tab_name;

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
		if ((data != nil ) && (status_code < 400)) // http ok from jetty
			parser = [[NSXMLParser alloc] initWithData:data];

		[configurl release];
	}
	
	// if we can't get the file from the server let's try to get a locally cached version
	if (parser == nil) {
		NSLog(@"Trying local cached client config");
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
			NSLog(@"Trying local cached client config 2");
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
	// create a new zone object if require
	current_zone_name = [attributeDict objectForKey:@"name"];
	Zone *zone = [[Zone alloc] initWithDictionary:attributeDict];
	if ([[zoneList sharedInstance] addZone:zone] == NO) {
		NSLog(@"Zone item, problem adding %@", current_zone_name);		
	}
	[zone release];
}	
/**
 \brief	Adds a panel to a zone
 */
void addZonePanels(NSDictionary *attributeDict) {
	//	NSLog(@"addZonePanel %@",[attributeDict objectForKey:@"name"]);
}
/**
 \brief	Adds an arbitrary to a zone
 */
void addZoneArbitrary(NSDictionary *attributeDict) {
	//	NSLog(@"addZoneArbitrary %@",[attributeDict objectForKey:@"name"]);
}
/**
 \brief	Adds a room to a zone
 */
void addZoneRoom(NSDictionary *attributeDict) {
	//	NSLog(@"addZoneRoom %@",[attributeDict objectForKey:@"name"]);
	
	current_room_name = [attributeDict objectForKey:@"name"];

	Room *room = [[Room alloc] initWithDictionary: attributeDict];
	// push a room object onto the room list
	[[zoneList sharedInstance] addRoom: room];
	[room release];
}
/**
 \brief adds a room alert
 */
void addRoomAlert(NSDictionary *attributeDict) {
	Alert *alert = [[Alert alloc] initWithDictionary:attributeDict];
	
	[[zoneList sharedInstance] addAlert:alert];

	[alert release];
}

/**
 \brief adds a room door notifier
 */
void addRoomDoor(NSDictionary *attributeDict) {
	Door *door = [[Door alloc] initWithDictionary:attributeDict];
	
	[[zoneList sharedInstance] addDoor:door];
	
	[door release];
}

/**
 \brief	Handles the room window tab entries
 */
void handleRoomWindowTab(NSDictionary * attributeDict)
{
//	NSLog(@"handleRoomWindowTab %@", [attributeDict objectForKey:@"name"]);
	current_tab_name = [attributeDict objectForKey:@"name"];
	[[zoneList sharedInstance] addTab:current_tab_name];
}
/**
 \brief	Adds a room entry from a control element
 */
void addRoomControl(NSDictionary *attributeDict) {
//	NSLog(@"addRoomControl %@",[attributeDict objectForKey:@"name"]);
	// create new control object
	Control *control = [[Control alloc] initWithDictionary:attributeDict];
	if ([[controlMap sharedInstance] addControl:control] == YES)
	{
		// the control is valid lets add it to the room 
		[[zoneList sharedInstance] addControl: control];
	}
	else
	{
		NSLog(@"Room item, control problem adding %@", [attributeDict objectForKey:@"key"]);
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
		NSLog(@"Status item, control problem adding %@", [attributeDict objectForKey:@"key"]);
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
	// add a new controltype item
}
/**
 \brief	Adds a control row from a control element
 */
void addControlRow(NSDictionary *attributeDict) {
//	NSLog(@"addControlRow ");
	// add a new row object

}

/**
 \brief	Handles the logging tab entries
 */
void handleLoggingTab(NSDictionary * attributeDict)
{
	//	NSLog(@"handleRoomWindowTab %@", [attributeDict objectForKey:@"name"]);
	current_tab_name = [attributeDict objectForKey:@"name"];
	
	LogRecord* record = [[LogRecord alloc] initWithDictionary:attributeDict];
	[[logList sharedInstance] addTab:record];
	[record release];
}
/**
 Adds a control to the logging tab
 */
void addLogControl(NSDictionary* attributeDict) {

	NSString* controlKey = [attributeDict objectForKey:@"key"];
	[[logList sharedInstance] addControl:controlKey];
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
			handleZone(attributeDict);
		}
	} else if ([elementName isEqualToString:@"room"]) {
		current_state = parsing_room;
		addZoneRoom(attributeDict);
		
	} else if (([elementName isEqualToString:@"tab"]) || 
			   ([elementName isEqualToString:@"group"]))   {
		// status bar or room
		if (current_state == parsing_status) {
			// Handle status bar tab entry
			handleStatus(attributeDict);
		}
		else if (current_state == parsing_room) {
			// handle room tab entry
			handleRoomWindowTab(attributeDict);
		}
		else if (current_state == parsing_logging) {
			// handle logging tab entry
			handleLoggingTab(attributeDict);
		}
	} else if ([elementName isEqualToString:@"control"]) {

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
			addRoomControl(attributeDict);
		}
		else if (current_state == parsing_logging) {
			// handle logging control
			addLogControl(attributeDict);
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
		addArbitraryItem(attributeDict);
	} else 	if ([elementName isEqualToString:@"logging"]) {
		current_state = parsing_logging;
	} else 	if ([elementName isEqualToString:@"alert"]) {
		if (current_state == parsing_room) {
			// add a room alert
			addRoomAlert(attributeDict);
		}
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
		current_room_name = nil;
	}
	else if ([elementName isEqualToString:@"tab"]) {
		current_tab_name = nil;
	}
	else if ([elementName isEqualToString:@"arbitrary"]) {
		current_state = parsing_none;
	}
	else if ([elementName isEqualToString:@"zone"]) {
		// reset zone state
		current_zone_name = nil;
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
