//
//  controlRow.m
//  eLife3
//
//  Created by Richard Lemon on 2/03/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "controlRow.h"


@implementation controlRow

@synthesize cases_;
@synthesize items_;

/**
 Initialize the row with the attributes
 */
-(id)initWithDictionary:(NSDictionary *)data {
	
	self = [self init];
	self.cases_ = [data objectForKey:@"cases"];
	return self;
}
/**
 Standard constructor thingie
 */
-(id) init {
	self = [super init];
	items_ = [[NSMutableArray alloc] init];
	return self;
}
/**
 Standard destructor thingie
 */
-(void) dealloc {
	[items_ release];
	[super dealloc];
}
/**
 Add an item object, we are just saving the attributes at the moment
 */
-(Boolean) addItem:(NSDictionary*)attributeDict {
	NSString* currItem = [attributeDict objectForKey:@"type"];
	control_types_t itemType = [self getItemType:currItem];
	
	if (itemType == unknown) {
		NSLog(@"cannot add control Item, unknown primitive type %@", currItem);		
		return NO;
	}
	
	NSDictionary * tmpDict = [attributeDict copy];
	[items_ addObject:tmpDict];
	[tmpDict release];
	return YES;
}

-(control_types_t) getItemType: (NSString*) itemType {
	// if the control item is not one of 
	// label, picker, slider, button, toggle,
	// toggled, video, browser, mediaPlayer,
	// trackDetails, space
	if ([itemType caseInsensitiveCompare:@"label"] == NSOrderedSame) {
		return label;
	} else if ([itemType caseInsensitiveCompare:@"picker"] == NSOrderedSame) {
		return picker;
	} else if ([itemType caseInsensitiveCompare:@"slider"] == NSOrderedSame) {
		return slider;
	} else if ([itemType caseInsensitiveCompare:@"button"] == NSOrderedSame) {
		return button;
	} else if ([itemType caseInsensitiveCompare:@"toggle"] == NSOrderedSame) {
		return toggle;
	} else if ([itemType caseInsensitiveCompare:@"video"] == NSOrderedSame) {
		return video;
	} else if ([itemType caseInsensitiveCompare:@"browser"] == NSOrderedSame) {
		return browser;
	} else if ([itemType caseInsensitiveCompare:@"mediaPlayer"] == NSOrderedSame) {
		return mediaPlayer;
	} else if ([itemType caseInsensitiveCompare:@"trackDetails"] == NSOrderedSame) {
		return trackDetails;
	} else if ([itemType caseInsensitiveCompare:@"space"] == NSOrderedSame) {
		return space;
	} else {
		return unknown;
	}
}
@end
