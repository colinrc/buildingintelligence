//
//  eliferoomcontrol.h
//  elife
//
//  Created by Cameron Humphries on 5/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface eliferoomcontrol : NSObject {
	NSString *name;
	NSString *key;
	NSDictionary *roomctrlattr;
	NSString *command;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSDictionary *roomctrlattr;
@property (nonatomic, retain) NSString *command;

- (id) initWithName:(NSString *)thename andKey:(NSString *)thekey andAttributes:(NSDictionary *)theattr;

@end
