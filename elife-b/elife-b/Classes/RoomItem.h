//
//  RoomItem.h
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomControlsTabBarController.h"

@interface RoomItem : NSObject {
	NSString *name;
	NSMutableArray *controltabs;
	RoomControlsTabBarController *roomTC;
	id *parentVC;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *controltabs;
@property (nonatomic, retain) RoomControlsTabBarController *roomTC;
@property (nonatomic, retain) id *parentVC;

- (id)initWithName:(NSString *)thename;

@end
