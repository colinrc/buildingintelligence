//
//  elife_bAppDelegate.h
//  elife-b
//
//  Created by Cameron Humphries on 29/11/08.
//  Copyright Humphries Consulting Pty Ltd 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZonesViewController.h"
#import "elifesocket.h"

@interface elife_bAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
	UITabBarController *rootTC;
	ZonesViewController *zonesNC;
	NSMutableArray *mainVClist;
	
	NSMutableArray *elifezonelist;
	NSMutableArray *elifectrltypes;
	NSMutableArray *elifemacrolist;
	
	elifesocket *elifesvr;
	NSMutableArray *msgs_for_svr;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *rootTC;
@property (nonatomic, retain) ZonesViewController *zonesNC;
@property (nonatomic, retain) NSMutableArray *mainVClist;
@property (nonatomic, retain) NSMutableArray *elifezonelist;
@property (nonatomic, retain) NSMutableArray *elifectrltypes;
@property (nonatomic, retain) NSMutableArray *elifemacrolist;
@property (nonatomic, retain) NSMutableArray *msgs_for_svr;
@property (retain) elifesocket *elifesvr;

@end

