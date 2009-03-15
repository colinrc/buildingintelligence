//
//  ControlTableCell.m
//  elife-b
//
//  Created by Cameron Humphries on 18/02/09.
//  Copyright 2009 Humphries Consulting Pty Ltd. All rights reserved.
//

#import "ControlTableCell.h"
#import "elife_bAppDelegate.h"
#import "elifezone.h"
#import "eliferoom.h"
#import "eliferoomtab.h"
#import "eliferoomcontrol.h"
#import "elifecontroltypes.h"
#import "elifecontroltypeitem.h"
#import "elifecontrolrow.h"

@implementation ControlTableCell
@synthesize celltimer;
@synthesize cellzoneidx;
@synthesize cellroomidx;
@synthesize celltabidx;
@synthesize cellcontrolidx;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier zoneidx:(NSInteger)zoneidx roomidx:(NSInteger)roomidx tabidx:(NSInteger)tabidx controlidx:(NSInteger)controlidx {
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:zoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:roomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:tabidx];
	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:controlidx];
	elifecontroltypes *thecontroltype;
	NSString *controltypeid = [thecontrol.roomctrlattr objectForKey:@"type"];
	
	self.cellzoneidx = zoneidx;
	self.cellroomidx = roomidx;
	self.celltabidx = tabidx;
	self.cellcontrolidx = controlidx;
	
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		// we need a view to place our controls on.
		UIView *myContentView = self.contentView;
		
		// Find specification for the control type
		NSInteger i=0;
		BOOL found=NO;
		while ((i < [elifeappdelegate.elifectrltypes count]) && !found) {
			thecontroltype = [elifeappdelegate.elifectrltypes objectAtIndex:i];
			if ([controltypeid isEqualToString:[thecontroltype controltype]]) {
				found=YES;
			} else {
				i++;
			}
		}
		
		// Loop through control type creating objects
		elifecontrolrow *currctrlrow;
		elifecontroltypeitem *currctrlitem;
		NSDictionary *itemattrs;
		for (int j=0; j < [thecontroltype.displayrows count]; j++) {
			currctrlrow = [thecontroltype.displayrows objectAtIndex:j];
			for (int k=0; k < [currctrlrow.displayitems count]; k++) {
				currctrlitem = [currctrlrow.displayitems objectAtIndex:k];
				itemattrs = currctrlitem.itemattrs;
				if ([[itemattrs objectForKey:@"type"] isEqualToString:@"label"]) {
					UILabel *mylabel = [[UILabel alloc] init];
					mylabel.tag=(j+1)*100+k;
					mylabel.textAlignment = UITextAlignmentCenter;
					if ([itemattrs objectForKey:@"states"]) {
						NSArray *states = [[itemattrs objectForKey:@"states"] componentsSeparatedByString:@","];
						NSArray *formats = [[itemattrs objectForKey:@"formats"] componentsSeparatedByString:@","];
						if ([thecontrol.ctrlstatus isEqualToString:[states objectAtIndex:0]]) {
							mylabel.text = [formats objectAtIndex:0];
						}
						else if ([thecontrol.ctrlstatus isEqualToString:[states objectAtIndex:1]]) {
							mylabel.text = [formats objectAtIndex:1];
						}
					} else {
						mylabel.text = thecontrol.name;
					}					
					[myContentView addSubview:mylabel];
					[mylabel release];
				} else if ([[itemattrs objectForKey:@"type"] isEqualToString:@"video"]) {
					UIWebView *mywebview = [[UIWebView alloc] init];
					NSString *videosrc = @"about:blank";
					mywebview.tag=(j+1)*100+k;
					if ([itemattrs objectForKey:@"src"]) {
						videosrc = [itemattrs objectForKey:@"src"];
					}
					NSURL *myurl = [NSURL URLWithString:videosrc];
					NSURLRequest *myurlreq = [NSURLRequest requestWithURL:myurl];
					[mywebview loadRequest:myurlreq];					
					[myContentView addSubview:mywebview];
					[mywebview release];
				} else if ([[itemattrs objectForKey:@"type"] isEqualToString:@"button"]) {
					UIButton *mybutton = [[UIButton alloc] init];
					NSString *iconname;
					mybutton.tag=(j+1)*100+k;
					iconname = [itemattrs objectForKey:@"icon"];
					if (iconname != nil) {
						[mybutton setImage:[UIImage imageNamed:[iconname stringByAppendingString:@".png"]] forState:UIControlStateNormal];
					} else {
						[mybutton setTitle:[itemattrs objectForKey:@"label"] forState:UIControlStateNormal];
						
					}					
					[myContentView addSubview:mybutton];
					[mybutton release];
				} else if ([[itemattrs objectForKey:@"type"] isEqualToString:@"toggle"]) {
					//UIButton *mybutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
					UIButton *mybutton = [[UIButton alloc] init];
					mybutton.tag=(j+1)*100+k;
					if ([itemattrs objectForKey:@"labels"]) {
						NSArray *labels = [[itemattrs objectForKey:@"labels"] componentsSeparatedByString:@","];
						if ([thecontrol.ctrlstatus isEqualToString:@"on"]) {
							[mybutton setTitle:[labels objectAtIndex:0] forState:UIControlStateNormal];
							
						}
						//else if ([thecontrol.ctrlstatus isEqualToString:@"off"]) {
						else {
							[mybutton setTitle:[labels objectAtIndex:1] forState:UIControlStateNormal];
							
						}
						[mybutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
					}
					else {
						[mybutton setTitle:thecontrol.name forState:UIControlStateNormal];
						
					}					
					[myContentView addSubview:mybutton];
					[mybutton release];
				}
			}
		}
		
    }
	
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*
 this function will layout the subviews for the cell
 if the cell is not in editing mode we want to position them
 */
- (void)layoutSubviews {
	
    [super layoutSubviews];
	
	elife_bAppDelegate *elifeappdelegate = (elife_bAppDelegate *)[[UIApplication sharedApplication] delegate];
	elifezone *thezone = [elifeappdelegate.elifezonelist objectAtIndex:self.cellzoneidx];
	eliferoom *theroom = [thezone.roomlist objectAtIndex:self.cellroomidx];
	eliferoomtab *thetab = [theroom.tablist objectAtIndex:self.celltabidx];
	eliferoomcontrol *thecontrol = [thetab.controllist objectAtIndex:self.cellcontrolidx];
	elifecontroltypes *thecontroltype;
	NSString *controltypeid = [thecontrol.roomctrlattr objectForKey:@"type"];
	
	// getting the cell size
    CGRect contentRect = self.contentView.bounds;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    if (!self.editing) {
		
		// get the X pixel spot
        CGFloat boundsX = contentRect.origin.x;
		CGFloat framewidth = contentRect.size.width;
		CGRect frame;
		
		// Find specification for the control type
		NSInteger i=0;
		BOOL found=NO;
		while ((i < [elifeappdelegate.elifectrltypes count]) && !found) {
			thecontroltype = [elifeappdelegate.elifectrltypes objectAtIndex:i];
			if ([controltypeid isEqualToString:[thecontroltype controltype]]) {
				found=YES;
			} else {
				i++;
			}
		}
		
		// Loop through control type creating objects
		elifecontrolrow *currctrlrow;
		elifecontroltypeitem *currctrlitem;
		NSInteger nextrowoffset=0;
		NSInteger currrowoffset=10;
		NSDictionary *itemattrs;
		for (int j=0; j < [thecontroltype.displayrows count]; j++) {
			currctrlrow = [thecontroltype.displayrows objectAtIndex:j];
			currrowoffset = currrowoffset + nextrowoffset;
			nextrowoffset = 0;			
			for (int k=0; k < [currctrlrow.displayitems count]; k++) {
				currctrlitem = [currctrlrow.displayitems objectAtIndex:k];
				itemattrs = currctrlitem.itemattrs;
				if ([[itemattrs objectForKey:@"type"] isEqualToString:@"label"]) {
					frame = CGRectMake(boundsX + 10 + ((framewidth-20)/[currctrlrow.displayitems count]*k), currrowoffset, (framewidth-20)/[currctrlrow.displayitems count], 44);
					UIView *myuiobject = (UIView *)[self viewWithTag:(j+1)*100+k];
					myuiobject.frame = frame;
					if (nextrowoffset < 44) {
						nextrowoffset = nextrowoffset + 44;
					}
				} else if ([[itemattrs objectForKey:@"type"] isEqualToString:@"video"]) {
					NSInteger videoWidth=240;
					NSInteger videoHeight=180;
					if ([itemattrs objectForKey:@"videoWidth"]) {
						videoWidth = [[itemattrs objectForKey:@"videoWidth"] integerValue];
					}
					if ([itemattrs objectForKey:@"videoHeight"]) {
						videoWidth = [[itemattrs objectForKey:@"videoHeight"] integerValue];
					}
					frame = CGRectMake(((int)framewidth-20-videoWidth)/2, currrowoffset, videoWidth, videoHeight);
					UIView *myuiobject = (UIView *)[self viewWithTag:(j+1)*100+k];
					myuiobject.frame = frame;
					if (nextrowoffset < 200) {
						nextrowoffset = nextrowoffset + 200;
					}
				} else if ([[itemattrs objectForKey:@"type"] isEqualToString:@"button"]) {
					frame = CGRectMake(boundsX + 10 + ((framewidth-20)/[currctrlrow.displayitems count]*k), currrowoffset, (framewidth-20)/[currctrlrow.displayitems count], 44);
					UIView *myuiobject = (UIView *)[self viewWithTag:(j+1)*100+k];
					myuiobject.frame = frame;
					if (nextrowoffset < 44) {
						nextrowoffset = nextrowoffset + 44;
					}
				} else if ([[itemattrs objectForKey:@"type"] isEqualToString:@"toggle"]) {
					frame = CGRectMake(boundsX + 10 + ((framewidth-20)/[currctrlrow.displayitems count]*k), currrowoffset, (framewidth-20)/[currctrlrow.displayitems count], 44);
					UIView *myuiobject = (UIView *)[self viewWithTag:(j+1)*100+k];
					myuiobject.frame = frame;					
					if (nextrowoffset < 44) {
						nextrowoffset = nextrowoffset + 44;
					}
				}
			}
		}		
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
