//
//  elifezone.h
//  elife
//
//  Created by Cameron Humphries on 4/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface elifezone : NSObject {
	NSString *name;
	NSDictionary *zoneattr;
	NSMutableArray *roomlist;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDictionary *zoneattr;
@property (nonatomic, retain) NSMutableArray *roomlist;

- (id) initWithName:(NSString *)thename andAttributes:(NSDictionary *)theattr;

@end
