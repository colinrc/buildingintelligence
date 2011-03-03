//
//  controlRow.h
//  eLife3
//
//  Created by Richard Lemon on 2/03/11.
//  Copyright 2011 Building Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum control_types {
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
	space,
	unknown
} control_types_t;

@interface controlRow : NSObject {
	NSString* cases_;
	NSMutableArray* items_;
}

@property (nonatomic, copy) NSString *cases_;
@property (nonatomic, assign) NSMutableArray* items_;

-(id)initWithDictionary:(NSDictionary *)data;
-(Boolean) addItem:(NSDictionary*)attributeDict;
-(control_types_t) getItemType: (NSString*) itemType;

@end
