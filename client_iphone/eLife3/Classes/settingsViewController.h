//
//  settingsViewController.h
//  eLife3
//
//  Created by Cameron Humphries on 14/01/10.
//  Copyright 2010 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface settingsViewController : UITableViewController <UITextFieldDelegate>{
	UITextField *elifesvr;
	UITextField *elifesvrport;
	UITextField *config_file;
	UITextField *config_port;
	UITextField *remote_server_url;
	UITextField *remote_refresh_rate;
}

@property (nonatomic, retain) IBOutlet UITextField *elifesvr;
@property (nonatomic, retain) IBOutlet UITextField *elifesvrport;
@property (nonatomic, retain) IBOutlet UITextField *config_file;
@property (nonatomic, retain) IBOutlet UITextField *config_port;
@property (nonatomic, retain) IBOutlet UITextField *remote_server_url;
@property (nonatomic, retain) IBOutlet UITextField *remote_refresh_rate;

//-(void) keyboardWillHide:(NSNotification *)notification;

@end
