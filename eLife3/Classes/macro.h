//
//  macro.h
//  eLife3
//
//  Created by Richard Lemon on 9/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface macro : NSObject {
	NSDictionary *macroattr;
	BOOL running;
}

@property (nonatomic, retain) NSDictionary *macroattr;
@property BOOL running;

- (id)initWithDict:(NSDictionary *)thedict;
- (BOOL)isRunning;
@end
