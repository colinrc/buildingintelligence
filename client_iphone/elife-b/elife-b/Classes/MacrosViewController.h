//
//  MacrosViewController.h
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacrosTableViewController.h"

@interface MacrosViewController : UINavigationController {
	MacrosTableViewController *macrosTabControl;
}

@property (nonatomic, retain) MacrosTableViewController *macrosTabControl;

@end
