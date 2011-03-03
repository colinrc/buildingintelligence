//
//  controlViewController.h
//  eLife3
//
//  Created by Richard Lemon on 17/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Control.h"

@interface controlViewController : UIViewController //<UIScrollViewDelegate> 
{
	Control* control_;// The control we are handling
	NSMutableArray* currentControl_; // array of control rows
	int current_row_;// straight row counter +1 per row
	int current_column_;// percentage of screen width we are at
	int remaining_items_;// number of items left to show
}

@property (nonatomic, retain) Control* control_;
@property (nonatomic, retain) NSMutableArray* currentControl_;
@property (nonatomic) int current_row_;
@property (nonatomic) int current_column_;
@property (nonatomic) int remaining_items_;

-(void) nextRow;
-(Boolean) evaluateCases:(NSString*)cases;
-(void) addLabel:(NSDictionary *)labelDict;
-(void) addSlider:(NSDictionary *)labelDict;
-(void) addButton:(NSDictionary *)labelDict;
-(void) addToggle:(NSDictionary *)labelDict;

@end
