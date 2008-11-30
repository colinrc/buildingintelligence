//
//  MacrosTableViewController.h
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "elifemacro.h"

@interface MacrosTableViewController : UITableViewController {
	IBOutlet UITableViewCell *myCell;
}

@property (nonatomic, assign) IBOutlet UITableViewCell *myCell;

@end
