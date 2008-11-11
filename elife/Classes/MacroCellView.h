//
//  MacroCellView.h
//  elife
//
//  Created by Cameron Humphries on 20/09/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MacroCellView : UITableViewCell {
	IBOutlet UILabel	*macroLabel;
	IBOutlet UIActivityIndicatorView	*macroprogress;
}

@property (nonatomic, retain) UIActivityIndicatorView *macroprogress;
@property (nonatomic, retain) UILabel *macroLabel;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;


@end
