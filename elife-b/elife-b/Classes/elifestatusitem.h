//
//  elifestatusitem.h
//  elife-b
//
//  Created by Cameron Humphries on 11/01/09.
//  Copyright 2009 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface elifestatusitem : NSObject {
	NSString *key;
}

@property (retain, nonatomic) NSString *key;

- (id)initWithKey:(NSString *)thekey;

@end

