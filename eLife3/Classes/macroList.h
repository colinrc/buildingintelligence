//
//  macroList.h
//  eLife3
//
//  Created by Richard Lemon on 9/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface macroList : NSObject {
	NSMutableArray *macrolist_;
}

-(void)addMacro:(NSDictionary *)item;
-(void)updateMacro:(NSDictionary *)item;
-(void)deleteMacros;
-(NSInteger)countMacros;

@property (nonatomic, retain) NSMutableArray *macrolist_;

@end
