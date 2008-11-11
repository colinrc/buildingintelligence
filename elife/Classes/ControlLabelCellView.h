//
//  ControlLabelCellView.h
//  elife
//
//  Created by Cameron Humphries on 21/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlLabelCellView : UITableViewCell {
	IBOutlet UILabel *label;
}

@property (nonatomic, retain) IBOutlet UILabel *label;

@end
