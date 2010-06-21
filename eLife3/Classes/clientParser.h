//
//  clientParser.h
//  eLife3
//
//  Created by Richard Lemon on 11/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface clientParser : NSObject < UIAlertViewDelegate > {
	NSString *className;
	NSMutableArray *items;
	NSObject *item; // stands for any class    
	NSString *currentNodeName;
	NSMutableString *currentNodeContent;
	NSMutableArray *currentstate;
	Boolean parserSuccess;
}

- (NSArray *)items;
- (id)init;
-(Boolean)checkSuccess;

@end
