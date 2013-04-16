//
//  xmlParser.h
//  eLife3
//
//  Created by Richard Lemon on 9/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface xmlParser : NSObject <NSXMLParserDelegate> {
	NSString *className;
	NSString *currentNodeName;
	NSMutableString *currentNodeContent;
//	NSMutableArray *currentstate;
}

- (id)initParser;
- (id)parseXMLData:(NSString *)xmldata;

@end
