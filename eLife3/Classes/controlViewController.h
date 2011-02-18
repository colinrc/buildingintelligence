//
//  controlViewController.h
//  eLife3
//
//  Created by Richard Lemon on 17/02/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <UIKit/UIKit.h>


// types of control understood by the client
// label
// 
enum control_types {
	label,
	picker,
	slider,
	button,
	toggle,
	toggled,
	video,
	browser,
	mediaPlayer,
	trackDetails,
	space
};

@interface controlViewController : UIViewController {

}

@end
