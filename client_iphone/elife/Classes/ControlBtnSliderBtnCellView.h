//
//  ControlBtnSliderBtnCellView.h
//  elife
//
//  Created by Cameron Humphries on 21/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlBtnSliderBtnCellView : UITableViewCell {
	IBOutlet UIButton *btn1;
	IBOutlet UISlider *slider;
	IBOutlet UIButton *btn2;
}

@property (nonatomic, retain) IBOutlet UIButton *btn1;
@property (nonatomic, retain) IBOutlet UISlider *slider;
@property (nonatomic, retain) IBOutlet UIButton *btn2;

-(IBAction)Btn1Action:(id)sender;
-(IBAction)SliderAction:(id)sender;
-(IBAction)Btn2Action:(id)sender;

@end
