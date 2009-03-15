//
//  ControlTableCell.h
//  elife-b
//
//  Created by Cameron Humphries on 18/02/09.
//  Copyright 2009 Humphries Consulting Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlTableCell : UITableViewCell {
	NSTimer *celltimer;
	NSInteger cellzoneidx;
	NSInteger cellroomidx;
	NSInteger celltabidx;
	NSInteger cellcontrolidx;
}

@property (retain, nonatomic) NSTimer *celltimer;
@property (nonatomic) NSInteger cellzoneidx;
@property (nonatomic) NSInteger cellroomidx;
@property (nonatomic) NSInteger celltabidx;
@property (nonatomic) NSInteger cellcontrolidx;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier zoneidx:(NSInteger)zoneidx roomidx:(NSInteger)roomidx tabidx:(NSInteger)tabidx controlidx:(NSInteger)controlidx;


@end
