//
//  eLife3AppDelegate.h
//  eLife3
//
//  Created by Cameron Humphries on 10/01/10.
//  Copyright Humphries Consulting Pty Ltd 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "elifesocket.h"

@interface eLife3AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIActionSheetDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	elifesocket *elifeSvrConn;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) elifesocket *elifeSvrConn;

@end
