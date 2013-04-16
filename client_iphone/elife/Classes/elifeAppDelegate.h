//
//  elifeAppDelegate.h
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright Humphries Consulting Pty Ltd 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZonesViewController.h"

@interface elifeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
	UITabBarController *rootTC;
	ZonesViewController *zonesNC;
	NSMutableArray *mainVClist;
	
	NSMutableArray *elifezonelist;
	NSMutableArray *elifectrltypes;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *rootTC;
@property (nonatomic, retain) ZonesViewController *zonesNC;
@property (nonatomic, retain) NSMutableArray *mainVClist;
@property (nonatomic, retain) NSMutableArray *elifezonelist;
@property (nonatomic, retain) NSMutableArray *elifectrltypes;

@end

