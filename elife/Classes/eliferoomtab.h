//
//  eliferoomtab.h
//  elife
//
//  Created by Cameron Humphries on 5/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface eliferoomtab : NSObject {
	NSString *name;
	NSDictionary *tabattr;
	NSMutableArray *controllist;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDictionary *tabattr;
@property (nonatomic, retain) NSMutableArray *controllist;

- (id) initWithName:(NSString *)thename andAttributes:(NSDictionary *)theattr;

@end
