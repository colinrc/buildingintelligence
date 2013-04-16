//
//  SettingsViewController.h
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *localserverip;
	IBOutlet UITextField *localserverport;
	IBOutlet UITextField *localconfigname;
}

@property (nonatomic, retain) IBOutlet UITextField *localserverip;
@property (nonatomic, retain) IBOutlet UITextField *localserverport;
@property (nonatomic, retain) IBOutlet UITextField *localconfigname;

- (IBAction)finishEdit:(id)sender;

@end
