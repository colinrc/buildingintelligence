//
//  clientParser.h
//  eLife3
//
//  Created by Richard Lemon on 11/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface clientParser : NSObject < UIAlertViewDelegate, NSXMLParserDelegate> {
	NSString *className;
	NSString *currentNodeName;
	NSMutableString *currentNodeContent;
	Boolean parserSuccess;
	NSTimer *timer_;
}

@property (nonatomic, retain) NSTimer *timer_;
@property (nonatomic) Boolean parserSuccess;
- (id)init;
-(void)loadConfig;

@end
