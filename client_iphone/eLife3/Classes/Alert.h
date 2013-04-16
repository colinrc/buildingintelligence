//
//  Alert.h
//  eLife3
//
//  Created by Richard Lemon on 4/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Alert : NSObject {
	
	NSString* name_;
	NSMutableArray* keys_;
	NSString* icon_;
}

@property (nonatomic, copy) NSString* name_;

-(id)initWithDictionary:(NSDictionary *)data;
-(void)addKeys:(NSString *)keysString;
@end
