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
}

@property (nonatomic, retain) NSDictionary *macroattr;

- (id)initWithDict:(NSDictionary *)thedict;

@end
