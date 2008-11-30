//
//  eliferoom.h
//  elife
//
//  Created by Cameron Humphries on 5/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface eliferoom : NSObject {
	NSString *name;
	NSDictionary *roomattr;
	NSMutableArray *tablist;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDictionary *roomattr;
@property (nonatomic, retain) NSMutableArray *tablist;

- (id) initWithName:(NSString *)thename andAttributes:(NSDictionary *)theattr;

@end
