//
//  ControlWebCellView.h
//  elife
//
//  Created by Cameron Humphries on 21/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlWebCellView : UITableViewCell {
	IBOutlet UIWebView *webview;
}

@property (nonatomic, retain) IBOutlet UIWebView *webview;

@end
