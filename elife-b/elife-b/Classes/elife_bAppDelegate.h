//
//  elife_bAppDelegate.h
//  elife-b
//
//  Created by Cameron Humphries on 29/11/08.
//  Copyright Humphries Consulting Pty Ltd 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface elife_bAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
