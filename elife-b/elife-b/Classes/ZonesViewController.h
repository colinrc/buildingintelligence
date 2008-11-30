//
//  ZonesViewController.h
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZonesTableViewController.h"

@interface ZonesViewController : UINavigationController {
	ZonesTableViewController *zonesTabControl;
}

@property (nonatomic, retain) ZonesTableViewController *zonesTabControl;

@end
