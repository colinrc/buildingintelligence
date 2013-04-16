//
//  elifecontroltypeitem.h
//  elife
//
//  Created by Cameron Humphries on 20/10/08.
//  Copyright 2008 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface elifecontroltypeitem : NSObject {
	NSString *ctrlitemtype;
	NSDictionary *itemattrs;
}

@property (nonatomic, retain) NSString *ctrlitemtype;
@property (nonatomic, retain) NSDictionary *itemattrs;

-(id)initWithType:(NSString *)thetype andAttrs:(NSDictionary *)theattrs;

@end
