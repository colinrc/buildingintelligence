//
//  logViewController.h
//  eLife3
//
//  Created by Richard Lemon on 8/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface logViewController : UITableViewController {

}

- (void)registerWithNotification:(NSString *)thekey;
- (void)logUpdate:(NSNotification *)notification;

@end
