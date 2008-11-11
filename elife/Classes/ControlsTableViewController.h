//
//  ControlsTableViewController.h
//  elife
//
//  Created by Cameron Humphries on 8/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlsTableViewController : UITableViewController {
	NSInteger zoneidx;
	NSInteger roomidx;
	NSInteger tabidx;
}

@property (nonatomic) NSInteger zoneidx;
@property (nonatomic) NSInteger roomidx;
@property (nonatomic) NSInteger tabidx;

@end
