//
//  SwitchTableViewCell.m
//
//  Copyright 2012 Symbiotic Software LLC. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

- (id)init
{
	if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil])
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryView = [[[UISwitch alloc] init] autorelease];
	}
	return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryView = [[[UISwitch alloc] init] autorelease];
	}
	return self;
}

- (UISwitch *)onOffSwitch
{
	return (UISwitch *)self.accessoryView;
}

@end
