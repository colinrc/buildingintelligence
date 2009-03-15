//
//  elifeXMLParser.m
//  elife
//
//  Created by Cameron Humphries on 21/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "elifeXMLParser.h"
#import "elife_bAppDelegate.h"
#import "elifezone.h"
#import "eliferoom.h"
#import "eliferoomtab.h"
#import "eliferoomcontrol.h"
#import "elifecontroltypes.h"
#import "elifecontrolrow.h"
#import "elifecontroltypeitem.h"
#import "elifemacro.h"
#import "MacrosViewController.h"
#import "elifestatustab.h"
#import "elifestatusitem.h"

@implementation elifeXMLParser

// State variables for XML parsing
elifezone *currentzone;
eliferoom *currentroom;
eliferoomtab *currentroomtab;
eliferoomcontrol *currentroomctrl;
elifecontroltypes *currentctrltype;
elifestatustab *currentstatustab;
elifestatusitem *currentstatusitem;
BOOL parsing_calendar;
BOOL parsing_ctrltypes;
BOOL parsing_macros;
BOOL parsing_status;
BOOL superuseronly;
NSInteger ctrlrowidx;

- (NSArray *)items
{
	return items;
}

- (id)initParser {
	[items release];
	items = [[NSMutableArray alloc] init];
	[currentstate release];
	currentstate = [[NSMutableArray alloc] init];
	
	//you must then convert the path to a proper NSURL or it won't work
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  
	NSString *elifehost = [userDefaults stringForKey:@"local_server_ip"]; 
	NSString *defconfig = [userDefaults stringForKey:@"config_file"];
	NSURL *configurl = [[NSURL alloc] initWithString:[[@"http://" stringByAppendingString:elifehost] stringByAppendingString:[@"/html/iphone/" stringByAppendingString:defconfig]]];
	NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:defconfig];
	
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:configurl];
	if (parser = nil) {
		parser = [[NSXMLParser alloc] initWithData:[[NSData alloc] initWithContentsOfFile:path]];
	}
	
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:YES];
	
	if ([parser parse] == NO) {
		[parser release];
		parser = [[NSXMLParser alloc] initWithData:[[NSData alloc] initWithContentsOfFile:path]];
		[parser setDelegate:self];
		[parser setShouldProcessNamespaces:YES];
		
		
		[parser parse];
	}
		
	[parser release];
	
	return self;
}

- (id)parseXMLData:(NSString *)xmldata {
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

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	NSDictionary *currentelement = [[NSDictionary alloc] init];
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([elementName isEqualToString:@"zone"] && parsing_calendar==NO) {
		// check if zone is superuser only access and do not add to zonelist
		NSString *canOpen = [attributeDict objectForKey:@"canOpen"];
		if ([canOpen isEqualToString:@"superuser"]) {
			superuseronly=YES;
		} else {
			superuseronly=NO;
			// store zone name in currentstate array for future reference
			currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"elementtype",[attributeDict objectForKey:@"name"],@"name",nil];
			[currentstate addObject:currentelement];
		
			// create new zone object
			elifezone *newzone = [[elifezone alloc] initWithName:[attributeDict objectForKey:@"name"] andAttributes:attributeDict];
			// add newly created zone to the appdelegate elifezonelist
			[elifeappdelegate.elifezonelist addObject:newzone];
			currentzone = [elifeappdelegate.elifezonelist  objectAtIndex:[elifeappdelegate.elifezonelist indexOfObject:newzone]];
			//[newzone release];
		}
		
	} else if ([elementName isEqualToString:@"room"]) {
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",[attributeDict objectForKey:@"name"],@"name",nil];
		[currentstate addObject:currentelement];

		if (!superuseronly) {
			// create new room object
			eliferoom *newroom = [[eliferoom alloc] initWithName:[attributeDict objectForKey:@"name"] andAttributes:attributeDict];
		
			// Add room object to current zone
			[currentzone.roomlist addObject:newroom];
		

			currentroom = [currentzone.roomlist objectAtIndex:[currentzone.roomlist indexOfObject:newroom]];
				
			[newroom release];
		}
	} else if ([elementName isEqualToString:@"tab"] && (parsing_status == NO)) {
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",[attributeDict objectForKey:@"name"],@"name",nil];
		[currentstate addObject:currentelement];
		
		if (!superuseronly) {
			// create new roomtab object
			eliferoomtab *newroomtab = [[eliferoomtab alloc] initWithName:[attributeDict objectForKey:@"name"] andAttributes:attributeDict];
		
			// add roomtab to current room
			[currentroom.tablist addObject:newroomtab];
			currentroomtab = [currentroom.tablist objectAtIndex:[currentroom.tablist indexOfObject:newroomtab]];
		
			[newroomtab release];
		}
	} else if (([elementName isEqualToString:@"tab"] || [elementName isEqualToString:@"group"]) && (parsing_status == YES)) {
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",[attributeDict objectForKey:@"name"],@"name",nil];
		[currentstate addObject:currentelement];

		// create new status group
		elifestatustab *newstatustab = [[elifestatustab alloc] initWithName:[attributeDict objectForKey:@"name"] andDict:attributeDict];
		
		// add status group to AppDelegate
		[elifeappdelegate.elifestatustabs addObject:newstatustab];
		currentstatustab = [elifeappdelegate.elifestatustabs  objectAtIndex:[elifeappdelegate.elifestatustabs indexOfObject:newstatustab]];
		[newstatustab release];
	} else if ([elementName isEqualToString:@"control"] && (parsing_status == YES)) {
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",[attributeDict objectForKey:@"name"],@"name",nil];
		[currentstate addObject:currentelement];

		// create new status item
		elifestatusitem *newstatusitem = [[elifestatusitem alloc] initWithKey:[attributeDict objectForKey:@"key"]];
		
		// add status item to current status group
		[currentstatustab.statusitems addObject:newstatusitem];
		[newstatusitem release];
	} else if ([elementName isEqualToString:@"CONTROL"] && (parsing_macros == YES)) {
		// Defining a Macro
		ElifeMacro *tmpmacro = [[ElifeMacro alloc] initWithDict:attributeDict];
		[elifeappdelegate.elifemacrolist addObject:tmpmacro];
		[tmpmacro release];

	} else if ([elementName isEqualToString:@"control"] && (parsing_ctrltypes == NO)) {
		// Defining a specific control for a room
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
		[currentstate addObject:currentelement];
		
		if (!superuseronly) {
			// create new roomcontrol object
			eliferoomcontrol *newroomctrl = [[eliferoomcontrol alloc] initWithName:[attributeDict objectForKey:@"name"] andKey:[attributeDict objectForKey:@"key"] andAttributes:attributeDict];
		
			// add control to current roomtab
			[currentroomtab.controllist addObject:newroomctrl];
		
			[newroomctrl release];	
		}
	} else if ([elementName isEqualToString:@"control"] && (parsing_ctrltypes == YES)) {
		//Defining a new control type
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
		[currentstate addObject:currentelement];
		
		// Create a new controltype object
		elifecontroltypes *newcontroltype = [[elifecontroltypes alloc] initWithType:[attributeDict objectForKey:@"type"]];
		
		// add newly created control type to the appdelegate elife control type list
		[elifeappdelegate.elifectrltypes addObject:newcontroltype];
		currentctrltype = [elifeappdelegate.elifectrltypes  objectAtIndex:[elifeappdelegate.elifectrltypes indexOfObject:newcontroltype]];
		//[newzone release];
		
		ctrlrowidx=-1;
	} else if ([elementName isEqualToString:@"CONTROL"]) {
		//runtime message from elife server
		if ([[attributeDict objectForKey:@"KEY"] isEqualToString:@"MACRO"]) {
			// macro state change being reported
			// locate macro and update status
			BOOL foundmacro=NO;
			int i;
			ElifeMacro *currmacro;
			for (i=0; (!foundmacro) && i<[elifeappdelegate.elifemacrolist count]; i++) {
				currmacro = [elifeappdelegate.elifemacrolist objectAtIndex:i];
				if ([[currmacro.macroattr objectForKey:@"EXTRA"] isEqualToString:[attributeDict objectForKey:@"EXTRA"]]) {
					foundmacro=YES;
					if ([[attributeDict objectForKey:@"COMMAND"] isEqualToString:@"started"]) {
						currmacro.running=YES;
					} else if ([[attributeDict objectForKey:@"COMMAND"] isEqualToString:@"finished"]) {
						currmacro.running=NO;
					}
				}
			}
			
			// Send notification message to any observers
			[[NSNotificationCenter defaultCenter] postNotificationName:[attributeDict objectForKey:@"EXTRA"] object:nil];

		} else {
			// control element state change
			//NSLog(@"Control %@ state change %@", [attributeDict objectForKey:@"KEY"], [attributeDict objectForKey:@"COMMAND"]);
			//Locate control item and update status
			BOOL foundctrl=NO;
			int i,j,k,l;
			elifezone *currzone;
			eliferoom *currroom;
			eliferoomtab *currtab;
			eliferoomcontrol *currctrl;
			for (i=0; (!foundctrl) && i<[elifeappdelegate.elifezonelist count]; i++) {
				currzone = [elifeappdelegate.elifezonelist objectAtIndex:i];
				for (j=0; (!foundctrl) && j<[currzone.roomlist count]; j++) {
					currroom = [currzone.roomlist objectAtIndex:j];
					for (k=0; (!foundctrl) && k<[currroom.tablist count]; k++) {
						currtab = [currroom.tablist objectAtIndex:k];
						for (l=0; (!foundctrl) && l<[currtab.controllist count]; l++) {
							currctrl = [currtab.controllist objectAtIndex:l];
							if ([currctrl.key isEqualToString:[attributeDict objectForKey:@"KEY"]]) {
								foundctrl=YES;
								currctrl.ctrlstatus = [attributeDict objectForKey:@"COMMAND"];
								currctrl.ctrlval = [[attributeDict objectForKey:@"EXTRA"] intValue];
							}
						}
					}
				}
			}
			// Send notification message to any observers
			[[NSNotificationCenter defaultCenter] postNotificationName:[attributeDict objectForKey:@"KEY"] object:nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:[[attributeDict objectForKey:@"KEY"] stringByAppendingString:@"_status"] object:nil];
		}
	} else if ([elementName isEqualToString:@"MACROS"]) {
		parsing_macros=YES;
		[elifeappdelegate.elifemacrolist release];
		elifeappdelegate.elifemacrolist = [[NSMutableArray alloc] init];
		//NSLog(@"Starting to parse macros");
	} else if ([elementName isEqualToString:@"statusBar"]) {
		parsing_status=YES;
	} else if ([elementName isEqualToString:@"calendar"]) {
		parsing_calendar=YES;
	} else if ([elementName isEqualToString:@"controlTypes"]) {
		parsing_ctrltypes=YES;
	} else if ([elementName isEqualToString:@"row"]) {
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
		[currentstate addObject:currentelement];
		
		if (!superuseronly) {
			// Create a new controltype row
			elifecontrolrow *newcontrolrow = [[elifecontrolrow alloc] init];
			newcontrolrow.rowattrs = [[NSMutableDictionary alloc] init];
			if ([attributeDict objectForKey:@"cases"] != nil) {
				[newcontrolrow.rowattrs setObject:[attributeDict objectForKey:@"cases"] forKey:@"cases"];
			}
			newcontrolrow.displayitems = [[NSMutableArray alloc] init];
			
			ctrlrowidx++;
			[currentctrltype.displayrows addObject:newcontrolrow];
		}
	} else if ([elementName isEqualToString:@"item"]) {
		// Define new control row definition
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
		[currentstate addObject:currentelement];

		if (!superuseronly) {
			// Create a new controltype item
			elifecontroltypeitem *newcontroltypeitem = [[elifecontroltypeitem alloc] initWithType:[attributeDict objectForKey:@"type"] andAttrs:attributeDict];
		
			// add newly created controltype item to current controltype
			elifecontrolrow *currentrow = [currentctrltype.displayrows objectAtIndex:ctrlrowidx];
			[currentrow.displayitems addObject:newcontroltypeitem];
		}
	} else {
		currentelement = [NSDictionary dictionaryWithObjectsAndKeys:elementName,@"element",nil];
		[currentstate addObject:currentelement];
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if ([currentstate count] > 1) {
		[currentstate removeLastObject];
	}

	if ([elementName isEqualToString:@"calendar"]) {
		parsing_calendar=NO;
	} else if ([elementName isEqualToString:@"statusBar"]) {
		parsing_status=NO;
	} else if ([elementName isEqualToString:@"controlTypes"]) {
		parsing_ctrltypes=NO;
	} else if ([elementName isEqualToString:@"MACROS"]) {
		parsing_macros=NO;
		MacrosViewController *macrosvc = [elifeappdelegate.mainVClist objectAtIndex:0];
		[(UITableView *)macrosvc.macrosTabControl.view reloadData];
		[macrosvc.macrosTabControl.view setNeedsDisplay];
	} else if ([elementName isEqualToString:@"zone"] && parsing_calendar==NO) {
		// drop zone if it has no rooms
		if ([currentzone.roomlist count] == 0) {
			[elifeappdelegate.elifezonelist removeLastObject];
		}
		// reset zone state
		superuseronly=NO;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{   
	[currentNodeContent appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    //NSLog(@"Error %i,Description: %@, Line: %i, Column: %i", [parseError code],[[parser parserError] localizedDescription], [parser lineNumber],[parser columnNumber]);
 
}


- (void)dealloc
{
	[items release];
	[currentstate release];
	[super dealloc];
}

@end