//
//  TextFieldTableViewCell.m
//
//  Created by marc on 5/18/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import "TextFieldTableViewCell.h"


@implementation TextFieldTableViewCell

@synthesize label;
@synthesize textField;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
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
		label.textAlignment = UITextAlignmentRight;
		[self.contentView addSubview:label];
		
		textField = [[UITextField alloc] initWithFrame:CGRectZero];
		textField.backgroundColor = [UIColor clearColor];
		textField.opaque = NO;
		textField.textColor = [UIColor blackColor];
		textField.font = [UIFont systemFontOfSize:14.0];
		textField.delegate = self;
		[self.contentView addSubview:textField];
	}
	return self;
}

- (void)dealloc
{
	[label release];
	[textField release];
	[super dealloc];
}

- (void)layoutSubviews
{
	CGRect contentRect, frame;
	
	[super layoutSubviews];
	contentRect = [self.contentView bounds];

	frame = CGRectMake(contentRect.origin.x + 6.0, contentRect.origin.y + 8.0, 100.0, 26.0);
	label.frame = frame;

	frame = CGRectMake(contentRect.origin.x + 114.0, contentRect.origin.y + 12.0, 170.0, 26.0);
	textField.frame = frame;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField
{
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
	[aTextField resignFirstResponder];
	return NO;
}

@end
