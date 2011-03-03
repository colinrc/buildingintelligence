//
//  globalConfig.h
//  eLife3
//
//  Created by Richard Lemon on 18/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "logList.h"
#import "controlMap.h"
#import "macroList.h"
#import "zoneList.h"
#import "statusGroupMap.h"
#import "uiControlList.h"


@interface globalConfig : NSObject {
	logList* logging_;
	controlMap* controls_;
	macroList* macros_;
	zoneList* zones_;
	statusGroupMap* statusbar_;
	uiControlList* uicontrols_;
	
}

@property(nonatomic, retain) logList* logging_;
@property(nonatomic, retain) controlMap* controls_;
@property(nonatomic, retain) macroList* macros_;
@property(nonatomic, retain) zoneList* zones_;
@property(nonatomic, retain) statusGroupMap* statusbar_;
@property(nonatomic, retain) uiControlList* uicontrols_;

+(globalConfig*)sharedInstance;

-(void)reset; // TODO: need to be able to cleanup

@end
