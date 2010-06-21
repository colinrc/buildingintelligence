//
//  xmlParser.h
//  eLife3
//
//  Created by Richard Lemon on 9/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface xmlParser : NSObject {
	NSString *className;
	NSMutableArray *items;
	NSObject *item; // stands for any class    
	NSString *currentNodeName;
	NSMutableString *currentNodeContent;
	NSMutableArray *currentstate;
}

- (NSArray *)items;
- (id)initParser;
- (id)parseXMLData:(NSString *)xmldata;

@end
