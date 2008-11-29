//
//  elifeXMLParser.h
//  elife
//
//  Created by Cameron Humphries on 21/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface elifeXMLParser : NSObject {
	NSString *className;
	NSMutableArray *items;
	NSObject *item; // stands for any class    
	NSString *currentNodeName;
	NSMutableString *currentNodeContent;
	NSMutableArray *currentstate;
}

- (NSArray *)items;
- (id)parseXMLAtURL:(NSURL *)url toObject:(NSString *)aClassName parseError:(NSError **)error;
- (id)parseXMLData:(NSString *)xmldata;

@end