//
//  elifemacro.h
//  elife
//
//  Created by Cameron Humphries on 28/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ElifeMacro : NSObject {
	NSDictionary *macroattr;
	BOOL running;
}

@property (nonatomic, retain) NSDictionary *macroattr;
@property BOOL running;

- (id)initWithDict:(NSDictionary *)thedict;
- (BOOL)isRunning;
@end
