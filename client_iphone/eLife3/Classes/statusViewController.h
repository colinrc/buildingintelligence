//
//  statusViewController.h
//  eLife3
//
//  Created by Cameron Humphries on 14/01/10.
//  Copyright 2010 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface statusViewController : UITableViewController {

}

- (void)registerWithNotification:(NSString *)thekey;
- (void)statusUpdate:(NSNotification *)notification;
	

@end