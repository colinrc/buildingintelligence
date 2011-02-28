//
//  macroList.m
//  eLife3
//
//  Created by Richard Lemon on 9/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import "macroList.h"
#import "macro.h"

@implementation macroList

@synthesize macrolist_;

/**
 Standard constructor thingie
 */
-(id)init {
	self = [super init];
	macrolist_ = [[NSMutableArray alloc] initWithCapacity:5];
	return self;
}
/**
 Standard destructor thingie
 */
-(void) dealloc 
{
	[macrolist_ release];
	[super dealloc];
}

/**
 Adds a new macro to the list, called during startup
 Need to send a notification as the macros are read
 after the windows are shown
*/
-(void)addMacro:(NSDictionary *)item {
	@synchronized(self) {
		macro *temp_macro = [[macro alloc] initWithDict:item];
		[macrolist_ addObject:temp_macro];
		[temp_macro release];

		[[NSNotificationCenter defaultCenter] postNotificationName:@"addMacro" object:self];
		//NSLog(@"macro entries: %d", [macrolist_ count]);
	}
}
/**
 Updates the run state of the found macro
*/
-(void)updateMacro:(NSDictionary *)item {
	@synchronized(self) {
		// macro state change being reported
		// locate macro and update status
		BOOL found_macro=NO;
		int i;
		macro *current_macro = nil;
		
		for (i=0; (!found_macro) && i< [macrolist_ count]; i++)
		{
			current_macro = [macrolist_ objectAtIndex:i];
			if ([[current_macro.macroattr objectForKey:@"EXTRA"] isEqualToString:[item objectForKey:@"EXTRA"]])
			{
				found_macro=YES;
				if ([[item objectForKey:@"COMMAND"] isEqualToString:@"started"]) {
					if (current_macro.running != YES)
					{
						current_macro.running=YES;
						[[NSNotificationCenter defaultCenter] postNotificationName:[item objectForKey:@"EXTRA"] object:self];
					}

				} else if ([[item objectForKey:@"COMMAND"] isEqualToString:@"finished"]) {
					if (current_macro.running !=NO)
					{
						current_macro.running=NO;
						[[NSNotificationCenter defaultCenter] postNotificationName:[item objectForKey:@"EXTRA"] object:self];
					}
				}
				else {
					NSLog(@"Macro %@ received command %@",[current_macro.macroattr objectForKey:@"EXTRA"], [item objectForKey:@"COMMAND"] );
				}

			}
		}
	}
}
/**
 returns the number of macros defined
 */
-(NSInteger)countMacros {
	return [macrolist_ count];
}

@end