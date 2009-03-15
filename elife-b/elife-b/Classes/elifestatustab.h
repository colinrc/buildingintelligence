//
//  elifestatustab.h
//  elife-b
//
//  Created by Cameron Humphries on 1/01/09.
//  Copyright 2009 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface elifestatustab : NSObject {
	NSString *tabname;
	NSDictionary *tabattr;
	NSMutableArray *statusitems;
}

@property (retain,nonatomic) NSString *tabname;
@property (retain,nonatomic) NSDictionary *tabattr;
@property (retain,nonatomic) NSMutableArray *statusitems;


- (id)initWithName:(NSString *)thename andDict:(NSDictionary *)thedict;

@end
