//
//  ControlOnOffCellView.h
//  elife
//
//  Created by Cameron Humphries on 9/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlOnOffCellView : UITableViewCell {
	IBOutlet UIImageView *ctrlicon;
	IBOutlet UILabel *ctrllabel;
	IBOutlet UISwitch *ctrlswitch;
}

@property (nonatomic, retain) IBOutlet UIImageView *ctrlicon;
@property (nonatomic, retain) IBOutlet UILabel *ctrllabel;
@property (nonatomic, retain) IBOutlet UISwitch *ctrlswitch;

-(IBAction)OnOffAction:(id)sender;

@end
