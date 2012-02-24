//
//  TextTableViewCell.m
//
//  Created by marc on 12/24/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import "TextTableViewCell.h"

#define TEXT_CELL_FONT ([UIFont systemFontOfSize:14.0])
#define TEXT_CELL_LINEBREAK (UILineBreakModeWordWrap)

@implementation TextTableViewCell

@synthesize label;
@synthesize textString;

+ (CGFloat)rowHeightForText:(NSString *)str withWidth:(CGFloat)width intoCell:(TextTableViewCell *)cell
{
	CGRect contentRect, frame;
	CGSize size, compSize;
	
	if(cell)
	{
		contentRect = cell.contentView.frame;
		width = contentRect.size.width;
	}
	
	size.width = width - ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?32.0:16.0);
	size.height = 1000;
	compSize = [str sizeWithFont:TEXT_CELL_FONT constrainedToSize:size lineBreakMode:TEXT_CELL_LINEBREAK];
	
	if(cell)
	{
		frame = CGRectMake(((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?16.0:14.0), 8.0, contentRect.size.width - ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?32.0:16.0), compSize.height);
		cell.label.frame = frame;
	}
	
	return compSize.height + 16.0;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
	{
		/* Setup the cell */
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		/* Setup the subview controls */
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.opaque = NO;
		label.font = TEXT_CELL_FONT;
		label.numberOfLines = 0;
		label.lineBreakMode = TEXT_CELL_LINEBREAK;
		[self.contentView addSubview:label];
	}
	return self;
}

- (void)dealloc
{
	[label release];
	self.textString = nil;
	[super dealloc];
}

- (void)layoutSubviews
{	
	[super layoutSubviews];
	[TextTableViewCell rowHeightForText:textString withWidth:0.0 intoCell:self];	
}

- (void)setTextString:(NSString *)aString
{
	if(textString != aString)
	{
		[textString release];
		textString = [aString retain];
		self.label.text = textString;
		[self setNeedsLayout];
	}
}

@end
