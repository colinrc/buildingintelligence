//
//  eLife3AppDelegate.h
//  eLife3
//
//  Created by Cameron Humphries on 10/01/10.
//  Copyright Humphries Consulting Pty Ltd 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serverConnection.h"

// tab order helper
enum tabs{
	macro_tab,
	status_tab,
	rooms_tab,
	more_tab
};

@interface eLife3AppDelegate : NSObject <UIApplicationDelegate, UIActionSheetDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	serverConnection *elifeSvrConn;
	Boolean server_not_setup_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) serverConnection *elifeSvrConn;
@property (nonatomic) Boolean server_not_setup_;

-(void)networkUpdate:(UITableViewController *)table;


@end
