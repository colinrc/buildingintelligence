//
//  roomViewController.h
//  eLife3
//
//  Created by Richard Lemon on 9/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room.h"

@interface roomViewController : UITableViewController {
	Room *room_;
	UITableViewCell *sliderCell_;
}

@property (nonatomic, assign) IBOutlet UITableViewCell *sliderCell_;
@property (nonatomic,retain) Room* room_;

- (void)registerWithNotification:(NSString *)thekey;

@end
