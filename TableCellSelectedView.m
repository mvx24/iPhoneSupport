//
//  TableCellSelectedView.m
//
//  Copyright (c) 2013 Symbiotic Software LLC. All rights reserved.
//

#import "TableCellSelectedView.h"
#import "UIColorAddition.h"

@interface TableCellSelectedView ()
{
@private
	UIColor *color;
	UIColor *highColor;
	CAGradientLayer *gradientLayer;
}

@end

@implementation TableCellSelectedView

- (id)initWithFrame:(CGRect)frame withColor:(UIColor *)aColor
{
	if (self = [super initWithFrame:frame])
	{
		color = [aColor retain];
		highColor = [[color colorLightenedBy:0.5] retain];
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	if(IS_IOS_GTE(@"7.0"))
	{
		CGContextRef context = UIGraphicsGetCurrentContext();
		[color setFill];
		CGContextFillRect(context, rect);
	}
	else
	{
		if(!gradientLayer)
		{
			gradientLayer = [[CAGradientLayer alloc] init];
			gradientLayer.frame = self.frame;
			[gradientLayer setColors:[NSArray arrayWithObjects:(id)[highColor CGColor], (id)[color CGColor], nil]];
			[self.layer insertSublayer:gradientLayer atIndex:0];
		}
	}
	[super drawRect:rect];
}

- (void)dealloc
{
	[color release];
	[highColor release];
	[gradientLayer release];
	[super dealloc];
}

@end
