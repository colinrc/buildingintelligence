//
//  uiBrowser.h
//  eLife3
//
//  Created by Richard Lemon on 8/03/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Control.h"

@interface uiBrowser : UIWebView <UIWebViewDelegate> {
	NSDictionary* attributes_;
	Control* control_;
	NSTimer *timer_;
}

@property (nonatomic, copy) NSDictionary* attributes_;
@property (nonatomic, retain) Control* control_;
@property (nonatomic, retain) NSTimer *timer_;

-(void) updateControl;
-(void) refreshPage;

@end
