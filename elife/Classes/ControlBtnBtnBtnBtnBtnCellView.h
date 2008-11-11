//
//  ControlBtnBtnBtnBtnBtnCellView.h
//  elife
//
//  Created by Cameron Humphries on 21/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlBtnBtnBtnBtnBtnCellView : UITableViewCell {
	IBOutlet UIButton *btn1;
	IBOutlet UIButton *btn2;
	IBOutlet UIButton *btn3;
	IBOutlet UIButton *btn4;
	IBOutlet UIButton *btn5;	
}

@property (nonatomic, retain) IBOutlet UIButton *btn1;
@property (nonatomic, retain) IBOutlet UIButton *btn2;
@property (nonatomic, retain) IBOutlet UIButton *btn3;
@property (nonatomic, retain) IBOutlet UIButton *btn4;
@property (nonatomic, retain) IBOutlet UIButton *btn5;

-(IBAction)Btn1Action:(id)sender;
-(IBAction)Btn2Action:(id)sender;
-(IBAction)Btn3Action:(id)sender;
-(IBAction)Btn4Action:(id)sender;
-(IBAction)Btn5Action:(id)sender;

@end
