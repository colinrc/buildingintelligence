//
//  ControlBtnBtnCellView.h
//  elife
//
//  Created by Cameron Humphries on 21/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlBtnBtnCellView : UITableViewCell {
	IBOutlet UIButton *btn1;
	IBOutlet UIButton *btn2;
}

@property (nonatomic, retain) IBOutlet UIButton *btn1;
@property (nonatomic, retain) IBOutlet UIButton *btn2;

-(IBAction)Btn1Action:(id)sender;
-(IBAction)Btn2Action:(id)sender;

@end
