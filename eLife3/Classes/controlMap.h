//
//  controlMap.h
//  eLife3
//
//  Created by Richard Lemon on 15/06/10.
//  Copyright 2010 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Control.h"

@interface controlMap : NSObject {

	NSMutableDictionary *controls_;

}

@property (nonatomic, retain) NSMutableDictionary *controls_;

-(Boolean)addControl:(Control *)control;
-(Boolean)updateControl:(NSDictionary *)data;
-(Control*)findControl:(NSString *)key;

@end
