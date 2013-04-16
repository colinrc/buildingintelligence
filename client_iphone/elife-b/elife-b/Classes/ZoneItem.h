//
//  ZoneItem.h
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomsTableViewController.h"



@interface ZoneItem : NSObject {
	NSString *name;
	RoomsTableViewController *zoneelemVC;
	id *parentNC;
	
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) RoomsTableViewController *zoneelemVC;
@property (nonatomic, retain) id *parentNC;

- (id)initWithName:(NSString *)newname;

@end
