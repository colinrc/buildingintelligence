//
//  RoomControlsTabBarController.h
//  elife
//
//  Created by Cameron Humphries on 21/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RoomControlsTabBarController : UITabBarController {
	NSInteger zoneidx;
	NSInteger roomidx;
}

@property (nonatomic) NSInteger zoneidx;
@property (nonatomic) NSInteger roomidx;

@end
