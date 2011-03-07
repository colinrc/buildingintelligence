//
//  uiButton.h
//  eLife3
//
//  Created by Richard Lemon on 4/03/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Control.h"

@interface uiButton : UIButton {
	NSDictionary* attributes_;
	Control* control_;
}

@property (nonatomic, copy) NSDictionary* attributes_;
@property (nonatomic, retain) Control* control_;

-(void) updateControl;
-(void) buttonAction:(id)sender;
-(void) statusUpdate:(NSNotification *)notification;

@end
