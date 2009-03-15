//
//  elifecontrolrow.h
//  elife-b
//
//  Created by Cameron Humphries on 19/01/09.
//  Copyright 2009 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface elifecontrolrow : NSObject {
	NSMutableDictionary *rowattrs;
	NSMutableArray *displayitems;
}

@property (nonatomic, retain) NSMutableDictionary *rowattrs;
@property (nonatomic, retain) NSMutableArray *displayitems;

@end
