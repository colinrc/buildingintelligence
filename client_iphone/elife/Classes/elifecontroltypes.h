//
//  elifecontroltypes.h
//  elife
//
//  Created by Cameron Humphries on 20/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface elifecontroltypes : NSObject {
	NSString *controltype;
	NSMutableArray *displayrows;
}

@property (nonatomic, retain) NSString *controltype;
@property (nonatomic, retain) NSMutableArray *displayrows;

-(id)initWithType:(NSString *)thetype;

@end
