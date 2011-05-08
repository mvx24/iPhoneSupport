//
//  FiveStarTableViewCell.m
//
//  Created by marc on 5/18/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import "FiveStarTableViewCell.h"

#define STAR_SIZE		38.0
#define STAR_SPACING	5.0

#define STAR_ON_COLOR	[UIColor colorWithRed:0.87 green:0.87 blue:0.0 alpha:1.0]
#define STAR_OFF_COLOR	[UIColor grayColor]
#define STAR_FONT		[UIFont boldSystemFontOfSize:32.0]

@implementation FiveStarTableViewCell

@synthesize value;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	CGFloat x, y;
	if(self = [super initWithStyle:UITableViewStylePlain reuseIdentifier:reuseIdentifier])
	{
		/* Setup the cell */
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		/* Setup the subview controls */
		x = ((self.frame.size.width) - ((STAR_SIZE * 5.0) + (STAR_SPACING * 4.0)))/2.0;
		y = (self.frame.size.height - STAR_SIZE)/2.0;
		one = [UIButton buttonWithType:UIButtonTypeCustom];
		one.titleLabel.font = STAR_FONT;
		[one setTitle:@"\u2605" forState:UIControlStateNormal];
		[one setTitleColor:STAR_OFF_COLOR forState:UIControlStateNormal];
		[one addTarget:self action:@selector(selectStar:) forControlEvents:UIControlEventTouchUpInside];
		one.frame = CGRectMake(x, y, STAR_SIZE, STAR_SIZE);
		[self.contentView addSubview:one];
		x += STAR_SIZE + STAR_SPACING;
		two = [UIButton buttonWithType:UIButtonTypeCustom];
		two.titleLabel.font = STAR_FONT;
		[two setTitle:@"\u2605" forState:UIControlStateNormal];
		[two setTitleColor:STAR_OFF_COLOR forState:UIControlStateNormal];
		[two addTarget:self action:@selector(selectStar:) forControlEvents:UIControlEventTouchUpInside];
		two.frame = CGRectMake(x, y, STAR_SIZE, STAR_SIZE);
		[self.contentView addSubview:two];
		x += STAR_SIZE + STAR_SPACING;
		three = [UIButton buttonWithType:UIButtonTypeCustom];
		three.titleLabel.font = STAR_FONT;
		[three setTitle:@"\u2605" forState:UIControlStateNormal];
		[three setTitleColor:STAR_OFF_COLOR forState:UIControlStateNormal];
		three.frame = CGRectMake(x, y, STAR_SIZE, STAR_SIZE);
		[three addTarget:self action:@selector(selectStar:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:three];
		x += STAR_SIZE + STAR_SPACING;
		four = [UIButton buttonWithType:UIButtonTypeCustom];
		four.titleLabel.font = STAR_FONT;
		[four setTitle:@"\u2605" forState:UIControlStateNormal];
		[four setTitleColor:STAR_OFF_COLOR forState:UIControlStateNormal];
		four.frame = CGRectMake(x, y, STAR_SIZE, STAR_SIZE);
		[four addTarget:self action:@selector(selectStar:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:four];
		x += STAR_SIZE + STAR_SPACING;
		five = [UIButton buttonWithType:UIButtonTypeCustom];
		five.titleLabel.font = STAR_FONT;
		[five setTitle:@"\u2605" forState:UIControlStateNormal];
		[five setTitleColor:STAR_OFF_COLOR forState:UIControlStateNormal];
		five.frame = CGRectMake(x, y, STAR_SIZE, STAR_SIZE);
		[five addTarget:self action:@selector(selectStar:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:five];
		stars[0] = one;
		stars[1] = two;
		stars[2] = three;
		stars[3] = four;
		stars[4] = five;
	}
	return self;
}

- (void)selectStar:(id)sender
{
	int i;
	for(i = 0; i < 5; ++i)
	{
		if(stars[i] == sender)
		{
			[self setValue:i+1];
			break;
		}
	}
}

- (void)setValue:(int)newValue
{
	int i;
	if(newValue != value)
	{
		value = newValue;
		for(i = 0; i < value; ++i)
			[stars[i] setTitleColor:STAR_ON_COLOR forState:UIControlStateNormal];
		for(; i < 5; ++i)
			[stars[i] setTitleColor:STAR_OFF_COLOR forState:UIControlStateNormal];
	}
}

/*- (void)layoutSubviews
{
	CGRect contentRect;
	
	[super layoutSubviews];
	contentRect = [self.contentView bounds];
}*/

@end
