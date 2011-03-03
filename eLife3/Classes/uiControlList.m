//
//  uiControlList.m
//  eLife3
//
//  Created by Richard Lemon on 2/03/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import "uiControlList.h"


@implementation uiControlList

@synthesize currentName_;
@synthesize currentRow_;

-(id) init {
	self = [super init];
	controlTypes_ = [[NSMutableDictionary alloc] init];
	currentRow_ = nil;
	currentName_ = nil;
	return self;
}

-(Boolean) addControlType:(NSDictionary*) attributeDict {
	NSString* name =  [attributeDict objectForKey:@"type"];
	if (name == nil) {
		NSLog(@"cannot add control Type, invalid xml, no type name");				
		return NO;
	}
	NSLog(@"addControlType %@",name);
	if ([controlTypes_ objectForKey:name] != nil) {
		NSLog(@"cannot add control Type, already defined control with name %@", name);		
		return NO;
	}
	self.currentName_ = name;
	NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
	[controlTypes_  setObject:tmpArray forKey: name];
	[tmpArray release];
	return YES;
}

-(Boolean) addControlRow:(NSDictionary*) attributeDict {
	NSLog(@"addControlRow");
	NSMutableArray* currentRowList = [self getControlRows:currentName_];

	if (currentRowList == nil) {
		NSLog(@"cannot add control row, no control with name %@", currentName_);		
		return NO;
	}
	
	currentRow_  = [[controlRow alloc] initWithDictionary:attributeDict];
	[currentRowList addObject:currentRow_];
	[currentRow_ release];
	return YES;
}

-(Boolean) addControlItem:(NSDictionary*) attributeDict {
	NSLog(@"addControlType %@", [attributeDict objectForKey:@"type"]);
	if (currentRow_ == nil) {
		NSLog(@"cannot add control item, no current row", currentName_);		
		return NO;
	}
	
	return [currentRow_ addItem: attributeDict];
}

-(NSMutableArray*) getControlRows:(NSString *)controlTypeName {
	
	return [controlTypes_ objectForKey:controlTypeName];
}
@end
