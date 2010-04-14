//
//  settingsViewController.h
//  eLife3
//
//  Created by Cameron Humphries on 14/01/10.
//  Copyright 2010 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface settingsViewController : UIViewController {
	UITextField *elifesvr;
	UITextField *elifesvrport;
}

@property (nonatomic, retain) IBOutlet UITextField *elifesvr;
@property (nonatomic, retain) IBOutlet UITextField *elifesvrport;

- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@end
