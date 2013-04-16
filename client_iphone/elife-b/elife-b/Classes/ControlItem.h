//
//  ControlItem.h
//  elife
//
//  Created by Cameron Humphries on 21/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlItem : NSObject {
	NSString *tabname;
	NSString *name;
	NSString *key;
}

@property (nonatomic, retain) NSString *tabname;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *key;

- (id)initWithName:(NSString *)newname andKey:(NSString *)newkey andTabName:(NSString *)newtabname;

@end
