//
//  statusGroupMap.h
//  eLife3
//
//  Created by Richard Lemon on 16/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Control.h"
#import "statusGroup.h"

@interface statusGroupMap : NSObject {

	NSMutableArray *group_names_;
	NSMutableDictionary *group_data_;

}

@property (nonatomic, retain) NSMutableArray* group_names_;
@property (nonatomic, retain) NSMutableDictionary* group_data_;

+(statusGroupMap*)sharedInstance;

-(void)addGroup:(NSDictionary *)data;
-(void)addStatusItem:(Control *)control;
-(statusGroup*)getGroup:(NSInteger)group;
-(NSInteger)activeItems:(NSInteger)group;
-(Control*)activeControl:(NSInteger)section:(NSInteger)row;

@end
