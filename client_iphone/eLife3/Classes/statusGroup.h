//
//  statusGroup.h
//  eLife3
//
//  Created by Richard Lemon on 16/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface statusGroup : NSObject
{
	NSString *name_;
	NSString *icon_;
	NSString *show_;
	NSString *hide_;
}

@property (nonatomic, copy) NSString *name_;
@property (nonatomic, copy) NSString *icon_;
@property (nonatomic, copy) NSString *show_;
@property (nonatomic, copy) NSString *hide_;


-(id)initWithDictionary:(NSDictionary *)data;

@end

