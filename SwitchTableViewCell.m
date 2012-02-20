//
//  SwitchTableViewCell.m
//
//  Created by marc on 5/18/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

@synthesize label;
@synthesize onOffSwitch;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	if(self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
	{
		/* Setup the cell */
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		/* Setup the subview controls */
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.opaque = NO;
		label.textColor = [UIColor blackColor];
		label.font = [UIFont boldSystemFontOfSize:14.0];
		[self.contentView addSubview:label];
		
		onOffSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		onOffSwitch.backgroundColor = [UIColor clearColor];
		onOffSwitch.opaque = NO;
		[self.contentView addSubview:onOffSwitch];
	}
	return self;
}

- (void)dealloc
{
	[label release];
	[onOffSwitch release];
    [super dealloc];
}

- (void)layoutSubviews
{
	CGRect contentRect, frame;
	
	[super layoutSubviews];
	contentRect = [self.contentView bounds];
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
	frame = CGRectMake(contentRect.origin.x + 8.0, contentRect.origin.y + 8.0, 200.0, 26.0);
	label.frame = frame;
	
	frame = CGRectMake(contentRect.origin.x + 196.0, contentRect.origin.y + 8.0, 94.0, 27.0);
	onOffSwitch.frame = frame;
}

@end
