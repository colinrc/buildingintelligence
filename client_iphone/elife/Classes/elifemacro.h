//
//  elifemacro.h
//  elife
//
//  Created by Cameron Humphries on 28/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ElifeMacro : NSObject {
	NSString *name;
	NSString *key;
	NSInteger status;
	
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *key;
@property (nonatomic) NSInteger status;

- (id)initWithName:(NSString *)thename andKey:(NSString *)thekey currentStatus:(NSInteger)thestatus;

@end
